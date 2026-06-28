import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swaply/features/onboarding/data/data_sources/helper.dart';

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

  OnboardingRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  @override
  Future<void> saveOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // ── Upload image to Cloudinary ────────────
    String? avatarUrl;
    if (profileImage != null) {
      avatarUrl = await CloudinaryService.uploadAvatar(
        profileImage,
        user.uid,
      );
    }

    // ── Save to Firestore ─────────────────────
    await _db.collection('users').doc(user.uid).set({
      'skillsCanTeach':     teachSkills,
      'skillsWantsToLearn': learnSkills,
      'pricePerHour':       pricePerHour,
      'isPublic':           teachSkills.isNotEmpty,
      'onboardingComplete': true,
      'avatarUrl': ?avatarUrl,
      'updatedAt':          FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}