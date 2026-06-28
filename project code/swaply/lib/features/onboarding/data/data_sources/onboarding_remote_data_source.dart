import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

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
    final userDoc = _db.collection('users').doc(uid);

    // 1. Upload avatar to Firebase Storage if provided
    String? photoUrl;
    if (profileImage != null) {
      final ref = _storage.ref('avatars/$uid.jpg');
      await ref.putFile(profileImage);
      photoUrl = await ref.getDownloadURL();

      // Keep Firebase Auth's profile photo in sync too — separate source of
      // truth (Auth) from the app's own (Firestore via UserModel) on purpose.
      await _auth.currentUser!.updatePhotoURL(photoUrl);
    }

    // 2. Load the current user doc so we don't clobber fields onboarding
    //    doesn't touch (e.g. balance). Falls back to UserModel.empty() if
    //    the doc doesn't exist yet for some reason.
    final snapshot = await userDoc.get();
    final currentUser = snapshot.exists
        ? UserModel.fromFirestore(snapshot)
        : UserModel.empty().copyWith(id: uid);

    // 3. Apply onboarding answers through copyWith — never build a raw map.
    final updatedUser = currentUser.copyWith(
      skillsCanTeach:     teachSkills,
      skillsWantsToLearn: learnSkills,
      pricePerHour:       pricePerHour,
      avatarUrl:          photoUrl ?? currentUser.avatarUrl,
      onboardingComplete: true,
      isPublic:           teachSkills.isNotEmpty,
    );

    // 4. Single source of truth for the Firestore shape: toFirestore().
    await userDoc.set(updatedUser.toFirestore(), SetOptions(merge: true));
  }
}