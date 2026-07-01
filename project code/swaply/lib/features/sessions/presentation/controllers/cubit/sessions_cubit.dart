import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final SessionRepository _repo;
  final String currentUid;
  Timer? _completionSweepTimer;

  StreamSubscription? _incomingSub;
  StreamSubscription? _myRequestsSub;

  SessionsCubit({required this.currentUid, SessionRepository? repo})
    : _repo = repo ?? SessionRepository(),
      super(const SessionsInitial());

  // ── Load ──────────────────────────────────

  Future<void> loadSessions() async {
    emit(const SessionsLoading());
    try {
      await _repo.deleteExpiredPendingSessions(currentUid);

      await _repo.handleExpiredAcceptedSessions(currentUid);

      emit(const SessionsLoaded(incoming: [], myRequests: []));
      _listenIncoming();
      _listenMyRequests();
      _startCompletionSweep();
    } catch (e) {
      print(e);
      emit(const SessionsError('Failed to load sessions. Please try again.'));
    }
  }

  // ── Streams ───────────────────────────────
  void _listenIncoming() {
    _incomingSub = _repo.watchIncomingRequests(currentUid).listen(
      (list) {
        final current = state;
        if (current is SessionsLoaded) {
          emit(current.copyWith(incoming: list));
        } else if (current is SessionsActionLoading) {
          emit(SessionsLoaded(incoming: list, myRequests: current.myRequests));
        }
      },
      onError: (_) =>
          emit(const SessionsError('Failed to load incoming requests.')),
    );
  }

  void _listenMyRequests() {
    _myRequestsSub = _repo.watchMyRequests(currentUid).listen(
      (list) {
        final current = state;
        if (current is SessionsLoaded) {
          emit(current.copyWith(myRequests: list));
        } else if (current is SessionsActionLoading) {
          emit(SessionsLoaded(incoming: current.incoming, myRequests: list));
        }
      },
      onError: (_) =>
          emit(const SessionsError('Failed to load your requests.')),
    );
  }
  // ── Auto-complete sweep ───────────────────

  /// Re-checks the already-loaded lists every 30s for sessions whose
  /// end time has passed. Firestore streams won't emit on their own near
  /// that moment (nothing writes to the doc as time passes), so this
  /// timer is what actually notices and triggers completion+settlement.
  void _startCompletionSweep() {
    _completionSweepTimer?.cancel();
    _completionSweepTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final current = state;
      if (current is! SessionsLoaded) return;
      for (final s in [...current.incoming, ...current.myRequests]) {
        if (s.isPastEnd) {
          _repo.completeSession(
            s,
          ); // fire-and-forget; transaction is idempotent-safe
        }
      }
    });
  }

  // ── Accept ────────────────────────────────
  Future<void> accept(String sessionId) async {
    if (state is! SessionsLoaded) return;
    try {
      final session = (state as SessionsLoaded).incoming.firstWhere(
        (s) => s.id == sessionId,
      );
      await _repo.acceptSession(sessionId, session);
      // ✅ stream fires automatically → UI updates
    } catch (e) {
      emit(const SessionsError('Could not accept session. Try again.'));
    }
  }

  Future<void> decline(String sessionId) async {
    if (state is! SessionsLoaded) return;
    try {
      await _repo.declineSession(sessionId);
      // ✅ stream fires automatically → UI updates
    } catch (e) {
      emit(const SessionsError('Could not decline session. Try again.'));
    }
  }

  Future<void> cancel(String sessionId) async {
    if (state is! SessionsLoaded) return;
    try {
      await _repo.cancelSession(sessionId);
      // ✅ stream fires automatically → UI updates
    } catch (e) {
      emit(const SessionsError('Could not cancel session. Try again.'));
    }
  }

  Future<void> delete(String sessionId) async {
    if (state is! SessionsLoaded) return;
    try {
      await _repo.deleteSession(sessionId);
      // ✅ stream fires automatically → removes from list
    } catch (e) {
      emit(const SessionsError('Could not delete session. Try again.'));
    }
  }

  // ── Request session ───────────────────────

  Future<void> requestSession({
    required String teacherId,
    required String teacherName,
    required String teacherAvatar,
    required String studentName,
    required String studentAvatar,
    required String skill,
    required DateTime scheduledAt,
    required int durationMinutes,
    required int pricePerHour,
    String? message,
  }) async {
    emit(const SessionsLoading());
    try {
      final points = _repo.computePoints(pricePerHour, durationMinutes);
      await _repo.requestSession(
        studentId: currentUid,
        teacherId: teacherId,
        studentName: studentName,
        teacherName: teacherName,
        studentAvatar: studentAvatar,
        teacherAvatar: teacherAvatar,
        skill: skill,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        points: points,
        message: message,
      );
      emit(const SessionRequestSuccess());
    } catch (e) {
      emit(const SessionsError('Failed to send request. Please try again.'));
    }
  }

  // ── Join notification ─────────────────────

  /// Fire-and-forget: tells the other party someone joined the call.
  /// Doesn't block or disrupt navigation if the push fails.
  Future<void> notifyJoined(SessionItem session) async {
    try {
      await _repo.notifySessionJoined(session: session, joinerUid: currentUid);
    } catch (_) {
      // non-critical — joining the call should proceed regardless
    }
  }

  // ── Rating ────────────────────────────────

  Future<void> submitRating({
    required String sessionId,
    required String rateeId,
    required String role,
    required int stars,
    String? review,
  }) async {
    try {
      await _repo.submitRating(
        sessionId: sessionId,
        raterId: currentUid,
        rateeId: rateeId,
        role: role,
        stars: stars,
        review: review,
      );
      emit(const SessionRatingSuccess());
    } catch (e) {
      emit(const SessionsError('Could not submit rating. Try again.'));
    }
  }

  // ── Helpers ───────────────────────────────

  String otherPartyName(SessionItem session) =>
      session.isOutgoing ? session.teacherName : session.studentName;

  String otherPartyAvatar(SessionItem session) =>
      session.isOutgoing ? session.teacherAvatar : session.studentAvatar;

  String rateeRole(SessionItem session) =>
      session.isOutgoing ? 'teacher' : 'student';

  String rateeId(SessionItem session) =>
      session.isOutgoing ? session.teacherId : session.studentId;

  // ── Dispose ───────────────────────────────

  @override
  Future<void> close() {
    _incomingSub?.cancel();
    _myRequestsSub?.cancel();
    _completionSweepTimer?.cancel();
    return super.close();
  }
}
