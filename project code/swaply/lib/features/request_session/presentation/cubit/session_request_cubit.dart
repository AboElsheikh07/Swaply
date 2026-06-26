import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/session_request_model.dart';
import '../../data/repositories/session_request_repository.dart';
import 'session_request_state.dart';

class SessionRequestCubit extends Cubit<SessionRequestState> {
  final SessionRequestRepository _repo;

  SessionRequestCubit(this._repo) : super(SessionRequestInitial());

  Future<void> sendRequest({required SessionRequestModel request}) async {
    emit(SessionRequestLoading());
    try {
      await _repo.sendRequest(request: request);
      emit(SessionRequestSuccess());
    } catch (e) {
      emit(SessionRequestError('Failed to send request. Please try again.'));
    }
  }

  void resetState() => emit(SessionRequestInitial());
}
