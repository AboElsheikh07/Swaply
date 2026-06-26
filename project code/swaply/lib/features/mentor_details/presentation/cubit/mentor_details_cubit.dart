import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/mentor_details_repository.dart';
import 'mentor_details_state.dart';

class MentorDetailsCubit extends Cubit<MentorDetailsState> {
  final MentorDetailsRepository _repo;

  MentorDetailsCubit(this._repo) : super(MentorDetailsInitial());

  Future<void> loadMentor({required String mentorId}) async {
    emit(MentorDetailsLoading());
    try {
      final results = await Future.wait([
        _repo.getMentorById(mentorId: mentorId),
        _repo.getMentorReviews(mentorId: mentorId),
      ]);
      emit(MentorDetailsLoaded(
        mentor:  results[0] as dynamic,
        reviews: results[1] as dynamic,
      ));
    } catch (e) {
      emit(MentorDetailsError('Failed to load mentor details.'));
    }
  }
}
