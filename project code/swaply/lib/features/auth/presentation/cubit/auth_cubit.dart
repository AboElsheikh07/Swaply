// auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/auth/data/repositories/auth_repository_firebase.dart';
import 'package:swaply/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      await _repo.login(email: email, password: password);
      if (!isClosed) emit(AuthSuccess());
    } catch (e) {
      if (!isClosed) emit(AuthError(e.toString()));
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      await _repo.signup(name: name, email: email, password: password);
      if (!isClosed) emit(AuthSuccess());
    } catch (e) {
      if (!isClosed) emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
      if (!isClosed) emit(AuthInitial());
    } catch (e) {
      if (!isClosed) emit(AuthError(e.toString()));
    }
  }

  Future<void> getCurrentUser() async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      final user = await _repo.getCurrentUser();
      if (!isClosed) emit(UserLoaded(user));
    } catch (e) {
      if (!isClosed) emit(AuthError(e.toString()));
    }
  }

  void resetState() {
    if (!isClosed) emit(AuthInitial());
  }
}