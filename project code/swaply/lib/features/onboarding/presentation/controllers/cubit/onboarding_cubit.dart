import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/onboarding/data/data_sources/onboarding_remote_data_source.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRemoteDataSource _datasource;
  bool _isSaving = false;

  OnboardingCubit()
      : _datasource = OnboardingRemoteDataSourceImpl(),
        super(OnboardingInitial());

  Future<void> completeOnboarding({
    required List<String> teachSkills,
    required List<String> learnSkills,
    required int pricePerHour,
    File? profileImage,
  }) async {
    if (_isSaving) return;
    _isSaving = true;
    emit(OnboardingLoading());
    try {
      await _datasource.saveOnboarding(
        teachSkills: teachSkills,
        learnSkills: learnSkills,
        pricePerHour: pricePerHour,
        profileImage: profileImage,
      );
      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isSaving = false;
    }
  }

  void resetState() => emit(OnboardingInitial());
}
