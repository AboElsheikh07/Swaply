import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/profile_local_data_source.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileLocalDataSource localDataSource;

  ProfileCubit(this.localDataSource, {bool initialDarkMode = false}) 
      : super(ProfileState.initial(isDarkMode: initialDarkMode));

  Future<void> loadData() async {
    final skills = await localDataSource.getSkills();
    final isDark = await localDataSource.getTheme();
    final imagePath = await localDataSource.getProfileImage();
    emit(state.copyWith(
      offeredSkills: skills.isNotEmpty ? skills : state.offeredSkills,
      isDarkMode: isDark,
      profileImagePath: imagePath,
    ));
  }

  
  void updateProfileImage(String path) {
    emit(state.copyWith(profileImagePath: path));
    localDataSource.saveProfileImage(path);
  }

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    emit(state.copyWith(isDarkMode: newValue));
    localDataSource.saveTheme(newValue);
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
    localDataSource.saveSkills(updatedSkills);
  }

  void removeSkill(String skill) {
    final updatedSkills = List<String>.from(state.offeredSkills)..remove(skill);
    emit(state.copyWith(offeredSkills: updatedSkills));
    localDataSource.saveSkills(updatedSkills);
  }

  void removeSkillAt(int index) {
    if (index < 0 || index >= state.offeredSkills.length) return;
    final updatedSkills = List<String>.from(state.offeredSkills)..removeAt(index);
    emit(state.copyWith(offeredSkills: updatedSkills));
    localDataSource.saveSkills(updatedSkills);
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
