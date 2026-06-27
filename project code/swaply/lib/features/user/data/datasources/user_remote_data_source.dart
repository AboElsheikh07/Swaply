import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _db;

  UserRemoteDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Collection reference ──────────────────
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ── Create ────────────────────────────────

  /// Called once at signup — creates the users/{uid} document
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  /// Only creates the document if it doesn't exist yet (safe to call on every login)
  Future<void> createUserIfNotExists(UserModel user) async {
    final doc = await _users.doc(user.id).get();
    if (!doc.exists) {
      await createUser(user);
    }
  }

  // ── Read ──────────────────────────────────

  /// Fetch a user once by UID
  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Live stream of the current user's document
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── Update ────────────────────────────────

  /// Update specific fields — only the fields you pass get written
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update(fields);
  }

  /// Replace the avatar URL
  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _users.doc(uid).update({'avatarUrl': avatarUrl});
  }

  /// Add a skill to skillsCanTeach
  Future<void> addTeachSkill(String uid, String skill) async {
    await _users.doc(uid).update({
      'skillsCanTeach': FieldValue.arrayUnion([skill]),
    });
  }

  /// Remove a skill from skillsCanTeach
  Future<void> removeTeachSkill(String uid, String skill) async {
    await _users.doc(uid).update({
      'skillsCanTeach': FieldValue.arrayRemove([skill]),
    });
  }

  /// Add a skill to skillsWantsToLearn
  Future<void> addLearnSkill(String uid, String skill) async {
    await _users.doc(uid).update({
      'skillsWantsToLearn': FieldValue.arrayUnion([skill]),
    });
  }

  /// Remove a skill from skillsWantsToLearn
  Future<void> removeLearnSkill(String uid, String skill) async {
    await _users.doc(uid).update({
      'skillsWantsToLearn': FieldValue.arrayRemove([skill]),
    });
  }

  // ── Balance ───────────────────────────────

  /// Deduct points from a user's balance (used after session request)
  Future<void> deductBalance(String uid, int amount) async {
    await _users.doc(uid).update({
      'balance': FieldValue.increment(-amount),
    });
  }

  /// Add points to a user's balance (used after session completion)
  Future<void> addBalance(String uid, int amount) async {
    await _users.doc(uid).update({
      'balance': FieldValue.increment(amount),
    });
  }

  /// Transfer points between student and teacher atomically
  /// so both writes succeed or neither does
  Future<void> transferBalance({
    required String fromUid,
    required String toUid,
    required int amount,
  }) async {
    final batch = _db.batch();
    batch.update(_users.doc(fromUid), {'balance': FieldValue.increment(-amount)});
    batch.update(_users.doc(toUid),   {'balance': FieldValue.increment(amount)});
    await batch.commit();
  }

  // ── Explore ───────────────────────────────

  /// Fetch all users who can teach a given skill (for Explore screen)
  Future<List<UserModel>> fetchTeachersBySkill(String skill) async {
    final query = await _users
        .where('skillsCanTeach', arrayContains: skill)
        .get();
    return query.docs.map(UserModel.fromFirestore).toList();
  }

  /// Fetch all users except the current one (for Explore screen)
  Future<List<UserModel>> fetchAllUsersExcept(String uid) async {
    final query = await _users.where(FieldPath.documentId, isNotEqualTo: uid).get();
    return query.docs.map(UserModel.fromFirestore).toList();
  }

  // ── Delete ────────────────────────────────

  /// Permanently delete a user document (account deletion)
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }
}