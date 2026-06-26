import '../../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotifChannelModel> channels;
  final Map<String, bool> prefs;

  NotificationsLoaded({required this.channels, required this.prefs});

  NotificationsLoaded copyWith({Map<String, bool>? prefs}) {
    return NotificationsLoaded(
      channels: channels,
      prefs: prefs ?? this.prefs,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}
