import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/profile_local_data_source.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileLocalDataSource localDataSource;

  ProfileCubit(this.localDataSource, {bool initialDarkMode = false})
      : super(ProfileState.initial(isDarkMode: initialDarkMode));

  Future<void> loadSettings() async {
    final isDark = await localDataSource.getTheme();
    final language = await localDataSource.getLanguage();
    emit(state.copyWith(isDarkMode: isDark, language: language));
  }

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    emit(state.copyWith(isDarkMode: newValue));
    localDataSource.saveTheme(newValue);
  }

  void updateLanguage(String language) {
    emit(state.copyWith(language: language));
    localDataSource.saveLanguage(language);
  }
}