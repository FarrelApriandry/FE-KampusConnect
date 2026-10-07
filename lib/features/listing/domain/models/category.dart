/// Kategori listing — GET /api/v1/categories.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.type,
  });

  final String id;
  final String name;
  final String? type;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString(),
      );
}
