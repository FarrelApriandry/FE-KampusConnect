import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../transaction/domain/models/transaction.dart';
import '../../transaction/presentation/transaction_providers.dart';

/// Inbox — daftar transaksi/nego (FR-08, FR-09).
/// Tab: Semua / Sebagai Pembeli / Sebagai Penjual.
/// Chat real-time belum masuk MVP; negosiasi harga lewat transaksi.
class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final me = ref.watch(authControllerProvider).valueOrNull?.user;
    final filter = ref.watch(txRoleFilterProvider);
    final txs = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            onPressed: () =>
                ref.read(transactionsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<TxRoleFilter>(
              segments: const [
                ButtonSegment(value: TxRoleFilter.all, label: Text('Semua')),
                ButtonSegment(
                    value: TxRoleFilter.buyer, label: Text('Pembelian')),
                ButtonSegment(
                    value: TxRoleFilter.seller, label: Text('Penjualan')),
              ],
              selected: {filter},
              onSelectionChanged: (s) =>
                  ref.read(txRoleFilterProvider.notifier).state = s.first,
            ),
          ),
          Expanded(
            child: txs.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
                          ref.read(transactionsProvider.notifier).refresh(),
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
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('Belum ada transaksi',
                            style: theme.textTheme.titleMedium),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Ajukan nego di halaman listing untuk mulai.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(transactionsProvider.notifier).refresh(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final t = items[i];
                      final iAmSeller = me != null &&
                          t.sellerId == me.id;
                      final counterpart =
                          iAmSeller ? (t.buyer?.name ?? 'Pembeli') : (t.seller?.name ?? 'Penjual');
                      final roleLabel = iAmSeller ? 'Penjualan' : 'Pembelian';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/transactions/${t.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _StatusBadge(status: t.status),
                                    const Spacer(),
                                    Text(
                                      roleLabel,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.listing?.title ?? 'Listing',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${iAmSeller ? 'Dari' : 'Ke'} $counterpart · ${t.agreedPriceText}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (t.createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    formatRelativeTime(t.createdAt!),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.7)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  static const _colors = {
    'PENDING': (Colors.orange, Colors.orange),
    'ACCEPTED': (AppColors.success, AppColors.success),
    'COMPLETED': (AppColors.success, AppColors.success),
    'REJECTED': (AppColors.danger, AppColors.danger),
    'CANCELLED': (AppColors.textSecondary, AppColors.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final label = Transaction.statusLabels[status] ?? status;
    final color = _colors[status]?.$1 ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
