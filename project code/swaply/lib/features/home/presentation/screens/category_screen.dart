import 'package:flutter/material.dart';
import 'package:swaply/features/search/presentation/screens/search_screen.dart';
import 'package:swaply/l10n/app_localizations.dart';
import '../../data/models/category_model.dart';

class CategoryTab extends StatelessWidget {
  final List<CategoryModel> categories;
  const CategoryTab({super.key, required this.categories});

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

  // 1. عملنا دالة ذكية بتجيب الأيقونة الصح بناءً على الاسم من غير ما نلمس الـ Model
  IconData _getIconForCategory(String name) {
    final normalized = name.trim().toLowerCase();
    switch (normalized) {
      case 'programming':
        return Icons.code_rounded;
      case 'design':
        return Icons.palette_outlined;
      case 'languages':
        return Icons.language_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'business':
        return Icons.business_center_outlined;
      case 'fitness & wellness':
        return Icons.self_improvement_rounded;
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'cooking':
        return Icons.restaurant_outlined;
      default:
        return Icons.category_outlined; // أيقونة احتياطية لو الاسم مش متطابق
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Categories count: ${categories.length}");

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final category = categories[i];
        final color =
            _colors[i % _colors.length]; // الألوان عادي تفضل عشوائية ومبهجة

        // 2. هنا نادينا الدالة وباصينا اسم الكاتيجوري عشان نضمن الأيقونة الصح
        final icon = _getIconForCategory(category.name);

        return _CategoryCard(
          category: category,
          color: color,
          icon: icon, // هتروح للكارت مظبوطة 100%
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

  // ✅ يفتح SearchScreen ومعاه اسم الكاتيجوري كـ initialQuery
  //    فبيدور تلقائياً على المينتورز اللي بيدرّسوا السكيل ده بس
  void _openSearchWithCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: category.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSearchWithCategory(context),
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
              Positioned(
                top: 0,
                bottom: 0,
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
                        AppLocalizations.of(
                          context,
                        )!.mentorsCount(category.count),
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
