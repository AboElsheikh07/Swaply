import '../../data/models/search_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoadingSkills extends SearchState {}

class SearchIdle extends SearchState {
  final List<SkillModel> popularSkills;
  final List<String> recentSearches;
  SearchIdle({required this.popularSkills, required this.recentSearches});
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchMentorModel> results;
  final String query;
  SearchLoaded({required this.results, required this.query});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
