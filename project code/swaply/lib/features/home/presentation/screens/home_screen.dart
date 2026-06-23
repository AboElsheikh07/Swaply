import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────
//  Models
// ─────────────────────────────────────────

class Mentor {
  final String id;
  final String name;
  final String skill;
  final String rate;
  final double rating;
  final int reviews;
  final bool online;

  const Mentor({
    required this.id,
    required this.name,
    required this.skill,
    required this.rate,
    required this.rating,
    required this.reviews,
    this.online = false,
  });
}

class Category {
  final String id;
  final String name;
  final int count;

  const Category({required this.id, required this.name, required this.count});
}

class Promo {
  final String id;
  final String title;
  final String subtitle;
  final String vendor;

  const Promo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.vendor,
  });
}

// ─────────────────────────────────────────
//  Mock Data
// ─────────────────────────────────────────

const _mentors = [
  Mentor(
    id: 'm1',
    name: 'Sarah Chen',
    skill: 'UI/UX Design',
    rate: '60 pts/hr',
    rating: 4.9,
    reviews: 142,
    online: true,
  ),
  Mentor(
    id: 'm2',
    name: 'James Wilson',
    skill: 'Flutter & Mobile',
    rate: '75 pts/hr',
    rating: 4.8,
    reviews: 98,
    online: true,
  ),
  Mentor(
    id: 'm3',
    name: 'Maria Lopez',
    skill: 'Spanish Tutoring',
    rate: '40 pts/hr',
    rating: 5.0,
    reviews: 211,
  ),
  Mentor(
    id: 'm4',
    name: 'Derek Knight',
    skill: 'Guitar Lessons',
    rate: '50 pts/hr',
    rating: 4.7,
    reviews: 74,
  ),
  Mentor(
    id: 'm5',
    name: 'Priya Patel',
    skill: 'Yoga & Meditation',
    rate: '45 pts/hr',
    rating: 4.9,
    reviews: 163,
    online: true,
  ),
  Mentor(
    id: 'm6',
    name: 'Kenji Tanaka',
    skill: 'React & TypeScript',
    rate: '70 pts/hr',
    rating: 4.8,
    reviews: 119,
  ),
  Mentor(
    id: 'm7',
    name: 'Amelia Clarke',
    skill: 'Public Speaking',
    rate: '55 pts/hr',
    rating: 4.9,
    reviews: 88,
  ),
  Mentor(
    id: 'm8',
    name: 'Omar Haddad',
    skill: 'Photography',
    rate: '50 pts/hr',
    rating: 4.7,
    reviews: 66,
  ),
];

const _categories = [
  Category(id: 'c1', name: 'Design & Creative', count: 124),
  Category(id: 'c2', name: 'Development & Tech', count: 238),
  Category(id: 'c3', name: 'Languages', count: 86),
  Category(id: 'c4', name: 'Music & Audio', count: 54),
  Category(id: 'c5', name: 'Wellness & Fitness', count: 72),
  Category(id: 'c6', name: 'Business & Marketing', count: 91),
  Category(id: 'c7', name: 'Photography', count: 48),
  Category(id: 'c8', name: 'Cooking & Lifestyle', count: 63),
];

const _promos = [
  Promo(
    id: 'p1',
    title: 'Earn 50 pts when you teach your first skill',
    subtitle: 'Start teaching today',
    vendor: 'By Skill Swap',
  ),
  Promo(
    id: 'p2',
    title: 'New mentors this week',
    subtitle: '20+ designers & devs joined',
    vendor: 'By Skill Swap',
  ),
  Promo(
    id: 'p3',
    title: 'Invite a friend',
    subtitle: 'Get 100 bonus points',
    vendor: 'By Skill Swap',
  ),
];

// ─────────────────────────────────────────
//  Colors
// ─────────────────────────────────────────

// ─────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _TabBar(controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_HomeTab(), _CategoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Header
// ─────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySoft,
            child: const Icon(
              CupertinoIcons.person_fill,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Jonathan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Let's learn something today",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.mutedFg),
                ),
              ],
            ),
          ),
          // Search button
          _IconBtn(icon: CupertinoIcons.search, onTap: () {}),
          const SizedBox(width: 8),
          // Notifications button
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.dark),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  TabBar
// ─────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedFg,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerColor: AppColors.border,
        tabs: const [
          Tab(text: 'Home'),
          Tab(text: 'Category'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Home Tab
// ─────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _pageCtrl = PageController();
  int _slide = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                    itemBuilder: (_, i) => _PromoCard(promo: _promos[i]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Dots
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
                      color: _slide == i ? AppColors.dark : AppColors.border,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Top Mentors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.orange,
                size: 18,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, i) => _MentorCard(mentor: _mentors[i]),
          ),
        ),
        const SizedBox(height: 24),

        // ── Just For You ──
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Just for you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, i) => _MentorCard(mentor: _mentors[i + 4]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  Promo Card
// ─────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  final Promo promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEECFB),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            left: -30,
            top: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
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
                      Text(
                        promo.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF444466),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promo.vendor,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedFg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.gift_fill,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Mentor Card
// ─────────────────────────────────────────

class _MentorCard extends StatelessWidget {
  final Mentor mentor;
  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.primarySoft,
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                  // Online badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mentor.online
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor.online ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: mentor.online
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mentor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        mentor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mentor.skill,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedFg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mentor.rate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
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

// ─────────────────────────────────────────
//  Category Tab
// ─────────────────────────────────────────

class _CategoryTab extends StatelessWidget {
  const _CategoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _CategoryCard(category: _categories[i], reverse: i.isOdd),
    );
  }
}

// ─────────────────────────────────────────
//  Category Card
// ─────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final Category category;
  final bool reverse;
  const _CategoryCard({required this.category, this.reverse = false});

  // كل كاتيجوري بلون مختلف
  static const _colors = [
    Color(0xFF5B4CB8),
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFE65100),
    Color(0xFFC62828),
    Color(0xFF4E342E),
  ];

  static const _icons = [
    Icons.palette_outlined,
    Icons.code_rounded,
    Icons.language_rounded,
    Icons.music_note_rounded,
    Icons.self_improvement_rounded,
    Icons.business_center_outlined,
    Icons.camera_alt_outlined,
    Icons.restaurant_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final idx = _categories.indexOf(category) % _colors.length;
    final color = _colors[idx];

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Colored icon panel (image substitute)
              Positioned(
                top: 0,
                bottom: 0,
                left: reverse ? 0 : null,
                right: reverse ? null : 0,
                width: MediaQuery.of(context).size.width * 0.38,
                child: Container(
                  color: color.withOpacity(0.85),
                  child: Icon(_icons[idx], color: Colors.white54, size: 52),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: reverse
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: reverse
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      colors: [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF1A1A2E).withOpacity(0.88),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Text
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: reverse
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.count} mentors',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
