import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swaply/core/constants/firestore_keys.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';

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

      await UserRepository().createUser(
        uid: credential.user!.uid,
        username: name, // from signup form
      );
      // Update Firebase display name
      await credential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser!;
    final uid = user.uid;

    final docRef = await _db.collection(FirestoreKeys.users).doc(uid).get();

    if (!docRef.exists) {
      // Profile doc doesn't exist yet — e.g. the signup Firestore write
      // hasn't landed before this ran, or the account was created outside
      // the normal signup flow. Create a baseline profile so the app has
      // something valid to load, instead of crashing on the null cast.
      await UserRepository().ensureUserExists(
        uid: uid,
        username: user.displayName ?? '',
      );
      final freshDoc = await _db.collection(FirestoreKeys.users).doc(uid).get();
      return UserModel.fromFirestore(freshDoc);
    }

    return UserModel.fromFirestore(docRef);
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