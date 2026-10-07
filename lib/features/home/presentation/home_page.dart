import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/kc_logo.dart';
import '../../../shared/widgets/listing_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../listing/presentation/listing_providers.dart';

/// Halaman Home — sapaan, pintasan cari, kategori, dan feed listing terbaru.
/// Iterasi 2: tersambung ke GET /listings + GET /categories.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull?.user;
    final firstName = user?.name.split(' ').first ?? 'Mahasiswa';
    final feed = ref.watch(homeFeedProvider);
    final cats = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const KCLogo(size: 34, showWordmark: false),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(homeFeedProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(homeFeedProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Halo, $firstName!',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Temukan barang bekas di sekitar kampusmu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // Pintasan ke Explore.
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go('/explore'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      'Cari buku, elektronik, jasa, dll.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Kategori', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            cats.maybeWhen(
              data: (list) => SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    return ActionChip(
                      label: Text(c.name),
                      onPressed: () {
                        ref.read(exploreFilterProvider.notifier).state =
                            ExploreFilter(categoryId: c.id);
                        context.go('/explore');
                      },
                    );
                  },
                ),
              ),
              orElse: () => const _CategorySkeleton(),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child:
                      Text('Baru di kampus', style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go('/explore'),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            feed.when(
              loading: () => const _FeedSkeleton(),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 10),
                    Text('Gagal memuat feed',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(homeFeedProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) return const _EmptyFeed();
                return Column(
                  children: [for (final l in items) ListingCard(listing: l)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 44,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text('Belum ada iklan', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Jadi yang pertama jual — buka tab Sell.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
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
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              width: 96,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}
