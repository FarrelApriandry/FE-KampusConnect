import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../transaction/presentation/transaction_providers.dart';
import '../domain/models/listing.dart';
import 'listing_providers.dart';

/// Detail listing — gambar, harga, penjual, tombol nego (FR-05, FR-08).
class ListingDetailPage extends ConsumerWidget {
  const ListingDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detail = ref.watch(listingDetailProvider(id));
    final me = ref.watch(authControllerProvider).valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 44, color: AppColors.danger),
              const SizedBox(height: 10),
              Text('Listing tidak dapat dimuat',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('$e',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(listingDetailProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (l) => RefreshIndicator(
          onRefresh: () => ref.refresh(listingDetailProvider(id).future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Gallery(listing: l),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Chip(label: l.isService ? 'Jasa' : 'Produk'),
                        if (l.condition != null &&
                            l.condition != 'NOT_APPLICABLE')
                          _Chip(label: l.conditionLabel),
                        _Chip(label: l.statusLabel, muted: !l.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(l.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      l.priceText,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (l.meetupLocation != null &&
                        l.meetupLocation!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l.meetupLocation!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (l.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Diposting ${formatRelativeTime(l.createdAt!)}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Penjual.
                    if (l.seller != null)
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              initialsOf(l.seller!.name),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l.seller!.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (l.seller!.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded,
                                    size: 16, color: AppColors.success),
                              ],
                            ],
                          ),
                          subtitle: const Text('Mahasiswa Untidar'),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Deskripsi.
                    Text('Deskripsi', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    SelectableText(
                      (l.description?.isNotEmpty ?? false)
                          ? l.description!
                          : 'Tanpa deskripsi.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),

                    // Aksi pemilik: arsipkan / aktifkan.
                    if (me != null && (l.isOwner || me.id == l.sellerId)) ...[
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final target =
                              l.status == 'ARCHIVED' ? 'ACTIVE' : 'ARCHIVED';
                          try {
                            await updateListing(ref, l.id, status: target);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(target == 'ARCHIVED'
                                      ? 'Listing diarsipkan'
                                      : 'Listing diaktifkan kembali'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                        icon: Icon(
                          l.status == 'ARCHIVED'
                              ? Icons.unarchive_rounded
                              : Icons.inventory_2_outlined,
                          size: 20,
                        ),
                        label: Text(l.status == 'ARCHIVED'
                            ? 'Aktifkan kembali'
                            : 'Arsipkan listing'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Buyer: tombol nego di bottom bar (bukan pemilik listing).
      bottomNavigationBar: detail.maybeWhen(
        data: (l) {
          final mine = me != null &&
              (l.isOwner || me.id == l.sellerId);
          if (mine || !l.isActive) return null;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton.icon(
                onPressed: () => _offerSheet(context, ref, l),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Ajukan Nego'),
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  void _offerSheet(BuildContext context, WidgetRef ref, Listing l) {
    final theme = Theme.of(context);
    final ctrl = TextEditingController(text: '${l.price.toInt()}');
    final formKey = GlobalKey<FormState>();
    bool busy = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajukan nego — ${l.title}',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Harga list: ${l.priceText}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga yang lo tawarin',
                    prefixText: 'Rp',
                  ),
                  validator: (v) {
                    final n = num.tryParse((v ?? '').trim());
                    if (n == null || n < 0) return 'Harga tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          setState(() => busy = true);
                          try {
                            await ref
                                .read(transactionsProvider.notifier)
                                .offer(
                                  listingId: l.id,
                                  agreedPrice:
                                      num.parse(ctrl.text.trim()),
                                );
                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Nego terkirim — cek tab Inbox untuk balasan.'),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => busy = false);
                            if (sheetCtx.mounted) {
                              ScaffoldMessenger.of(sheetCtx)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Kirim tawaran'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final urls = listing.images.map((e) => e.imageUrl).toList();

    if (urls.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: AppColors.primarySoft,
        child: const Icon(Icons.image_outlined,
            size: 48, color: AppColors.primary),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: urls.length,
        itemBuilder: (context, i) => CachedNetworkImage(
          imageUrl: urls[i],
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.primarySoft),
          errorWidget: (_, _, _) => Container(
            color: AppColors.primarySoft,
            child: const Icon(Icons.image_outlined, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: muted ? AppColors.border : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: muted ? AppColors.textSecondary : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
