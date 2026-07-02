import 'package:equatable/equatable.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial — nothing loaded yet
class UserInitial extends UserState {
  const UserInitial();
}

/// Fetching user from Firestore
class UserLoading extends UserState {
  const UserLoading();
}

/// User loaded successfully
class UserLoaded extends UserState {
  final UserModel user;
  final int sessionsCount;

  const UserLoaded(this.user, {this.sessionsCount = 0});

  @override
  List<Object?> get props => [user, sessionsCount];
}

/// Something went wrong
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

/// A specific action is in progress (update avatar, add skill, etc.)
/// Keeps the current user visible while waiting
class UserActionLoading extends UserState {
  final UserModel user;

  const UserActionLoading(this.user);

  @override
  List<Object?> get props => [user];
}

/// An action completed successfully (avatar updated, skill added, etc.)
class UserActionSuccess extends UserState {
  final UserModel user;
  final String message;

  const UserActionSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}
