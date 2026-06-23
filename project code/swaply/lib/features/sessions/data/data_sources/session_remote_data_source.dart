import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

/// Raw Firestore access – no business logic here.
class SessionRemoteDataSource {
  final FirebaseFirestore _db;

  SessionRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');

  // ── Streams ──────────────────────────────────

  /// All sessions where the user is the teacher (incoming requests).
  // Stream<List<SessionItem>> watchIncomingRequests(String uid) {
    
    // return _sessions
        // .where('teacherId', isEqualTo: uid)
        // .orderBy('scheduledAt')
        // .snapshots()
        // .map((snap) => snap.docs.map(SessionItem.fromFirestore).toList());
  // }

  /// All sessions where the user is the student (my requests).
  // Stream<List<SessionItem>> watchMyRequests(String uid) {
  //   return _sessions
  //       .where('studentId', isEqualTo: uid)
  //       .orderBy('scheduledAt')
  //       .snapshots()
  //       .map((snap) => snap.docs.map(SessionItem.fromFirestore).toList());
  // }

  // ── Mutations ────────────────────────────────

  Future<void> createSession(SessionItem session) async {
    await _sessions.doc(session.id).set(session.toFirestore());
  }

  Future<void> updateStatus(String sessionId, SessionStatus status) async {
    await _sessions.doc(sessionId).update({'status': status.name});
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
  }

  /// Fetch a single session once (for deep-link / notification open).
  // Future<SessionItem?> fetchSession(String sessionId) async {
    // final doc = await _sessions.doc(sessionId).get();
    // return doc.exists ? SessionItem.fromFirestore(doc) : null;
  // }
}
