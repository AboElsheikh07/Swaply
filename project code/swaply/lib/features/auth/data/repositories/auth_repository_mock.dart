import 'auth_repository.dart';

// ✅ دي الـ mock - بتشيلها وتحط FirebaseAuthRepository لما تربط Firebase
class MockAuthRepository implements AuthRepository {
  @override
  Future<void> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network
    // لو عايز تعمل error للتجربة:
    // throw Exception('Invalid credentials');
  }

  @override
  Future<void> signup({required String name, required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<void> logout() async {}
}

// 🔥 لما Firebase يتجهز، اعمل الكلاس ده وبدّله في الـ cubit
// class FirebaseAuthRepository implements AuthRepository {
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   Future<void> login({required String email, required String password}) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }
//
//   @override
//   Future<void> signup({required String name, required String email, required String password}) async {
//     final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//     await cred.user?.updateDisplayName(name);
//   }
//
//   @override
//   Future<void> logout() async => await _auth.signOut();
// }
