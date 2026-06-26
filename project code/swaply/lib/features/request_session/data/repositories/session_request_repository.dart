import '../models/session_request_model.dart';

abstract class SessionRequestRepository {
  Future<void> sendRequest({required SessionRequestModel request});
}
