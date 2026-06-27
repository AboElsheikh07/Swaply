import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class OnboardingRemoteDataSource {
  Future<void> saveOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  OnboardingRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> saveOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    final uid = _auth.currentUser!.uid;

    // 1. Upload avatar to Firebase Storage if provided
    String? photoUrl;
    if (profileImage != null) {
      final ref = _storage.ref('avatars/$uid.jpg');
      await ref.putFile(profileImage);
      photoUrl = await ref.getDownloadURL();

      // Keep Firebase Auth profile in sync
      await _auth.currentUser!.updatePhotoURL(photoUrl);
    }

    // 2. Write directly into the existing UserModel fields in Firestore
    await _db.collection('users').doc(uid).update({
      'teachSkills': teachSkills,
      'learnSkills': learnSkills,
      'pricePerHour': pricePerHour,
      'isPublic': teachSkills.isNotEmpty,
      'onboardingDone': true,
      if (photoUrl != null) 'avatarUrl': photoUrl,
    });
  }
}