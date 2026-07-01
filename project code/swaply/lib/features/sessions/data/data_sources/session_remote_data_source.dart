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
      'status': status.name, // ✅ saves 'accepted' not 'Accepted'
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Accept (with hold) ────────────────────────

  /// Accepts a session and holds the cost on the student's balance,
  /// atomically. Guards against double-processing if called twice.
  Future<void> acceptSessionWithHold({
    required String sessionId,
    required String studentId,
    required int points,
  }) async {
    final sessionRef = _sessions.doc(sessionId);
    final studentRef = _users.doc(studentId);

    await _db.runTransaction((tx) async {
      final sessionSnap = await tx.get(sessionRef);
      final status = sessionSnap.data()?['status'];
      if (status != SessionStatus.pending.name) return; // already handled

      tx.update(sessionRef, {
        'status': SessionStatus.accepted.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(studentRef, {'heldBalance': FieldValue.increment(points)});
    });
  }

  // ── Complete + settle ──────────────────────────

  /// Marks an accepted/ongoing session completed and moves the held
  /// points: deducted from student.balance, released from
  /// student.heldBalance, credited to teacher.balance. One transaction,
  /// guarded by a status check so a second concurrent call (e.g. both
  /// users' devices sweeping at once) is a safe no-op.
  Future<void> completeSessionAndSettle({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required int points,
  }) async {
    final sessionRef = _sessions.doc(sessionId);
    final studentRef = _users.doc(studentId);
    final teacherRef = _users.doc(teacherId);

    await _db.runTransaction((tx) async {
      final sessionSnap = await tx.get(sessionRef);
      final status = sessionSnap.data()?['status'];
      if (status != SessionStatus.accepted.name &&
          status != SessionStatus.ongoing.name) {
        return; // already completed/cancelled elsewhere — skip
      }

      tx.update(sessionRef, {
        'status': SessionStatus.completed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(studentRef, {
        'balance': FieldValue.increment(-points),
        'heldBalance': FieldValue.increment(-points),
      });
      tx.update(teacherRef, {'balance': FieldValue.increment(points)});
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

  // ── Delete ───────────────────────────────────

  /// Permanently delete a session document (admin / cleanup only).
  Future<void> deleteSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
  }

  /// Deletes pending sessions whose scheduledAt has passed.
  /// Called on app open — no backend needed.
  Future<void> deleteExpiredPendingSessions(String uid) async {
    final now = Timestamp.fromDate(DateTime.now());

    // Check sessions where user is student (outgoing)
    final asStudent = await _sessions
        .where('studentId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .where('scheduledAt', isLessThan: now)
        .get();

    // Check sessions where user is teacher (incoming)
    final asTeacher = await _sessions
        .where('teacherId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .where('scheduledAt', isLessThan: now)
        .get();

    final batch = _db.batch();
    for (final doc in [...asStudent.docs, ...asTeacher.docs]) {
      batch.delete(doc.reference);
    }
    if (asStudent.docs.isNotEmpty || asTeacher.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  /// Called on app open after deleteExpiredPendingSessions.
  /// Handles accepted sessions whose time window has fully passed.
  Future<void> handleExpiredAcceptedSessions(String uid) async {
    final now = DateTime.now();

    final asStudent = await _sessions
        .where('studentId', isEqualTo: uid)
        .where('status', isEqualTo: SessionStatus.accepted.name)
        .get();

    final asTeacher = await _sessions
        .where('teacherId', isEqualTo: uid)
        .where('status', isEqualTo: SessionStatus.accepted.name)
        .get();

    // deduplicate — same session might appear in both queries
    final seen = <String>{};
    final allDocs = [
      ...asStudent.docs,
      ...asTeacher.docs,
    ].where((doc) => seen.add(doc.id)).toList();

    for (final doc in allDocs) {
      final data = doc.data();
      final scheduledAt = (data['scheduledAt'] as Timestamp).toDate();
      final duration = (data['durationMinutes'] as int?) ?? 60;
      final sessionEnd = scheduledAt.add(Duration(minutes: duration));

      if (now.isAfter(sessionEnd)) {
        final studentId = data['studentId'] as String;
        final teacherId = data['teacherId'] as String;
        final points = (data['points'] as int?) ?? 0;

        // Session ended with no join → refund student, cancel
        await _refundAndCancel(
          sessionId: doc.id,
          studentId: studentId,
          teacherId: teacherId,
          points: points,
        );
      }
    }
  }

  Future<void> _refundAndCancel({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required int points,
  }) async {
    final sessionRef = _sessions.doc(sessionId);
    final studentRef = _users.doc(studentId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(sessionRef);
      final status = snap.data()?['status'];

      // Guard — only cancel if still accepted (not completed/cancelled elsewhere)
      if (status != SessionStatus.accepted.name) return;

      // 1. Cancel the session
      tx.update(sessionRef, {
        'status': SessionStatus.cancelled.name,
        'cancelledReason': 'expired_no_join',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Release held balance — student gets their points back
      tx.update(studentRef, {
        'heldBalance': FieldValue.increment(-points),
        // balance stays the same — points were only held, not spent
      });
    });
  }
}
