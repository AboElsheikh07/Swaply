import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repo;

  NotificationsCubit(this._repo) : super(NotificationsInitial());

  Future<void> loadChannels() async {
    emit(NotificationsLoading());
    try {
      final channels = await _repo.getChannels();
      final prefs = {
        for (final ch in channels)
          for (final p in ch.prefs) p.id: p.defaultVal,
      };
      emit(NotificationsLoaded(channels: channels, prefs: prefs));
    } catch (e) {
      emit(NotificationsError('Failed to load notification settings.'));
    }
  }

  Future<void> togglePref(String prefId) async {
    if (state is! NotificationsLoaded) return;
    final current = state as NotificationsLoaded;
    final newVal = !(current.prefs[prefId] ?? false);

    // Optimistic update - الـ UI بيتغير فوراً
    final newPrefs = Map<String, bool>.from(current.prefs)..[prefId] = newVal;
    emit(current.copyWith(prefs: newPrefs));

    try {
      await _repo.updatePref(prefId: prefId, value: newVal);
    } catch (e) {
      // لو فشل، رجّع القيمة القديمة
      emit(current);
    }
  }
}
