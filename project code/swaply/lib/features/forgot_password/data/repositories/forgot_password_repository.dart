abstract class ForgotPasswordRepository {
  Future<void> sendCode({required String email});
  Future<void> verifyCode({required String code});
  Future<void> resetPassword({required String newPassword});
}
