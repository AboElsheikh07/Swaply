import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';

/// Raw Firestore access – no business logic here.
class SessionRemoteDataSource {
  final FirebaseFirestore _db;

  SessionRemoteDataSource({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _ratings =>
      _db.collection('ratings');

  // ── ID Generation ─────────────────────────────

  /// Generate a unique Firestore document ID without writing anything yet.
  /// This ID doubles as the Zego callID — no extra field needed.
  String generateSessionId() => _sessions.doc().id;

  // ── Streams ──────────────────────────────────

  /// Live list of sessions where the user is the teacher (incoming requests).
  Stream<List<SessionItem>> watchIncomingRequests(String uid) {
    return _sessions
        .where('teacherId', isEqualTo: uid)
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => SessionItem.fromFirestore(doc, uid))
              .toList(),
        );
  }

  /// Live list of sessions where the user is the student (my requests).
  Stream<List<SessionItem>> watchMyRequests(String uid) {
    return _sessions
        .where('studentId', isEqualTo: uid)
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => SessionItem.fromFirestore(doc, uid))
              .toList(),
        );
  }

  // ── Fetch once ───────────────────────────────

  /// One-time fetch of incoming requests (no real-time updates).
  Future<List<SessionItem>> fetchIncomingRequests(String uid) async {
    final snap = await _sessions
        .where('teacherId', isEqualTo: uid)
        .orderBy('scheduledAt')
        .get();
    return snap.docs.map((doc) => SessionItem.fromFirestore(doc, uid)).toList();
  }

  /// One-time fetch of my requests (no real-time updates).
  Future<List<SessionItem>> fetchMyRequests(String uid) async {
    final snap = await _sessions
        .where('studentId', isEqualTo: uid)
        .orderBy('scheduledAt')
        .get();
    return snap.docs.map((doc) => SessionItem.fromFirestore(doc, uid)).toList();
  }

  /// Fetch a single session by ID (for deep-link / notification open).
  Future<SessionItem?> fetchSession(String sessionId, String uid) async {
    final doc = await _sessions.doc(sessionId).get();
    return doc.exists ? SessionItem.fromFirestore(doc, uid) : null;
  }

  // ── Create ───────────────────────────────────

  /// Write a new session document to Firestore.
  Future<void> createSession(SessionItem session) async {
    await _sessions.doc(session.id).set(session.toFirestore());
  }

  // ── Status updates ───────────────────────────

  /// Update the status field of a session.
  Future<void> updateStatus(String sessionId, SessionStatus status) async {
    await _sessions.doc(sessionId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Reschedule ───────────────────────────────

  /// Update the scheduledAt field of a session.
  Future<void> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  }) async {
    await _sessions.doc(sessionId).update({
      'scheduledAt': Timestamp.fromDate(newScheduledAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Rating ───────────────────────────────────

  /// Write a rating document and update the ratee's average on their profile.
  Future<void> submitRating({
    required String sessionId,
    required String raterId,
    required String rateeId,
    required String role, // 'teacher' or 'student'
    required int stars,
    String? review,
  }) async {
    final ratingRef = _ratings.doc('${sessionId}_$role');

    // 1. Write the rating document
    await ratingRef.set({
      'sessionId': sessionId,
      'raterId': raterId,
      'rateeId': rateeId,
      'role': role,
      'stars': stars,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Update ratee's rating stats using a transaction
    //    so the average is always accurate
    final userRef = _users.doc(rateeId);
    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final data = userSnap.data() ?? {};

      final currentCount = (data['ratingCount'] as int?) ?? 0;
      final currentAvg = (data['ratingAvg'] as num?)?.toDouble() ?? 0.0;

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + stars) / newCount;

      tx.update(userRef, {
        'ratingCount': newCount,
        'ratingAvg': double.parse(newAvg.toStringAsFixed(1)),
        'ratingSessionId': sessionId,
      });
    });

    // 3. Mark the session as rated by this role
    await _sessions.doc(sessionId).update({
      '${role}Rated': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Points ───────────────────────────────────

  /// Deduct points from student, credit teacher — runs as a transaction
  /// so both writes succeed or both fail (no partial updates).
  Future<void> transferPoints({
    required String studentId,
    required String teacherId,
    required int points,
  }) async {
    final studentRef = _users.doc(studentId);
    final teacherRef = _users.doc(teacherId);

    await _db.runTransaction((tx) async {
      final studentSnap = await tx.get(studentRef);
      final teacherSnap = await tx.get(teacherRef);

      final studentPoints = (studentSnap.data()?['points'] as int?) ?? 0;
      final teacherPoints = (teacherSnap.data()?['points'] as int?) ?? 0;

      if (studentPoints < points) {
        throw Exception('Insufficient points');
      }

      tx.update(studentRef, {'points': studentPoints - points});
      tx.update(teacherRef, {'points': teacherPoints + points});
    });
  }

  // ── Delete ───────────────────────────────────

  /// Permanently delete a session document (admin / cleanup only).
  Future<void> deleteSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
  }
}