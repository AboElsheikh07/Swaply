import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';

// ─────────────────────────────────────────
//  States
// ─────────────────────────────────────────

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

/// Initial — nothing loaded yet
class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

/// Loading sessions from backend
class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

/// Sessions loaded successfully
class SessionsLoaded extends SessionsState {
  final List<SessionItem> incoming;
  final List<SessionItem> myRequests;

  const SessionsLoaded({
    required this.incoming,
    required this.myRequests,
  });

  SessionsLoaded copyWith({
    List<SessionItem>? incoming,
    List<SessionItem>? myRequests,
  }) {
    return SessionsLoaded(
      incoming: incoming ?? this.incoming,
      myRequests: myRequests ?? this.myRequests,
    );
  }

  @override
  List<Object?> get props => [incoming, myRequests];
}

/// Something went wrong
class SessionsError extends SessionsState {
  final String message;

  const SessionsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Accept / Decline in progress — keeps lists visible while waiting
class SessionsActionLoading extends SessionsState {
  final List<SessionItem> incoming;
  final List<SessionItem> myRequests;

  const SessionsActionLoading({
    required this.incoming,
    required this.myRequests,
  });

  @override
  List<Object?> get props => [incoming, myRequests];
}

/// New session request sent successfully
class SessionRequestSuccess extends SessionsState {
  const SessionRequestSuccess();
}

/// Rating submitted successfully
class SessionRatingSuccess extends SessionsState {
  const SessionRatingSuccess();
}

// ─────────────────────────────────────────
//  Cubit
// ─────────────────────────────────────────

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
     
      // ── Real implementation (uncomment when backend ready) ──
      _listenIncoming();
      _listenMyRequests();
    } catch (e) {
      emit(const SessionsError('Failed to load sessions. Please try again.'));
    }
  }

  // ── Streams (uncomment when backend ready) ───

  void _listenIncoming() {
    _incomingSub = _repo
        .watchIncomingRequests(currentUid)
        .listen((list) {
          final current = state;
          if (current is SessionsLoaded) {
            emit(current.copyWith(incoming: list));
          }
        });
  }

  void _listenMyRequests() {
    _myRequestsSub = _repo
        .watchMyRequests(currentUid)
        .listen((list) {
          final current = state;
          if (current is SessionsLoaded) {
            emit(current.copyWith(myRequests: list));
          }
        });
  }

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
      emit(current); // revert
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
      final updated =
          current.myRequests.where((s) => s.id != sessionId).toList();

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

      await _repo.requestSession(
        studentId:       currentUid,
        teacherId:       teacherId,
        studentName:     studentName,
        teacherName:     teacherName,
        studentAvatar:   studentAvatar,
        teacherAvatar:   teacherAvatar,
        skill:           skill,
        scheduledAt:     scheduledAt,
        durationMinutes: durationMinutes,
        points:          points,
        message:         message,
      );

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
      await _repo.submitRating(
        sessionId: sessionId,
        raterId:   currentUid,
        rateeId:   rateeId,
        role:      role,
        stars:     stars,
        review:    review,
      );

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