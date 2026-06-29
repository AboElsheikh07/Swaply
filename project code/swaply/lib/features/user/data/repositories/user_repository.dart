import 'package:swaply/features/user/data/datasources/user_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

class UserRepository {
  final UserRemoteDataSource _remote;

  UserRepository({UserRemoteDataSource? remote})
      : _remote = remote ?? UserRemoteDataSource();

  // ── Create ────────────────────────────────

  /// Call this right after Firebase Auth signup
  Future<void> createUser({
    required String uid,
    required String username,
    String avatarUrl = '',
  }) async {
    final user = UserModel.initial(
      id:        uid,
      username:  username,
      avatarUrl: avatarUrl,
    );
    await _remote.createUser(user);
  }

  /// Safe to call on every login — only writes if user doesn't exist yet
  Future<void> ensureUserExists({
    required String uid,
    required String username,
  }) async {
    final user = UserModel.initial(id: uid, username: username);
    await _remote.createUserIfNotExists(user);
  }

  // ── Read ──────────────────────────────────

  Future<UserModel?> fetchUser(String uid) =>
      _remote.fetchUser(uid);

  Stream<UserModel?> watchUser(String uid) =>
      _remote.watchUser(uid);

  // ── Update ────────────────────────────────

  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      _remote.updateUser(uid, fields);

  Future<void> updateAvatar(String uid, String avatarUrl) =>
      _remote.updateAvatar(uid, avatarUrl);

  Future<void> addTeachSkill(String uid, String skill) =>
      _remote.addTeachSkill(uid, skill);

  Future<void> removeTeachSkill(String uid, String skill) =>
      _remote.removeTeachSkill(uid, skill);

  Future<void> addLearnSkill(String uid, String skill) =>
      _remote.addLearnSkill(uid, skill);

  Future<void> removeLearnSkill(String uid, String skill) =>
      _remote.removeLearnSkill(uid, skill);

  // ── Balance ───────────────────────────────

  Future<void> deductBalance(String uid, int amount) =>
      _remote.deductBalance(uid, amount);

  Future<void> addBalance(String uid, int amount) =>
      _remote.addBalance(uid, amount);

  /// Atomic transfer — both writes succeed or neither does
  Future<void> transferBalance({
    required String fromUid,
    required String toUid,
    required int amount,
  }) => _remote.transferBalance(
        fromUid: fromUid,
        toUid:   toUid,
        amount:  amount,
      );

  // ── Explore ───────────────────────────────

  Future<List<UserModel>> fetchTeachersBySkill(String skill) =>
      _remote.fetchTeachersBySkill(skill);

  Future<List<UserModel>> fetchAllUsersExcept(String uid) =>
      _remote.fetchAllUsersExcept(uid);

  // ── Delete ────────────────────────────────

  Future<void> deleteUser(String uid) =>
      _remote.deleteUser(uid);
}