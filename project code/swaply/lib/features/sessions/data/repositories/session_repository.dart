import 'package:swaply/features/sessions/data/data_sources/session_remote_data_source.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/services/onesignal_push_service.dart';

/// Business-logic layer between cubit and data source.
class SessionRepository {
  final SessionRemoteDataSource _remote;

  SessionRepository({SessionRemoteDataSource? remote})
    : _remote = remote ?? SessionRemoteDataSource();

  // ── Streams ──────────────────────────────────

  /// Live list of requests sent TO the current user (they are the teacher).
  Stream<List<SessionItem>> watchIncomingRequests(String uid) =>
      _remote.watchIncomingRequests(uid);

  /// Live list of requests sent BY the current user (they are the student).
  Stream<List<SessionItem>> watchMyRequests(String uid) =>
      _remote.watchMyRequests(uid);

  // ── Fetch once ───────────────────────────────

  /// Fetch all incoming requests once (no real-time updates).
  Future<List<SessionItem>> fetchIncomingRequests(String uid) =>
      _remote.fetchIncomingRequests(uid);

  /// Fetch all my requests once (no real-time updates).
  Future<List<SessionItem>> fetchMyRequests(String uid) =>
      _remote.fetchMyRequests(uid);

  /// Fetch a single session by ID (for deep-link / notification open).
  Future<SessionItem?> fetchSession(String sessionId, String uid) =>
      _remote.fetchSession(sessionId, uid);

  // ── Create ───────────────────────────────────

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
    final docId = _remote.generateSessionId();

    final session = SessionItem(
      id: docId,
      studentId: studentId,
      teacherId: teacherId,
      studentName: studentName,
      teacherName: teacherName,
      studentAvatar: studentAvatar,
      teacherAvatar: teacherAvatar,
      skill: skill,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      isOutgoing: true,
      points: points,
      status: SessionStatus.pending,
      message: message,
      createdAt: DateTime.now(),
      studentRated: false,
      teacherRated: false,
    );

    await _remote.createSession(session);

    await OneSignalPushService.sendToUser(
      externalUserId: teacherId,
      title: 'New session request',
      body: '$studentName wants to book a $skill session',
      data: {'sessionId': docId, 'type': 'new_request'},
    );
  }

  // ── Status updates ───────────────────────────

  Future<void> acceptSession(String sessionId, SessionItem session) async {
    await _remote.acceptSessionWithHold(
      sessionId: sessionId,
      studentId: session.studentId,
      points: session.points,
    );

    await OneSignalPushService.sendToUser(
      externalUserId: session.studentId,
      title: 'Session accepted',
      body: '${session.teacherName} accepted your ${session.skill} request',
      data: {'sessionId': sessionId, 'type': 'accepted'},
    );
  }

  Future<void> notifySessionJoined({
    required SessionItem session,
    required String joinerUid,
  }) async {
    final teacherJoined = joinerUid == session.teacherId;
    final recipientId = teacherJoined ? session.studentId : session.teacherId;
    final joinerName = teacherJoined
        ? session.teacherName
        : session.studentName;

    await OneSignalPushService.sendToUser(
      externalUserId: recipientId,
      title: 'Your session partner joined',
      body: '$joinerName joined the ${session.skill} session — join now!',
      data: {'sessionId': session.id, 'type': 'partner_joined'},
    );
  }

  /// Marks a session completed and settles the held balance.
  /// Safe to call from either party's device, and safe to call more than
  /// once for the same session (the transaction's status guard no-ops it).
  Future<void> completeSession(SessionItem session) =>
      _remote.completeSessionAndSettle(
        sessionId: session.id,
        studentId: session.studentId,
        teacherId: session.teacherId,
        points: session.points,
      );

  Future<void> declineSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.rejected);

  Future<void> cancelSession(String sessionId) async {
    // fetch session to check if it was accepted (hold exists)
    final doc = await _remote.fetchSession(sessionId, '');

    if (doc != null && doc.status == SessionStatus.accepted) {
      // release held balance before cancelling
      await _remote.refundAndCancel(
        sessionId: sessionId,
        studentId: doc.studentId,
        teacherId: doc.teacherId,
        points: doc.points,
      );
    } else {
      // just pending → simple status update
      await _remote.updateStatus(sessionId, SessionStatus.cancelled);
    }
  }

  /// Session is marked as live/ongoing (triggered when host starts the call).
  Future<void> startSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.ongoing);

  // ── Rating ───────────────────────────────────

  /// Submit a star rating + optional review after a completed session.
  /// [role] is either 'student' or 'teacher' — who is being rated.
  Future<void> submitRating({
    required String sessionId,
    required String raterId,
    required String rateeId,
    required String role,
    required int stars,
    String? review,
  }) => _remote.submitRating(
    sessionId: sessionId,
    raterId: raterId,
    rateeId: rateeId,
    role: role,
    stars: stars,
    review: review,
  );

  // ── Delete ───────────────────────────────────

  /// Permanently delete a session document (admin / cleanup only).
  Future<void> deleteSession(String sessionId) =>
      _remote.deleteSession(sessionId);

  Future<void> deleteExpiredPendingSessions(String uid) =>
      _remote.deleteExpiredPendingSessions(uid);

  Future<void> handleExpiredAcceptedSessions(String uid) =>
      _remote.handleExpiredAcceptedSessions(uid);

  // ── Helpers ──────────────────────────────────

  /// Calculate points cost given an hourly rate and duration.
  int computePoints(int pricePerHour, int durationMinutes) =>
      ((pricePerHour * durationMinutes) / 60).round();
}
