import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repo;
  final String currentUid;

  StreamSubscription<UserModel?>? _userSub;

  UserCubit({required this.currentUid, UserRepository? repo})
    : _repo = repo ?? UserRepository(),
      super(const UserInitial());

  // ── Load ─────────────────────────────────

  /// Start watching the current user's document in real time.
  /// Call this once after login — UI stays in sync automatically.
  void watchUser() {
    emit(const UserLoading());
    _userSub = _repo
        .watchUser(currentUid)
        .listen(
          (user) async {
            if (user == null) {
              emit(const UserError('User not found.'));
              return;
            }
            final count = await _repo.getCompletedSessionsCount(currentUid);
            emit(UserLoaded(user, sessionsCount: count));
          },
          onError: (_) {
            emit(const UserError('Failed to load user. Please try again.'));
          },
        );
  }

  Future<void> fetchUser() async {
    emit(const UserLoading());
    try {
      final user = await _repo.fetchUser(currentUid);
      if (user == null) {
        emit(const UserError('User not found.'));
        return;
      }
      final count = await _repo.getCompletedSessionsCount(currentUid);
      emit(UserLoaded(user, sessionsCount: count));
    } catch (_) {
      emit(const UserError('Failed to load user. Please try again.'));
    }
  }

  // ── Helpers ──────────────────────────────

  /// Current user — returns empty model if not loaded yet.
  /// Useful for reading balance/name without checking state type everywhere.
  UserModel get currentUser {
    final s = state;
    if (s is UserLoaded) return s.user;
    if (s is UserActionLoading) return s.user;
    if (s is UserActionSuccess) return s.user;
    return UserModel.empty();
  }

/// Completed sessions count — 0 if not loaded yet.
int get sessionsCount {
  final s = state;
  if (s is UserLoaded) return s.sessionsCount;
  return 0;
}
  /// Spendable balance — safe to call from UI directly.
  int get spendableBalance => currentUser.spendableBalance;

  /// Whether user can afford a given cost.
  bool canAfford(int cost) => currentUser.canAfford(cost);

  // ── Avatar ───────────────────────────────

  Future<void> updateAvatar(String avatarUrl) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      await _repo.updateAvatar(currentUid, avatarUrl);
      // watchUser stream will emit the updated user automatically
      // if using watchUser(); otherwise update locally:
      emit(
        UserActionSuccess(
          user: current.copyWith(avatarUrl: avatarUrl),
          message: 'Avatar updated.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not update avatar. Try again.'));
    }
  }

  // ── Skills ───────────────────────────────

  Future<void> addTeachSkill(String skill) async {
    final current = currentUser;
    if (current.skillsCanTeach.contains(skill)) return;
    emit(UserActionLoading(current));
    try {
      await _repo.addTeachSkill(currentUid, skill);
      emit(
        UserActionSuccess(
          user: current.copyWith(
            skillsCanTeach: [...current.skillsCanTeach, skill],
          ),
          message: 'Skill added.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not add skill. Try again.'));
    }
  }

  Future<void> removeTeachSkill(String skill) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      await _repo.removeTeachSkill(currentUid, skill);
      emit(
        UserActionSuccess(
          user: current.copyWith(
            skillsCanTeach: current.skillsCanTeach
                .where((s) => s != skill)
                .toList(),
          ),
          message: 'Skill removed.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not remove skill. Try again.'));
    }
  }

  Future<void> addLearnSkill(String skill) async {
    final current = currentUser;
    if (current.skillsWantsToLearn.contains(skill)) return;
    emit(UserActionLoading(current));
    try {
      await _repo.addLearnSkill(currentUid, skill);
      emit(
        UserActionSuccess(
          user: current.copyWith(
            skillsWantsToLearn: [...current.skillsWantsToLearn, skill],
          ),
          message: 'Skill added.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not add skill. Try again.'));
    }
  }

  Future<void> removeLearnSkill(String skill) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      await _repo.removeLearnSkill(currentUid, skill);
      emit(
        UserActionSuccess(
          user: current.copyWith(
            skillsWantsToLearn: current.skillsWantsToLearn
                .where((s) => s != skill)
                .toList(),
          ),
          message: 'Skill removed.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not remove skill. Try again.'));
    }
  }

  // ── Profile ──────────────────────────────

  Future<void> uploadAvatar(File imageFile) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      final url = await _repo.uploadAvatar(currentUid, imageFile);
      emit(
        UserActionSuccess(
          user: current.copyWith(avatarUrl: url),
          message: 'Avatar updated.',
        ),
      );
    } catch (e, stacktrace) {
      print('Avatar upload error: $e');
      print(stacktrace);
      emit(UserLoaded(current));
      emit(const UserError('Could not update avatar. Try again.'));
    }
  }

  Future<void> updateProfile({required String username}) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      await _repo.updateUser(currentUid, {'username': username});
      emit(
        UserActionSuccess(
          user: current.copyWith(username: username),
          message: 'Profile updated.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not update profile. Try again.'));
    }
  }

  // ── Balance ──────────────────────────────

  Future<void> deductBalance(int amount) async {
    final current = currentUser;
    if (!current.canAfford(amount)) {
      emit(const UserError('Insufficient points.'));
      return;
    }
    emit(UserActionLoading(current));
    try {
      await _repo.deductBalance(currentUid, amount);
      emit(
        UserActionSuccess(
          user: current.copyWith(balance: current.balance - amount),
          message: 'Balance deducted.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not deduct balance. Try again.'));
    }
  }

  Future<void> addBalance(int amount) async {
    final current = currentUser;
    emit(UserActionLoading(current));
    try {
      await _repo.addBalance(currentUid, amount);
      emit(
        UserActionSuccess(
          user: current.copyWith(balance: current.balance + amount),
          message: 'Balance updated.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not update balance. Try again.'));
    }
  }

  Future<void> transferBalance({
    required String toUid,
    required int amount,
  }) async {
    final current = currentUser;
    if (!current.canAfford(amount)) {
      emit(const UserError('Insufficient points.'));
      return;
    }
    emit(UserActionLoading(current));
    try {
      await _repo.transferBalance(
        fromUid: currentUid,
        toUid: toUid,
        amount: amount,
      );
      emit(
        UserActionSuccess(
          user: current.copyWith(balance: current.balance - amount),
          message: 'Points transferred.',
        ),
      );
    } catch (_) {
      emit(UserLoaded(current));
      emit(const UserError('Could not transfer points. Try again.'));
    }
  }

  // ── Delete ───────────────────────────────

  Future<void> deleteAccount() async {
    emit(const UserLoading());
    try {
      await _repo.deleteUser(currentUid);
      emit(const UserInitial());
    } catch (_) {
      emit(const UserError('Could not delete account. Try again.'));
    }
  }

  // ── Dispose ──────────────────────────────

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
