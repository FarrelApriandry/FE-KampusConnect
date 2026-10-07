import '../../../../core/utils/formatters.dart';
import '../../../listing/domain/models/listing.dart';

/// Transaksi FR-09 — snake_case sesuai response backend.
class Transaction {
  const Transaction({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.agreedPrice,
    required this.status,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.buyer,
    this.seller,
    this.listing,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final num agreedPrice;
  final String status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final ListingSeller? buyer;
  final ListingSeller? seller;
  final Listing? listing;

  /// SDD §9 state machine: PENDING → ACCEPTED/REJECTED,
  /// ACCEPTED → COMPLETED/CANCELLED.
  static const Map<String, List<String>> allowedTransitions = {
    'PENDING': ['ACCEPTED', 'REJECTED'],
    'ACCEPTED': ['COMPLETED', 'CANCELLED'],
    'REJECTED': [],
    'COMPLETED': [],
    'CANCELLED': [],
  };

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isClosed =>
      status == 'COMPLETED' || status == 'CANCELLED' || status == 'REJECTED';

  String get agreedPriceText => formatIdr(agreedPrice);

  static const Map<String, String> statusLabels = {
    'PENDING': 'Menunggu Balasan',
    'ACCEPTED': 'Diterima',
    'REJECTED': 'Ditolak',
    'COMPLETED': 'Selesai',
    'CANCELLED': 'Dibatalkan',
  };

  String get statusLabel => statusLabels[status] ?? status;

  /// Saya pembeli pada transaksi ini? (bandingkan dengan id user login).
  bool involvesUser(String userId) =>
      buyerId == userId || sellerId == userId;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final listingJson = json['listing'];
    return Transaction(
      id: json['id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      agreedPrice: json['agreed_price'] is num
          ? json['agreed_price'] as num
          : (num.tryParse('${json['agreed_price'] ?? ''}') ?? 0),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: parseApiDate(json['created_at']?.toString()),
      acceptedAt: parseApiDate(json['accepted_at']?.toString()),
      completedAt: parseApiDate(json['completed_at']?.toString()),
      buyer: json['buyer'] is Map
          ? ListingSeller.fromJson(
              (json['buyer'] as Map).cast<String, dynamic>())
          : null,
      seller: json['seller'] is Map
          ? ListingSeller.fromJson(
              (json['seller'] as Map).cast<String, dynamic>())
          : null,
      listing: listingJson is Map
          ? Listing.fromJson(listingJson.cast<String, dynamic>())
          : null,
    );
  }
}
