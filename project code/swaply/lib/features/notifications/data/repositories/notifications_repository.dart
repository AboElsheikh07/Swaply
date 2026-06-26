import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotifChannelModel>> getChannels();
  Future<void> updatePref({required String prefId, required bool value});
}
