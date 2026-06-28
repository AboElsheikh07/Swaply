import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final uid = user.uid;

    // تحويل الصورة لـ Base64 لو موجودة
    String? base64Image;
    if (profileImage != null) {
      final bytes = await profileImage.readAsBytes();
      base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }

    await _db.collection('users').doc(uid).set({
      'teachSkills':      teachSkills,
      'learnSkills':      learnSkills,
      'pricePerHour':     pricePerHour,
      'isPublic':         teachSkills.isNotEmpty,
      'onboardingDone':   true,
      if (base64Image != null) 'avatarBase64': base64Image,
      'updatedAt':        FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
