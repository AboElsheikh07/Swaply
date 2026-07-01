import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/widgets/session_card.dart';
import 'package:swaply/l10n/app_localizations.dart';

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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + Tab Bar ──────────────
            Container(
              color: colors.card,
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
                          AppLocalizations.of(context)!.sessions,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.manageSessionsDesc,
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
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.myRequests),
                      Tab(text: AppLocalizations.of(context)!.incomingRequests),
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
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colors.rose,
                          ),
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
                              AppLocalizations.of(context)!.tryAgain,
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
                      _GroupedSessionList(sessions: myRequests),
                      _GroupedSessionList(sessions: incoming),
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

// ─────────────────────────────────────────
//  Group enum
// ─────────────────────────────────────────

enum _Group { active, pending, completed, cancelled }

// ─────────────────────────────────────────
//  Grouped Session List
// ─────────────────────────────────────────

class _GroupedSessionList extends StatelessWidget {
  final List<SessionItem> sessions;
  const _GroupedSessionList({required this.sessions});

  static const _groupOrder = [
    _Group.active,
    _Group.pending,
    _Group.completed,
    _Group.cancelled,
    
  ];

  _Group _groupOf(SessionItem s) {
    switch (s.status) {
      case SessionStatus.accepted:
      case SessionStatus.ongoing:
        return _Group.active;
      case SessionStatus.pending:
        return _Group.pending;
      case SessionStatus.completed:
        return _Group.completed;
      case SessionStatus.rejected:
      case SessionStatus.cancelled:
        return _Group.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: colors.muted),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noSessionsYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.sessionsWillAppearHere,
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
          ],
        ),
      );
    }

    // Build map of group → sessions
    final Map<_Group, List<SessionItem>> grouped = {
      for (final g in _groupOrder) g: [],
    };
    for (final s in sessions) {
      grouped[_groupOf(s)]!.add(s);
    }

    // Flatten into a widget list: header + cards per non-empty group
    final List<Widget> items = [];
    for (final group in _groupOrder) {
      final list = grouped[group]!;
      if (list.isEmpty) continue;

      items.add(_GroupHeader(group: group));
      for (final session in list) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SessionCard(session: session),
          ),
        );
      }
      items.add(const SizedBox(height: 8));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: items,
    );
  }
}

// ─────────────────────────────────────────
//  Group Header
// ─────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final _Group group;
  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cfg = _config(group, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cfg.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cfg.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: colors.border, height: 1)),
        ],
      ),
    );
  }

  _Cfg _config(_Group g, AppColorTheme colors) {
    switch (g) {
      case _Group.active:
        return _Cfg(colors.green, 'ACTIVE');
      case _Group.pending:
        return _Cfg(colors.amber, 'PENDING');
      case _Group.completed:
        return _Cfg(colors.sky, 'COMPLETED');
      case _Group.cancelled:
        return _Cfg(colors.muted, 'CANCELLED & REJECTED');
    }
  }
}

class _Cfg {
  final Color color;
  final String label;
  const _Cfg(this.color, this.label);
}
