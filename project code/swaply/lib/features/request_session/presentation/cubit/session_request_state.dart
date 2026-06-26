abstract class SessionRequestState {}

class SessionRequestInitial extends SessionRequestState {}

class SessionRequestLoading extends SessionRequestState {}

class SessionRequestSuccess extends SessionRequestState {}

class SessionRequestError extends SessionRequestState {
  final String message;
  SessionRequestError(this.message);
}
