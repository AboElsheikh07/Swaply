import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swaply/core/constants/firestore_keys.dart';
import 'package:swaply/features/auth/data/models/user_model.dart';

class FirebaseAuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Save user profile to Firestore
      await _db.collection(FirestoreKeys.users).doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'avatarUrl': '',
        'points': 0,
        'skills': [],
        FirestoreKeys.createdAt: FieldValue.serverTimestamp(),
      });

      // Update Firebase display name
      await credential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel> getCurrentUser() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _db.collection(FirestoreKeys.users).doc(uid).get();

    return UserModel.fromJson(doc.data()!);
  }

  // Turns Firebase error codes into readable messages
  String _mapError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Please enter a valid email.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'Check your internet connection.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
