import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swaply/features/user/data/models/user_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/category_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;

  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    try {
      final results = await Future.wait([
        _repo.getTopMentors(),
        _repo.getRecommendedMentors(),
        _repo.getCategories(),
      ]);

      emit(
        HomeLoaded(
          topMentors: results[0] as List<UserModel>,
          recommended: results[1] as List<UserModel>,
          categories: results[2] as List<CategoryModel>,
        ),
      );
    } catch (e) {
      emit(HomeError('Something went wrong. Please try again.'));
    }
  }

  Future<void> refresh() => loadHome();
}
