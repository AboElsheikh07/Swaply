import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forgot_password_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository _repo;

  ForgotPasswordCubit(this._repo) : super(ForgotPasswordInitial());

  Future<void> sendCode({required String email}) async {
    emit(ForgotPasswordLoading());
    try {
      await _repo.sendCode(email: email);
      emit(CodeSentSuccess());
    } catch (e) {
      emit(ForgotPasswordError('Failed to send code. Please try again.'));
    }
  }

  Future<void> verifyCode({required String code}) async {
    emit(ForgotPasswordLoading());
    try {
      await _repo.verifyCode(code: code);
      emit(CodeVerifiedSuccess());
    } catch (e) {
      emit(ForgotPasswordError('Invalid code. Please try again.'));
    }
  }

  Future<void> resetPassword({required String newPassword}) async {
    emit(ForgotPasswordLoading());
    try {
      await _repo.resetPassword(newPassword: newPassword);
      emit(ResetSuccess());
    } catch (e) {
      emit(ForgotPasswordError('Failed to reset password. Please try again.'));
    }
  }

  void resetState() => emit(ForgotPasswordInitial());
}
