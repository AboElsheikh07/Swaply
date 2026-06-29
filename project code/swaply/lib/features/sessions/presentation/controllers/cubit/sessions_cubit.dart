import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final SessionRepository _repo;
  final String currentUid;

  StreamSubscription? _incomingSub;
  StreamSubscription? _myRequestsSub;

  SessionsCubit({required this.currentUid, SessionRepository? repo})
    : _repo = repo ?? SessionRepository(),
      super(const SessionsInitial());

  // ── Load ──────────────────────────────────

  Future<void> loadSessions() async {
    emit(const SessionsLoading());
    try {
      // ✅ emit empty lists immediately so UI shows empty state, not spinner forever
      emit(const SessionsLoaded(incoming: [], myRequests: []));
      _listenIncoming();
      _listenMyRequests();
    } catch (e) {
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
        }
      },
      onError: (_) =>
          emit(const SessionsError('Failed to load your requests.')),
    );
  }

  // ── Accept ────────────────────────────────

  Future<void> accept(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;

    emit(
      SessionsActionLoading(
        incoming: current.incoming,
        myRequests: current.myRequests,
      ),
    );

    try {
      await _repo.acceptSession(sessionId);
    } catch (e) {
      emit(current);
      emit(const SessionsError('Could not accept session. Try again.'));
    }
  }

  // ── Decline ───────────────────────────────

  Future<void> decline(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;

    emit(
      SessionsActionLoading(
        incoming: current.incoming,
        myRequests: current.myRequests,
      ),
    );

    try {
      await _repo.declineSession(sessionId);
    } catch (e) {
      emit(current);
      emit(const SessionsError('Could not decline session. Try again.'));
    }
  }

  // ── Cancel ────────────────────────────────

  Future<void> cancel(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;

    try {
      await _repo.cancelSession(sessionId);
    } catch (e) {
      emit(const SessionsError('Could not cancel session. Try again.'));
    }
  }

  Future<void> delete(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;

    try {
      await _repo.deleteSession(sessionId);
      // The Firestore stream will automatically remove it from the list
      // so no manual state update needed here.
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
    return super.close();
  }
}
