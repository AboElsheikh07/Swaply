import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final SessionRepository _repo;
  final String currentUid;

  StreamSubscription? _incomingSub;
  StreamSubscription? _myRequestsSub;

  SessionsCubit({required this.currentUid, SessionRepository? repo})
    : _repo = repo ?? SessionRepository(),
      super(const SessionsInitial());

  // ── Load ─────────────────────────────────

  Future<void> loadSessions() async {
    emit(const SessionsLoading());
    try {
      // ── Mock data (remove when backend is ready) ──
      await Future.delayed(const Duration(milliseconds: 300));

      final mockIncoming = [
        SessionItem(
          id: 's5',
          studentId: 'u_emma',
          teacherId: currentUid,
          studentName: 'Emma Richardson',
          teacherName: 'Me',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'Figma Basics',
          scheduledAt: DateTime(2024, 4, 24, 17, 0),
          durationMinutes: 60,
          isOutgoing: false,
          points: 35,
          status: SessionStatus.accepted,
          message: 'I want to learn Figma basics.',
          createdAt: DateTime(2024, 4, 18),
        ),
        SessionItem(
          id: 's6',
          studentId: 'u_david',
          teacherId: currentUid,
          studentName: 'David Park',
          teacherName: 'Me',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'Design Systems',
          scheduledAt: DateTime(2024, 4, 27, 11, 0),
          durationMinutes: 90,
          isOutgoing: false,
          points: 53,
          status: SessionStatus.pending,
          message: 'Interested in learning design systems.',
          createdAt: DateTime(2024, 4, 22),
        ),
      ];

      final mockMyRequests = [
        SessionItem(
          id: 's1',
          studentId: currentUid,
          teacherId: 'u_sarah',
          studentName: 'Me',
          teacherName: 'Sarah Chen',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'UI/UX Design',
          scheduledAt: DateTime(2024, 4, 25, 16, 0),
          durationMinutes: 60,
          isOutgoing: true,
          points: 60,
          status: SessionStatus.accepted,
          message: null,
          createdAt: DateTime(2024, 4, 20),
        ),
        SessionItem(
          id: 's2',
          studentId: currentUid,
          teacherId: 'u_maria',
          studentName: 'Me',
          teacherName: 'Maria Lopez',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'Spanish Tutoring',
          scheduledAt: DateTime(2024, 4, 26, 10, 0),
          durationMinutes: 45,
          isOutgoing: true,
          points: 30,
          status: SessionStatus.rejected,
          message: null,
          createdAt: DateTime(2024, 4, 21),
        ),
        SessionItem(
          id: 's3',
          studentId: currentUid,
          teacherId: 'u_priya',
          studentName: 'Me',
          teacherName: 'Priya Patel',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'Yoga & Meditation',
          scheduledAt: DateTime(2024, 4, 23, 9, 0),
          durationMinutes: 30,
          isOutgoing: true,
          points: 22,
          status: SessionStatus.ongoing,
          message: null,
          createdAt: DateTime(2024, 4, 22),
        ),
        SessionItem(
          id: 's4',
          studentId: currentUid,
          teacherId: 'u_james',
          studentName: 'Me',
          teacherName: 'James Wilson',
          studentAvatar: '',
          teacherAvatar: '',
          skill: 'Flutter & Mobile',
          scheduledAt: DateTime(2024, 4, 18, 14, 30),
          durationMinutes: 60,
          isOutgoing: true,
          points: 75,
          status: SessionStatus.completed,
          message: null,
          createdAt: DateTime(2024, 4, 10),
        ),
      ];

      emit(SessionsLoaded(incoming: mockIncoming, myRequests: mockMyRequests));

      // ── Real implementation (uncomment when backend ready) ──
      // _listenIncoming();
      // _listenMyRequests();
    } catch (e) {
      emit(const SessionsError('Failed to load sessions. Please try again.'));
    }
  }

  // ── Streams (uncomment when backend ready) ───

  // void _listenIncoming() {
  //   _incomingSub = _repo
  //       .watchIncomingRequests(currentUid)
  //       .listen((list) {
  //         final current = state;
  //         if (current is SessionsLoaded) {
  //           emit(current.copyWith(incoming: list));
  //         }
  //       });
  // }

  // void _listenMyRequests() {
  //   _myRequestsSub = _repo
  //       .watchMyRequests(currentUid)
  //       .listen((list) {
  //         final current = state;
  //         if (current is SessionsLoaded) {
  //           emit(current.copyWith(myRequests: list));
  //         }
  //       });
  // }

  // ── Accept ───────────────────────────────

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
      // await _repo.acceptSession(sessionId);

      // mock: update status locally
      final updated = current.incoming.map((s) {
        return s.id == sessionId
            ? s.copyWith(status: SessionStatus.accepted)
            : s;
      }).toList();

      emit(current.copyWith(incoming: updated));
    } catch (e) {
      emit(current); // revert
      emit(const SessionsError('Could not accept session. Try again.'));
    }
  }

  // ── Decline ──────────────────────────────

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
      // await _repo.declineSession(sessionId);

      // mock: remove locally
      final updated = current.incoming.where((s) => s.id != sessionId).toList();

      emit(current.copyWith(incoming: updated));
    } catch (e) {
      emit(current); // revert
      emit(const SessionsError('Could not decline session. Try again.'));
    }
  }

  // ── Cancel ───────────────────────────────

  Future<void> cancel(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;

    try {
      // await _repo.cancelSession(sessionId);

      // mock: remove from myRequests locally
      final updated = current.myRequests
          .where((s) => s.id != sessionId)
          .toList();

      emit(current.copyWith(myRequests: updated));
    } catch (e) {
      emit(const SessionsError('Could not cancel session. Try again.'));
    }
  }

  // ── Request new session ──────────────────

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

      // await _repo.requestSession(
      //   studentId:       currentUid,
      //   teacherId:       teacherId,
      //   studentName:     studentName,
      //   teacherName:     teacherName,
      //   studentAvatar:   studentAvatar,
      //   teacherAvatar:   teacherAvatar,
      //   skill:           skill,
      //   scheduledAt:     scheduledAt,
      //   durationMinutes: durationMinutes,
      //   points:          points,
      //   message:         message,
      // );

      emit(const SessionRequestSuccess());
    } catch (e) {
      emit(const SessionsError('Failed to send request. Please try again.'));
    }
  }

  // ── Rating ───────────────────────────────

  Future<void> submitRating({
    required String sessionId,
    required String rateeId,
    required String role, // 'teacher' or 'student'
    required int stars,
    String? review,
  }) async {
    try {
      // await _repo.submitRating(
      //   sessionId: sessionId,
      //   raterId:   currentUid,
      //   rateeId:   rateeId,
      //   role:      role,
      //   stars:     stars,
      //   review:    review,
      // );

      emit(const SessionRatingSuccess());
    } catch (e) {
      emit(const SessionsError('Could not submit rating. Try again.'));
    }
  }

  // ── Helpers ──────────────────────────────

  /// Display name for the other party depending on direction
  String otherPartyName(SessionItem session) =>
      session.isOutgoing ? session.teacherName : session.studentName;

  /// Avatar for the other party depending on direction
  String otherPartyAvatar(SessionItem session) =>
      session.isOutgoing ? session.teacherAvatar : session.studentAvatar;

  /// Role string of the person being rated
  String rateeRole(SessionItem session) =>
      session.isOutgoing ? 'teacher' : 'student';

  /// Role ID of the person being rated
  String rateeId(SessionItem session) =>
      session.isOutgoing ? session.teacherId : session.studentId;

  // ── Dispose ──────────────────────────────

  @override
  Future<void> close() {
    _incomingSub?.cancel();
    _myRequestsSub?.cancel();
    return super.close();
  }
}
