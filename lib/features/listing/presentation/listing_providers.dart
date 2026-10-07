import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/providers.dart';
import '../data/listing_remote_datasource.dart';
import '../domain/models/category.dart';
import '../domain/models/listing.dart';

/// ===== Datasource =====

final listingDatasourceProvider = Provider<ListingRemoteDatasource>(
  (ref) => ListingRemoteDatasource(ref.watch(dioProvider)),
);

/// ===== Kategori =====

final categoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  return ref.watch(listingDatasourceProvider).categories();
});

/// ===== Home: feed "rekomendasi" (listing aktif terbaru) =====

final homeFeedProvider = FutureProvider.autoDispose<List<Listing>>((ref) async {
  final r = await ref
      .watch(listingDatasourceProvider)
      .list(limit: 12, sort: 'newest', status: 'ACTIVE');
  return r.items;
});

/// ===== Explore: filter + hasil pencarian =====

class ExploreFilter {
  const ExploreFilter({
    this.search = '',
    this.categoryId,
    this.type,
    this.sort = 'newest',
  });

  final String search;
  final String? categoryId;
  final String? type;
  final String sort;

  bool get hasActiveFilter =>
      search.isNotEmpty || categoryId != null || type != null;

  ExploreFilter copyWith({
    String? search,
    Object? categoryId = _sentinel,
    Object? type = _sentinel,
    String? sort,
  }) =>
      ExploreFilter(
        search: search ?? this.search,
        categoryId: categoryId == _sentinel
            ? this.categoryId
            : categoryId as String?,
        type: type == _sentinel ? this.type : type as String?,
        sort: sort ?? this.sort,
      );

  static const _sentinel = Object();
}

class ExploreController
    extends AutoDisposeAsyncNotifier<List<Listing>> {
  @override
  Future<List<Listing>> build() async {
    final f = ref.watch(exploreFilterProvider);
    final r = await ref.watch(listingDatasourceProvider).list(
          search: f.search.isEmpty ? null : f.search,
          category: f.categoryId,
          type: f.type,
          sort: f.sort,
          limit: 30,
          status: 'ACTIVE',
        );
    return r.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Listing>>().copyWithPrevious(state);
    ref.invalidateSelf();
  }
}

final exploreFilterProvider = StateProvider<ExploreFilter>(
  (ref) => const ExploreFilter(),
);

final exploreControllerProvider = AutoDisposeAsyncNotifierProvider<
    ExploreController, List<Listing>>(ExploreController.new);

/// ===== Detail listing =====

final listingDetailProvider = FutureProvider.autoDispose
    .family<Listing, String>((ref, id) {
  return ref.watch(listingDatasourceProvider).getById(id);
});

/// ===== Listing milik sendiri (tab Me) =====

final myListingsProvider = FutureProvider.autoDispose<List<Listing>>(
  (ref) async {
    final me = ref.watch(authControllerProvider).valueOrNull;
    final userId = me?.user?.id;
    if (userId == null) return const [];
    final r = await ref
        .watch(listingDatasourceProvider)
        .list(sellerId: userId, limit: 50, sort: 'newest');
    return r.items;
  },
);

/// Buat listing baru (dipakai SellPage) — refresh feed setelah sukses.
Future<Listing> createListing(
  WidgetRef ref, {
  required String title,
  required num price,
  String? description,
  String? categoryId,
  String type = 'PRODUCT',
  String? condition,
  String? meetupLocation,
}) async {
  try {
    final listing = await ref.read(listingDatasourceProvider).create(
          title: title,
          price: price,
          description: description,
          categoryId: categoryId,
          type: type,
          condition: condition,
          meetupLocation: meetupLocation,
        );
    ref.invalidate(homeFeedProvider);
    ref.invalidate(myListingsProvider);
    ref.invalidate(exploreControllerProvider);
    return listing;
  } on ApiException {
    rethrow;
  }
}

/// Ubah status / arsipkan listing milik sendiri.
Future<Listing> updateListing(
  WidgetRef ref,
  String id, {
  String? status,
  num? price,
  String? title,
  String? description,
  String? meetupLocation,
  String? condition,
}) async {
  final listing = await ref.read(listingDatasourceProvider).update(
        id,
        status: status,
        price: price,
        title: title,
        description: description,
        meetupLocation: meetupLocation,
        condition: condition,
      );
  ref.invalidate(homeFeedProvider);
  ref.invalidate(myListingsProvider);
  ref.invalidate(exploreControllerProvider);
  ref.invalidate(listingDetailProvider(id));
  return listing;
}

Future<void> archiveListing(WidgetRef ref, String id) async {
  await ref.read(listingDatasourceProvider).archive(id);
  ref.invalidate(homeFeedProvider);
  ref.invalidate(myListingsProvider);
  ref.invalidate(exploreControllerProvider);
  ref.invalidate(listingDetailProvider(id));
}
