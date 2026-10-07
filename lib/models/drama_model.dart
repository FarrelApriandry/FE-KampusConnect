class DramaModel {
  final int id;
  final String title;
  final int year;
  final double rating;
  final List<String> genres;
  final String status;
  final String cover; // <-- Field baru
  final String synopsis;

  DramaModel({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
    required this.status,
    required this.cover, // <-- Constructor
    required this.synopsis,
  });

  factory DramaModel.fromJson(Map<String, dynamic> json) {
    return DramaModel(
      id: json['id'],
      title: json['title'],
      year: json['year'],
      rating: (json['rating'] as num).toDouble(),
      genres: List<String>.from(json['genres']),
      status: json['status'],
      cover: json['cover'] ?? '', // <-- Parsing cover
      synopsis: json['synopsis'],
    );
  }
}
