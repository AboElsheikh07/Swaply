import 'package:uuid/uuid.dart';
import '../data_sources/session_remote_data_source.dart';
import '../models/session_model.dart';

/// Business-logic layer between controller and data source.
class SessionRepository {
  final SessionRemoteDataSource _remote;
  final _uuid = const Uuid();

  SessionRepository({SessionRemoteDataSource? remote})
      : _remote = remote ?? SessionRemoteDataSource();

  // ── Streams ──────────────────────────────────

  Stream<List<SessionModel>> watchIncomingRequests(String uid) =>
      _remote.watchIncomingRequests(uid);

  Stream<List<SessionModel>> watchMyRequests(String uid) =>
      _remote.watchMyRequests(uid);

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
    required int cost,
    String? message,
  }) async {
    final session = SessionModel(
      id:              _uuid.v4(),
      studentId:       studentId,
      teacherId:       teacherId,
      studentName:     studentName,
      teacherName:     teacherName,
      studentAvatar:   studentAvatar,
      teacherAvatar:   teacherAvatar,
      skill:           skill,
      scheduledAt:     scheduledAt,
      durationMinutes: durationMinutes,
      cost:            cost,
      status:          SessionStatus.pending,
      message:         message,
      createdAt:       DateTime.now(),
    );
    await _remote.createSession(session);
  }

  // ── Status updates ───────────────────────────

  Future<void> acceptSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.accepted);

  Future<void> declineSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.rejected);

  Future<void> completeSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.completed);

  Future<void> cancelSession(String sessionId) =>
      _remote.updateStatus(sessionId, SessionStatus.cancelled);

  // ── Fetch once ───────────────────────────────

  Future<SessionModel?> fetchSession(String sessionId) =>
      _remote.fetchSession(sessionId);
}
