import 'forgot_password_repository.dart';

// ✅ بدّل بـ FirebaseForgotPasswordRepository لما Firebase يتجهز
class MockForgotPasswordRepository implements ForgotPasswordRepository {
  @override
  Future<void> sendCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<void> verifyCode({required String code}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code != '1234') throw Exception('Invalid code');
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

// 🔥 لما Firebase يتجهز
// class FirebaseForgotPasswordRepository implements ForgotPasswordRepository {
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   Future<void> sendCode({required String email}) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }
//
//   @override
//   Future<void> verifyCode({required String code}) async {
//     // verify OTP logic
//   }
//
//   @override
//   Future<void> resetPassword({required String newPassword}) async {
//     // confirm reset logic
//   }
// }
