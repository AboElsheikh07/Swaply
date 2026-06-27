import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';
import 'package:swaply/features/sessions/presentation/widgets/session_card.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    context.read<SessionsCubit>().loadSessions();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + Tab Bar ──────────────
            Container(
              color: Theme.of(context).cardColor,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessions',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage skill swap requests sent to and from you.',
                          style: TextStyle(fontSize: 13, color: colors.muted),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tab,
                    labelColor: colors.primary,
                    unselectedLabelColor: colors.muted,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorColor: colors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2,
                    dividerColor: colors.border,
                    tabs: const [
                      Tab(text: 'Incoming Requests'),
                      Tab(text: 'My Requests'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab Views ─────────────────────
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                builder: (context, state) {
                  if (state is SessionsLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    );
                  }

                  if (state is SessionsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: colors.rose),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.muted, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () =>
                                context.read<SessionsCubit>().loadSessions(),
                            child: Text(
                              'Try again',
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final incoming = state is SessionsLoaded
                      ? state.incoming
                      : state is SessionsActionLoading
                          ? state.incoming
                          : <SessionItem>[];

                  final myRequests = state is SessionsLoaded
                      ? state.myRequests
                      : state is SessionsActionLoading
                          ? state.myRequests
                          : <SessionItem>[];

                  return TabBarView(
                    controller: _tab,
                    children: [
                      _SessionList(sessions: incoming),
                      _SessionList(sessions: myRequests),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session List ──────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final List<SessionItem> sessions;
  const _SessionList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorTheme>()!;

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: colors.muted),
            const SizedBox(height: 12),
            Text(
              'No sessions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sessions will appear here once created.',
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => SessionCard(session: sessions[i]),
    );
  }
}