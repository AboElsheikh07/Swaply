import 'package:cloud_firestore/cloud_firestore.dart';

class SeedCategories {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;

    final snapshot = await db.collection('categories').get();

    // لو موجودة بالفعل متعملش حاجة
    if (snapshot.docs.isNotEmpty) return;

    final batch = db.batch();

    final categories = [
      {"name": "UI/UX Design", "count": 48},
      {"name": "Flutter", "count": 31},
      {"name": "Programming", "count": 55},
      {"name": "Languages", "count": 24},
      {"name": "Photography", "count": 19},
      {"name": "Business", "count": 14},
      {"name": "Music", "count": 27},
      {"name": "Cooking", "count": 11},
    ];

    for (final category in categories) {
      final doc = db.collection('categories').doc();

      batch.set(doc, category);
    }

    // await batch.commit();
  }
}