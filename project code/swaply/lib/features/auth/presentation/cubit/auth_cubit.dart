import 'package:flutter_bloc/flutter_bloc.dart';
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
    } catch (e) {
      emit(AuthError('Invalid email or password. Please try again.'));
    }
  }

  Future<void> signup({required String name, required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repo.signup(name: name, email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  void resetState() => emit(AuthInitial());
}
