
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
          points: 35,
          status: SessionStatus.accepted,
          message: 'I want to learn Figma basics.',
          createdAt: DateTime(2024, 4, 18),
          isOutgoing: false
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
          points: 53,
          status: SessionStatus.pending,
          message: 'Interested in learning design systems.',
          createdAt: DateTime(2024, 4, 22),
          isOutgoing: true
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
          points: 60,
          status: SessionStatus.accepted,
          message: null,
          createdAt: DateTime(2024, 4, 20),
          isOutgoing: true
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
          points: 30,
          status: SessionStatus.pending,
          message: null,
          createdAt: DateTime(2024, 4, 21),
          isOutgoing: false
        ),
      ];
 
      emit(SessionsLoaded(
        incoming: mockIncoming,
        myRequests: mockMyRequests,
      ));
 
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
 
    emit(SessionsActionLoading(
      incoming: current.incoming,
      myRequests: current.myRequests,
    ));
 
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
      emit(current); // revert to previous state
      emit(const SessionsError('Could not accept session. Try again.'));
    }
  }
 
  // ── Decline ──────────────────────────────
 
  Future<void> decline(String sessionId) async {
    final current = state;
    if (current is! SessionsLoaded) return;
 
    emit(SessionsActionLoading(
      incoming: current.incoming,
      myRequests: current.myRequests,
    ));
 
    try {
      // await _repo.declineSession(sessionId);
 
      // mock: remove locally
      final updated =
          current.incoming.where((s) => s.id != sessionId).toList();
 
      emit(current.copyWith(incoming: updated));
    } catch (e) {
      emit(current);
      emit(const SessionsError('Could not decline session. Try again.'));
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
    required String? message,
    required bool isOngoing,
  }) async {
    emit(const SessionsLoading());
 
    try {
      final points = ((pricePerHour * durationMinutes) / 60).round();
 
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
      //   points:            points,
      //   message:         message,
      //   isOngoing:       isOngoing,   
      // );
 
      emit(const SessionRequestSuccess());
    } catch (e) {
      emit(const SessionsError('Failed to send request. Please try again.'));
    }
  }
 
  // ── Rate ─────────────────────────────────
 
  // Future<void> submitRating({
  //   required String sessionId,
  //   required int stars,
  //   required String? review,
  // }) async {
  //   try {
  //     await _repo.submitRating(
  //       sessionId: sessionId,
  //       stars:     stars,
  //       review:    review,
  //     );
  //   } catch (e) {
  //     emit(const SessionsError('Could not submit rating. Try again.'));
  //   }
  // }
 
  // ── Helpers ──────────────────────────────
 
  int computeCost(int pricePerHour, int durationMinutes) =>
      ((pricePerHour * durationMinutes) / 60).round();
 
  // ── Dispose ──────────────────────────────
 
  @override
  Future<void> close() {
    _incomingSub?.cancel();
    _myRequestsSub?.cancel();
    return super.close();
  }
}
 