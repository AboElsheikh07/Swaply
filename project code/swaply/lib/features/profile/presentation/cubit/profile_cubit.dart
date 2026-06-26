import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial());

  void toggleDarkMode(bool value) {
    emit(state.copyWith(isDarkModeEnabled: value));
  }

  void updateProfile({required String name, required String email}) {
    emit(state.copyWith(name: name, email: email));
  }

  void addSkill(String skill) {
    if (skill.trim().isEmpty || state.offeredSkills.contains(skill.trim())) {
      return;
    }
    final updatedSkills = List<String>.from(state.offeredSkills)
      ..add(skill.trim());
    emit(state.copyWith(offeredSkills: updatedSkills));
  }

  void removeSkill(String skill) {
    final updatedSkills = List<String>.from(state.offeredSkills)..remove(skill);
    emit(state.copyWith(offeredSkills: updatedSkills));
  }

  void updateLanguage(String language) {
    emit(state.copyWith(language: language));
  }

  void topUpPoints(int amount) {
    if (amount <= 0) return;
    emit(state.copyWith(points: state.points + amount));
  }

  void withdrawPoints(int amount) {
    if (amount <= 0) return;
    final remaining = state.points - amount;
    emit(state.copyWith(points: remaining < 0 ? 0 : remaining));
  }
}
