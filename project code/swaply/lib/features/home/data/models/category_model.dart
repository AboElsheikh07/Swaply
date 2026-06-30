class CategoryModel {
  final String id;
  final String name;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.count,
  });

  // لما تربط الFirebase
  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      count: data['count'] ?? 0,
    );
  }
}
