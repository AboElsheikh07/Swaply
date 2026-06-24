import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:equatable/equatable.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();
 
  @override
  List<Object?> get props => [];
}
 
/// Initial — nothing loaded yet
class SessionsInitial extends SessionsState {
  const SessionsInitial();
}
 
/// Loading sessions from backend
class SessionsLoading extends SessionsState {
  const SessionsLoading();
}
 
/// Sessions loaded successfully
class SessionsLoaded extends SessionsState {
  final List<SessionItem> incoming;
  final List<SessionItem> myRequests;
 
  const SessionsLoaded({
    required this.incoming,
    required this.myRequests,
  });
 
  /// Used to update one list without touching the other
  SessionsLoaded copyWith({
    List<SessionItem>? incoming,
    List<SessionItem>? myRequests,
  }) {
    return SessionsLoaded(
      incoming: incoming ?? this.incoming,
      myRequests: myRequests ?? this.myRequests,
    );
  }
 
  @override
  List<Object?> get props => [incoming, myRequests];
}
 
/// Something went wrong
class SessionsError extends SessionsState {
  final String message;
 
  const SessionsError(this.message);
 
  @override
  List<Object?> get props => [message];
}
 
/// Action in progress (accept / decline / request)
class SessionsActionLoading extends SessionsState {
  final List<SessionItem> incoming;
  final List<SessionItem> myRequests;
 
  const SessionsActionLoading({
    required this.incoming,
    required this.myRequests,
  });
 
  @override
  List<Object?> get props => [incoming, myRequests];
}
 
/// Request sent successfully
class SessionRequestSuccess extends SessionsState {
  const SessionRequestSuccess();
}
 