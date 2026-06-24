import 'package:flutter/material.dart';
import 'package:swaply/features/sessions/data/models/session_model.dart';
import 'package:swaply/features/sessions/presentation/widgets/session_card.dart';
import 'package:swaply/core/constants/app_colors.dart';

// ─────────────────────────────────────────
//  Mock Data
// ─────────────────────────────────────────

final _myRequests = [
  SessionItem(
    id: 's1',
    studentId: 'u_me',
    teacherId: 'u_sarah',
    studentName: 'Me',
    teacherName: 'Sarah Chen',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'UI/UX Design',
    scheduledAt: DateTime(2024, 4, 25, 16, 0),
    durationMinutes: 60,
    points: 60,
    status: SessionStatus.accepted,
    message: null,
    createdAt: DateTime(2024, 4, 20),
    isOutgoing: true,
  ),
  SessionItem(
    id: 's2',
    studentId: 'u_me',
    teacherId: 'u_maria',
    studentName: 'Me',
    teacherName: 'Maria Lopez',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'Spanish Tutoring',
    scheduledAt: DateTime(2024, 4, 26, 10, 0),
    durationMinutes: 45,
    points: 30,
    status: SessionStatus.pending,
    message: 'Hi! I would love to practice conversational Spanish.',
    createdAt: DateTime(2024, 4, 21),
    isOutgoing: true,
  ),
  SessionItem(
    id: 's3',
    studentId: 'u_me',
    teacherId: 'u_priya',
    studentName: 'Me',
    teacherName: 'Priya Patel',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'Yoga & Meditation',
    scheduledAt: DateTime(2024, 4, 23, 9, 0),
    durationMinutes: 30,
    points: 22,
    status: SessionStatus.rejected,
    message: null,
    createdAt: DateTime(2024, 4, 22),
    isOutgoing: true,
  ),
  SessionItem(
    id: 's4',
    studentId: 'u_me',
    teacherId: 'u_james',
    studentName: 'Me',
    teacherName: 'James Wilson',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'Flutter & Mobile',
    scheduledAt: DateTime(2024, 4, 18, 14, 30),
    durationMinutes: 60,
    points: 75,
    status: SessionStatus.completed,
    message: 'Looking to learn state management basics.',
    createdAt: DateTime(2024, 4, 10),
    isOutgoing: true,
  ),
];

final _incoming = [
  SessionItem(
    id: 's5',
    studentId: 'u_emma',
    teacherId: 'u_me',
    studentName: 'Emma Richardson',
    teacherName: 'Me',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'Figma Basics',
    scheduledAt: DateTime(2024, 4, 24, 17, 0),
    durationMinutes: 60,
    points: 35,
    status: SessionStatus.accepted,
    message: 'I want to learn the basics of Figma for my design class.',
    createdAt: DateTime(2024, 4, 18),
    isOutgoing: false,
  ),
  SessionItem(
    id: 's6',
    studentId: 'u_david',
    teacherId: 'u_me',
    studentName: 'David Park',
    teacherName: 'Me',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'Design Systems',
    scheduledAt: DateTime(2024, 4, 27, 11, 0),
    durationMinutes: 90,
    points: 53,
    status: SessionStatus.pending,
    message: 'Interested in learning how to build a scalable design system.',
    createdAt: DateTime(2024, 4, 22),
    isOutgoing: false,
  ),
  SessionItem(
    id: 's7',
    studentId: 'u_rachel',
    teacherId: 'u_me',
    studentName: 'Rachel Kim',
    teacherName: 'Me',
    studentAvatar: '',
    teacherAvatar: '',
    skill: 'UI Design Intro',
    scheduledAt: DateTime(2024, 4, 15, 15, 0),
    durationMinutes: 60,
    points: 35,
    status: SessionStatus.completed,
    message: null,
    createdAt: DateTime(2024, 4, 8),
    isOutgoing: false,
  ),
];
// ─────────────────────────────────────────
//  SessionsScreen
// ─────────────────────────────────────────

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
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + Tab Bar ─────────────────
            Container(
              color: Colors.white,
              width: double.infinity, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage skill swap requests sent to and from you.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  TabBar(
                    controller: _tab,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.muted,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2,
                    dividerColor: AppColors.border,
                    tabs: const [
                      Tab(text: 'Incoming Requests'),
                      Tab(text: 'My Requests'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab Views ───────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _SessionList(sessions: _incoming),
                  _SessionList(sessions: _myRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Session List
// ─────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final List<SessionItem> sessions;
  const _SessionList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => SessionCard(session: sessions[i]),
    );
  }
}
