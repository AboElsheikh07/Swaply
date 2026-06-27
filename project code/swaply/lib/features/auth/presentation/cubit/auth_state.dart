import 'package:swaply/features/user/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class UserLoaded extends AuthState {
  final UserModel user;

  UserLoaded(this.user);
}
