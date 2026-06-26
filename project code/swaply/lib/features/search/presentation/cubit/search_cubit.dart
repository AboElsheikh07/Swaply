import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/search_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repo;
  final List<String> _recentSearches = [];

  SearchCubit(this._repo) : super(SearchInitial());

  Future<void> loadPopularSkills() async {
    emit(SearchLoadingSkills());
    try {
      final skills = await _repo.getPopularSkills();
      emit(SearchIdle(popularSkills: skills, recentSearches: _recentSearches));
    } catch (e) {
      emit(SearchError('Failed to load skills.'));
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      loadPopularSkills();
      return;
    }
    emit(SearchLoading());
    try {
      final results = await _repo.searchMentors(query: q);
      emit(SearchLoaded(results: results, query: q));
    } catch (e) {
      emit(SearchError('Search failed. Please try again.'));
    }
  }

  void addRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty || _recentSearches.contains(q)) return;
    _recentSearches.insert(0, q);
    if (_recentSearches.length > 6) _recentSearches.removeLast();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    if (state is SearchIdle) {
      final s = state as SearchIdle;
      emit(SearchIdle(popularSkills: s.popularSkills, recentSearches: List.from(_recentSearches)));
    }
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    if (state is SearchIdle) {
      final s = state as SearchIdle;
      emit(SearchIdle(popularSkills: s.popularSkills, recentSearches: []));
    }
  }

  void clearSearch() => loadPopularSkills();
}
