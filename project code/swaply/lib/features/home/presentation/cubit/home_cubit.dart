import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;

  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      // بنجيب الـ 3 calls مع بعض بدل ما نستنى واحدة ورا التانية
      final results = await Future.wait([
        _repo.getTopMentors(),
        _repo.getRecommendedMentors(),
        _repo.getCategories(),
      ]);

      emit(HomeLoaded(
        topMentors:  results[0] as dynamic,
        recommended: results[1] as dynamic,
        categories:  results[2] as dynamic,
      ));
    } catch (e) {
      emit(HomeError('Something went wrong. Please try again.'));
    }
  }

  Future<void> refresh() => loadHome();
}
