import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/listing_card.dart';
import '../../listing/domain/models/category.dart';
import '../../listing/presentation/listing_providers.dart';

/// Explore — pencarian + filter kategori/tipe + sort.
/// FR-06/FR-07: katalog & pencarian listing.
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(exploreFilterProvider);
    final cats = ref.watch(categoriesProvider);
    final results = ref.watch(exploreControllerProvider);
    final controller = TextEditingController(text: filter.search);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari listing…',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onSubmitted: (q) =>
              ref.read(exploreFilterProvider.notifier).state =
                  filter.copyWith(search: q.trim()),
        ),
        actions: [
          if (filter.hasActiveFilter)
            IconButton(
              tooltip: 'Reset filter',
              onPressed: () {
                ref.read(exploreFilterProvider.notifier).state =
                    const ExploreFilter();
                controller.clear();
              },
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          // Baris filter kategori.
          SizedBox(
            height: 44,
            child: cats.maybeWhen(
              data: (List<Category> list) {
                final chips = <Widget>[
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: filter.categoryId == null,
                    onSelected: (_) {
                      ref.read(exploreFilterProvider.notifier).state =
                          filter.copyWith(categoryId: null);
                    },
                  ),
                  for (final c in list)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: filter.categoryId == c.id,
                      onSelected: (_) {
                        ref.read(exploreFilterProvider.notifier).state =
                            filter.copyWith(categoryId: c.id);
                      },
                    ),
                ];
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final w in chips)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: w,
                      ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Tipe + sort.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('Semua')),
                      ButtonSegment(value: 'PRODUCT', label: Text('Barang')),
                      ButtonSegment(value: 'SERVICE', label: Text('Jasa')),
                    ],
                    selected: {filter.type ?? 'all'},
                    onSelectionChanged: (s) {
                      final v = s.first;
                      ref.read(exploreFilterProvider.notifier).state =
                          filter.copyWith(type: v == 'all' ? null : v);
                    },
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: filter.sort,
                  tooltip: 'Urutkan',
                  onSelected: (v) {
                    ref.read(exploreFilterProvider.notifier).state =
                        filter.copyWith(sort: v);
                  },
                  icon: const Icon(Icons.sort_rounded),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'newest', child: Text('Terbaru')),
                    PopupMenuItem(value: 'oldest', child: Text('Terlama')),
                    PopupMenuItem(
                        value: 'price_asc', child: Text('Harga terendah')),
                    PopupMenuItem(
                        value: 'price_desc', child: Text('Harga tertinggi')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: results.maybeWhen(
                data: (items) {
                  final label = filter.search.isEmpty
                      ? '${items.length} hasil'
                      : '${items.length} hasil untuk "${filter.search}"';
                  return Text(
                    label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),

          Expanded(
            child: results.when(
              loading: () => Shimmer.fromColors(
                baseColor: AppColors.border,
                highlightColor: AppColors.surface,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (var i = 0; i < 5; i++)
                      Container(
                        height: 96,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 10),
                    Text('Gagal memuat', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () =>
                          ref.invalidate(exploreControllerProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color:
                            AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('Tidak ada hasil',
                            style: theme.textTheme.titleMedium),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Coba kata kunci atau filter lain.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(exploreControllerProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        ListingCard(listing: items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
