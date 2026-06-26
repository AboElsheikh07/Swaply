import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notifications_repository_mock.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

const notifPrimary = Color(0xFF5B4CB8);
const notifBorder  = Color(0xFFEAEAF0);
const notifMutedFg = Color(0xFF8A8A9A);

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ بدّل MockNotificationsRepository بـ FirebaseNotificationsRepository لما Firebase يتجهز
      create: (_) => NotificationsCubit(MockNotificationsRepository())..loadChannels(),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text('Notifications',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsLoading() => const Center(
                child: CircularProgressIndicator(color: notifPrimary)),
            NotificationsLoaded(:final channels, :final prefs) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: channels.map((ch) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ch.label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          letterSpacing: 0.8, color: notifMutedFg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: notifBorder),
                        ),
                        child: Column(
                          children: ch.prefs.asMap().entries.map((entry) {
                            final i = entry.key;
                            final p = entry.value;
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.label,
                                                style: const TextStyle(
                                                    fontSize: 14, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 2),
                                            Text(p.description,
                                                style: const TextStyle(
                                                    fontSize: 12, color: notifMutedFg)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      AppSwitch(
                                        value: prefs[p.id] ?? p.defaultVal,
                                        onChanged: (_) =>
                                            context.read<NotificationsCubit>().togglePref(p.id),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < ch.prefs.length - 1)
                                  const Divider(height: 1, color: notifBorder),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            NotificationsError(:final message) => Center(
                child: Text(message, style: const TextStyle(color: notifMutedFg))),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? notifPrimary : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
