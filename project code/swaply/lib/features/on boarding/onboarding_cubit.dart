import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final _auth    = FirebaseAuth.instance;
  final _db      = FirebaseFirestore.instance;

  OnboardingCubit() : super(OnboardingInitial());

  Future<void> completeOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    emit(OnboardingLoading());
    try {
      final uid = _auth.currentUser!.uid;
      String? photoUrl;

      // 1. رفع الصورة لـ Firebase Storage لو موجودة
      // if (profileImage != null) {
      //   // final ref = _storage.ref('avatars/$uid.jpg');
      //   await ref.putFile(profileImage);
      //   photoUrl = await ref.getDownloadURL();

      //   // حدّث الـ Firebase Auth profile برضو
      //   await _auth.currentUser!.updatePhotoURL(photoUrl);
      // }

      // 2. حدّث الـ Firestore user doc
      await _db.collection('users').doc(uid).update({
        'teachSkills':    teachSkills,
        'learnSkills':    learnSkills,
        'pricePerHour':   pricePerHour,
        'isPublic':       teachSkills.isNotEmpty,
        'onboardingDone': true,
        if (photoUrl != null) 'avatarUrl': photoUrl,
      });

      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError('Failed to save profile. Please try again.'));
    }
  }

  void resetState() => emit(OnboardingInitial());
}
