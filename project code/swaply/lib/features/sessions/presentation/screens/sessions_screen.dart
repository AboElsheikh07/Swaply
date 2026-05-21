import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sessions_controller.dart';
import '../widgets/session_card.dart';
import '../../../../core/constants/app_colors.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Sessions',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage skill swap requests sent to and from you.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),

            // ── Tab Bar ──────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Incoming Requests'),
                  Tab(text: 'My Requests'),
                ],
              ),
            ),

            // ── Tab Views ────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  // Incoming Requests (teacher)
                  _SessionList(
                    sessions: ctrl.incoming,
                    currentUid: ctrl.currentUid,
                    isIncoming: true,
                  ),
                  // My Requests (student)
                  _SessionList(
                    sessions: ctrl.myRequests,
                    currentUid: ctrl.currentUid,
                    isIncoming: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session list + empty state ───────────────────

class _SessionList extends StatelessWidget {
  final RxList sessions;
  final String currentUid;
  final bool isIncoming;

  const _SessionList({
    required this.sessions,
    required this.currentUid,
    required this.isIncoming,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = sessions;
      if (list.isEmpty) return _EmptyState(isIncoming: isIncoming);

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) =>
            SessionCard(session: list[i], currentUid: currentUid),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final bool isIncoming;
  const _EmptyState({required this.isIncoming});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncoming ? Icons.inbox_outlined : Icons.send_outlined,
              size: 36,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isIncoming
                  ? 'When students request a session with you, it will show up here.'
                  : 'Browse mentors and request your first session to see it here.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Get.toNamed(isIncoming ? '/profile' : '/home'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isIncoming ? 'Update your skills' : 'Find a mentor',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
