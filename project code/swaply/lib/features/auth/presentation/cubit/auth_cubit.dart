import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repo.login(email: email, password: password);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(e.message ?? 'Invalid email or password. Please try again.'),
      );
    } catch (e) {
      emit(AuthError('Invalid email or password. Please try again.'));
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _repo.signup(name: name, email: email, password: password);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Something went wrong. Please try again.'));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  void resetState() => emit(AuthInitial());
}
