import 'dart:io';
import 'package:swaply/features/onboarding/data/data_sources/onboarding_remote_data_source.dart';


abstract class OnboardingRepository {
  Future<void> saveOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  });
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  const OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    await remoteDataSource.saveOnboarding(
      teachSkills: teachSkills,
      learnSkills: learnSkills,
      pricePerHour: pricePerHour,
      profileImage: profileImage,
    );
  }
}