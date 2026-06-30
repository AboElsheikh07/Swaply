import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/mentor_details/data/repositories/mentor_details_repository.dart';
import 'package:swaply/features/mentor_details/presentation/cubit/mentor_details_state.dart';

class MentorDetailsCubit extends Cubit<MentorDetailsState> {
  final MentorDetailsRepository repository;

  MentorDetailsCubit(this.repository) : super(MentorDetailsLoading());

  Future<void> loadMentor(String mentorId) async {
    emit(MentorDetailsLoading());

    try {
      final results = await Future.wait([
        repository.getMentor(mentorId),
        repository.getAvailability(mentorId), // ✅ بيانات حقيقية
      ]);

      emit(MentorDetailsLoaded(
        results[0] as dynamic,
        availability: results[1] as MentorAvailability,
      ));
    } catch (e) {
      emit(MentorDetailsError(e.toString()));
    }
  }
}
