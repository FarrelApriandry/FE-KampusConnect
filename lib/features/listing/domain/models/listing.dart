import '../../../../core/utils/formatters.dart';

/// Model listing KampusConnect — snake_case dari backend (Postgres).
class ListingImage {
  const ListingImage({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String imageUrl;
  final int sortOrder;

  factory ListingImage.fromJson(Map<String, dynamic> json) => ListingImage(
        id: json['id']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        sortOrder: json['sort_order'] is num
            ? (json['sort_order'] as num).toInt()
            : 0,
      );
}

/// Ringkasan penjual pada detail listing.
class ListingSeller {
  const ListingSeller({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.verificationStatus = 'PENDING',
    this.trustScore,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String verificationStatus;
  final num? trustScore;

  bool get isVerified => verificationStatus == 'VERIFIED';

  factory ListingSeller.fromJson(Map<String, dynamic> json) => ListingSeller(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Mahasiswa',
        avatarUrl: json['avatar_url']?.toString(),
        verificationStatus:
            json['verification_status']?.toString() ?? 'PENDING',
        trustScore: json['trust_score'] is num
            ? json['trust_score'] as num
            : num.tryParse('${json['trust_score'] ?? ''}'),
      );
}

class Listing {
  const Listing({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.title,
    this.description,
    required this.price,
    this.type = 'PRODUCT',
    this.condition,
    this.meetupLocation,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
    this.images = const [],
    this.seller,
    this.isOwner = false,
  });

  final String id;
  final String sellerId;
  final String? categoryId;
  final String title;
  final String? description;
  final num price;
  final String type;
  final String? condition;
  final String? meetupLocation;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ListingImage> images;
  final ListingSeller? seller;
  final bool isOwner;

  bool get isActive => status == 'ACTIVE';
  bool get isService => type == 'SERVICE';

  String get priceText => formatIdr(price);

  /// Gambar sampul: sort_order 0, atau gambar pertama yang ada.
  String? get coverUrl {
    if (images.isEmpty) return null;
    for (final img in images) {
      if (img.sortOrder == 0) return img.imageUrl;
    }
    return images.first.imageUrl;
  }

  static const Map<String, String> conditionLabels = {
    'NEW': 'Baru',
    'USED_LIKE_NEW': 'Bekas · Seperti Baru',
    'USED_GOOD': 'Bekas · Baik',
    'USED_FAIR': 'Bekas · Layak Pakai',
    'FOR_PARTS': 'Untuk Spare Part',
    'NOT_APPLICABLE': 'Tidak Diterapkan',
  };

  static const Map<String, String> statusLabels = {
    'ACTIVE': 'Aktif',
    'RESERVED': 'Direservasi',
    'SOLD': 'Terjual',
    'ARCHIVED': 'Diarsipkan',
  };

  String get conditionLabel =>
      conditionLabels[condition] ?? condition ?? '-';
  String get statusLabel => statusLabels[status] ?? status;

  factory Listing.fromJson(Map<String, dynamic> json) {
    DateTime? date(String? v) => parseApiDate(v);
    num numOf(dynamic v) =>
        v is num ? v : (num.tryParse('${v ?? ''}') ?? 0);
    final imgs = (json['images'] as List?)
            ?.map((e) => ListingImage.fromJson(
                  (e as Map?)?.cast<String, dynamic>() ?? {},
                ))
            .toList() ??
        const <ListingImage>[];

    return Listing(
      id: json['id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      price: numOf(json['price']),
      type: json['type']?.toString() ?? 'PRODUCT',
      condition: json['condition']?.toString(),
      meetupLocation: json['meetup_location']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: date(json['created_at']?.toString()),
      updatedAt: date(json['updated_at']?.toString()),
      images: imgs,
      seller: json['seller'] is Map
          ? ListingSeller.fromJson(
              (json['seller'] as Map).cast<String, dynamic>())
          : null,
      isOwner: json['is_owner'] == true,
    );
  }
}
