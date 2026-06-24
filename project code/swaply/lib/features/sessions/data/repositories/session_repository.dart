import 'package:uuid/uuid.dart';
import 'package:swaply/features/sessions/data/data_sources/session_remote_data_source.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';

/// Business-logic layer between cubit and data source.
class SessionRepository {
  final SessionRemoteDataSource _remote;
  final _uuid = const Uuid();

  SessionRepository({SessionRemoteDataSource? remote})
      : _remote = remote ?? SessionRemoteDataSource();

  // ── Streams ──────────────────────────────────

  /// Live list of requests sent TO the current user (they are the teacher).
  // Stream<List<SessionItem>> watchIncomingRequests(String uid) =>
  //     _remote.watchIncomingRequests(uid);

  /// Live list of requests sent BY the current user (they are the student).
  // Stream<List<SessionItem>> watchMyRequests(String uid) =>
  //     _remote.watchMyRequests(uid);

  // ── Fetch once ───────────────────────────────

  /// Fetch all incoming requests once (no real-time updates).
  // Future<List<SessionItem>> fetchIncomingRequests(String uid) =>
  //     _remote.fetchIncomingRequests(uid);

  /// Fetch all my requests once (no real-time updates).
  // Future<List<SessionItem>> fetchMyRequests(String uid) =>
  //     _remote.fetchMyRequests(uid);

  /// Fetch a single session by ID (for deep-link / notification open).
  // Future<SessionItem?> fetchSession(String sessionId) =>
  //     _remote.fetchSession(sessionId);

  // ── Create ───────────────────────────────────

  /// Student sends a new session request to a teacher.
  Future<void> requestSession({
    required String studentId,
    required String teacherId,
    required String studentName,
    required String teacherName,
    required String studentAvatar,
    required String teacherAvatar,
    required String skill,
    required DateTime scheduledAt,
    required int durationMinutes,
    required int points,
    String? message,
  }) async {
    final session = SessionItem(
      id: _uuid.v4(),
      studentId: studentId,
      teacherId: teacherId,
      studentName: studentName,
      teacherName: teacherName,
      studentAvatar: studentAvatar,
      teacherAvatar: teacherAvatar,
      skill: skill,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      isOutgoing: true, // always true — student is sending the request
      points: points,
      status: SessionStatus.pending,
      message: message,
      createdAt: DateTime.now(),
    );

    await _remote.createSession(session);
  }

  // ── Status updates ───────────────────────────

  /// Teacher accepts an incoming request.
  Future<void> acceptSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.accepted);

  /// Teacher declines an incoming request.
  Future<void> declineSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.rejected);

  /// Either party marks the session as completed.
  Future<void> completeSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.completed);

  /// Either party cancels before the session starts.
  Future<void> cancelSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.rejected);

  /// Session is marked as live/ongoing (triggered when host starts the call).
  Future<void> startSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.ongoing);

  // ── Reschedule ───────────────────────────────

  /// Update the scheduled date/time of a pending session.
  // Future<void> rescheduleSession({
  //   required String sessionId,
  //   required DateTime newScheduledAt,
  // }) =>
  //     _remote.rescheduleSession(
  //       sessionId: sessionId,
  //       newScheduledAt: newScheduledAt,
  //     );

  // ── Rating ───────────────────────────────────

  /// Submit a star rating + optional review after a completed session.
  /// [role] is either 'student' or 'teacher' — who is being rated.
  // Future<void> submitRating({
  //   required String sessionId,
  //   required String raterId,
  //   required String rateeId,
  //   required String role,
  //   required int stars,
  //   String? review,
  // }) =>
  //     _remote.submitRating(
  //       sessionId: sessionId,
  //       raterId: raterId,
  //       rateeId: rateeId,
  //       role: role,
  //       stars: stars,
  //       review: review,
  //     );

  // ── Points ───────────────────────────────────

  /// Deduct points from student and credit teacher after session completes.
  // Future<void> transferPoints({
  //   required String studentId,
  //   required String teacherId,
  //   required int points,
  // }) =>
  //     _remote.transferPoints(
  //       studentId: studentId,
  //       teacherId: teacherId,
  //       points: points,
  //     );

  // ── Delete ───────────────────────────────────

  /// Permanently delete a session document (admin / cleanup only).
  Future<void> deleteSession(String sessionId) =>
      _remote.deleteSession(sessionId);

  // ── Helpers ──────────────────────────────────

  /// Calculate points cost given an hourly rate and duration.
  int computePoints(int pricePerHour, int durationMinutes) =>
      ((pricePerHour * durationMinutes) / 60).round();
}