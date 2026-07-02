import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swaply/features/user/data/models/user_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/category_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;

  // TODO: inject the real UserCubit/AuthCubit here once its shape is
  // confirmed — getRecommendedMentors needs the current user's UserModel
  // (specifically skillsWantsToLearn) to rank matches. Left as a required
  // constructor param for now so this won't compile silently wrong; wire
  // it to wherever the app's current-user cubit actually lives.
  final UserModel currentUser;

  HomeCubit(this._repo, {required this.currentUser}) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    try {
      final results = await Future.wait([
        _repo.getTopMentors(currentUser),
        _repo.getRecommendedMentors(currentUser),
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
