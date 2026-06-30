import 'package:flutter/material.dart';
import 'package:swaply/l10n/app_localizations.dart';
import '../../data/models/category_model.dart';

class CategoryTab extends StatelessWidget {
  final List<CategoryModel> categories;
  const CategoryTab({super.key, required this.categories});

  static const _colors = [
    Color(0xFF5B4CB8), Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFF6A1B9A),
    Color(0xFF00838F), Color(0xFFE65100), Color(0xFFC62828), Color(0xFF4E342E),
  ];

  static const _icons = [
    Icons.palette_outlined,       Icons.code_rounded,
    Icons.language_rounded,       Icons.music_note_rounded,
    Icons.self_improvement_rounded, Icons.business_center_outlined,
    Icons.camera_alt_outlined,    Icons.restaurant_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final color = _colors[i % _colors.length];
        final icon  = _icons[i % _icons.length];
        return _CategoryCard(
          category: categories[i],
          color: color,
          icon: icon,
          reverse: i.isOdd,
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Color color;
  final IconData icon;
  final bool reverse;

  const _CategoryCard({
    required this.category,
    required this.color,
    required this.icon,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                top: 0, bottom: 0,
                left: reverse ? 0 : null,
                right: reverse ? null : 0,
                width: MediaQuery.of(context).size.width * 0.38,
                child: Container(
                  color: color.withOpacity(0.85),
                  child: Icon(icon, color: Colors.white54, size: 52),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
                      end:   reverse ? Alignment.centerLeft  : Alignment.centerRight,
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
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context)!.mentorsCount(category.count),
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, fontWeight: FontWeight.w500)),
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
