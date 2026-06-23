import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/mentor_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/home_repository_mock.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'category_screen.dart';

// ── Colors ──────────────────────────────
const _primary     = Color(0xFF5B4CB8);
const _primarySoft = Color(0xFFEEECFB);
const _mutedFg     = Color(0xFF8A8A9A);
const _border      = Color(0xFFEAEAF0);
const _dark        = Color(0xFF1A1A2E);

// ════════════════════════════════════════
//  Entry point - يحقن الـ Cubit
// ════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ بدّل MockHomeRepository بـ FirebaseHomeRepository لما Auth يخلص
      create: (_) => HomeCubit(MockHomeRepository())..loadHome(),
      child: const _HomeView(),
    );
  }
}

// ════════════════════════════════════════
//  View
// ════════════════════════════════════════
class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Column(
              children: [
                _Header(state: state),
                _buildTabBar(),
                Expanded(
                  child: switch (state) {
                    HomeLoading() => const Center(
                        child: CircularProgressIndicator(color: _primary),
                      ),
                    HomeError(:final message) => _ErrorView(
                        message: message,
                        onRetry: () => context.read<HomeCubit>().refresh(),
                      ),
                    HomeLoaded(:final topMentors, :final recommended, :final categories) =>
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _HomeTab(topMentors: topMentors, recommended: recommended),
                          CategoryTab(categories: categories),
                        ],
                      ),
                    _ => const SizedBox(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _primary,
        unselectedLabelColor: _mutedFg,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        indicatorColor: _primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerColor: _border,
        tabs: const [Tab(text: 'Home'), Tab(text: 'Category')],
      ),
    );
  }
}

// ── Header ──────────────────────────────
class _Header extends StatelessWidget {
  final HomeState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _primarySoft,
            child: const Icon(CupertinoIcons.person_fill, color: _primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ لما Auth يخلص، استبدل النص ده بـ user.displayName
                const Text('Hi, Jonathan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text("Let's learn something today",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          _IconBtn(icon: CupertinoIcons.search, onTap: () {}),
          const SizedBox(width: 8),
          _IconBtn(icon: CupertinoIcons.bell, onTap: () {}, badge: true),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: _dark),
            if (badge)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  Home Tab
// ════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  final List<MentorModel> topMentors;
  final List<MentorModel> recommended;
  const _HomeTab({required this.topMentors, required this.recommended});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _pageCtrl = PageController();
  int _slide = 0;

  static const _promos = [
    ('Earn 50 pts when you teach your first skill', 'Start teaching today'),
    ('New mentors this week', '20+ designers & devs joined'),
    ('Invite a friend', 'Get 100 bonus points'),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _primary,
      onRefresh: () => context.read<HomeCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        children: [
          // ── Promo Carousel ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _promos.length,
                      onPageChanged: (i) => setState(() => _slide = i),
                      itemBuilder: (_, i) => _PromoCard(
                        title: _promos[i].$1,
                        subtitle: _promos[i].$2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _promos.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _slide == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _slide == i ? _dark : _border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Top Mentors ──
          _SectionHeader(title: 'Top Mentors', icon: Icons.local_fire_department_rounded, onSeeAll: () {}),
          const SizedBox(height: 12),
          _MentorGrid(mentors: widget.topMentors),
          const SizedBox(height: 24),

          // ── Just For You ──
          _SectionHeader(title: 'Just for you', onSeeAll: () {}),
          const SizedBox(height: 12),
          _MentorGrid(mentors: widget.recommended),
        ],
      ),
    );
  }
}

// ── Section Header ───────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, this.icon, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (icon != null) ...[
            const SizedBox(width: 6),
            Icon(icon, color: Colors.orange, size: 18),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
          ),
        ],
      ),
    );
  }
}

// ── Mentor Grid ──────────────────────────
class _MentorGrid extends StatelessWidget {
  final List<MentorModel> mentors;
  const _MentorGrid({required this.mentors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mentors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, i) => _MentorCard(mentor: mentors[i]),
      ),
    );
  }
}

// ── Promo Card ───────────────────────────
class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PromoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _primarySoft,
      child: Stack(
        children: [
          Positioned(
            left: -30, top: -40,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.3)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444466))),
                      const SizedBox(height: 6),
                      const Text('By Swaply',
                          style: TextStyle(fontSize: 11, color: _mutedFg)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(CupertinoIcons.gift_fill, color: _primary, size: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mentor Card ──────────────────────────
class _MentorCard extends StatelessWidget {
  final MentorModel mentor;
  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      width: double.infinity,
                      color: _primarySoft,
                      // ✅ لما يكون عندك imageUrl:
                      // child: mentor.imageUrl != null
                      //     ? Image.network(mentor.imageUrl!, fit: BoxFit.cover)
                      //     : Icon(...)
                      child: const Icon(CupertinoIcons.person_fill, color: _primary, size: 48),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mentor.online ? const Color(0xFF2ECC71) : const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor.online ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: mentor.online ? const Color(0xFF27AE60) : const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(mentor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
                      const SizedBox(width: 2),
                      Text(mentor.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(mentor.skill,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: _mutedFg)),
                  const SizedBox(height: 4),
                  Text(mentor.rate,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ───────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: _mutedFg, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _mutedFg)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
