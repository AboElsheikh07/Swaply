import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_sources/onboarding_remote_data_source.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  /// Default constructor wires up the real implementations automatically.
  OnboardingCubit()
      : _repository = OnboardingRepositoryImpl(
          remoteDataSource: OnboardingRemoteDataSourceImpl(),
        ),
        super(OnboardingInitial());

  /// Injected constructor — use this in tests or when providing deps manually.
  OnboardingCubit.withRepository(OnboardingRepository repository)
      : _repository = repository,
        super(OnboardingInitial());

  Future<void> completeOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    emit(OnboardingLoading());
    try {
      await _repository.saveOnboarding(
        teachSkills: teachSkills,
        learnSkills: learnSkills,
        pricePerHour: pricePerHour,
        profileImage: profileImage,
      );
      emit(OnboardingSuccess());
    } catch (_) {
      emit(OnboardingError('Failed to save profile. Please try again.'));
    }
  }

  void resetState() => emit(OnboardingInitial());
}