import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/models/transaction.dart';
import 'transaction_providers.dart';

/// Detail transaksi — status, harga deal, pihak, aksi sesuai state machine
/// SDD §9 (PENDING→ACCEPTED/REJECTED, ACCEPTED→COMPLETED/CANCELLED).
class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final me = ref.watch(authControllerProvider).valueOrNull?.user;
    final txs = ref.watch(transactionsProvider);
    Transaction? found;
    for (final x in txs.valueOrNull ?? const <Transaction>[]) {
      if (x.id == id) {
        found = x;
        break;
      }
    }

    if (found == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaksi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final t = found;

    final iAmSeller = me != null && t.sellerId == me.id;
    final iAmBuyer = me != null && t.buyerId == me.id;
    final counterpart = iAmSeller
        ? (t.buyer?.name ?? 'Pembeli')
        : (t.seller?.name ?? 'Penjual');

    // Aksi tersedia sesuai status + peran.
    final actions = <(String, String, Color)>[];
    if (iAmSeller && t.isPending) {
      actions.add(('ACCEPTED', 'Terima Nego', AppColors.success));
      actions.add(('REJECTED', 'Tolak', AppColors.danger));
    }
    if (iAmBuyer && t.isAccepted) {
      actions.add(('COMPLETED', 'Selesaikan', AppColors.success));
    }
    if (t.isAccepted) {
      actions.add(('CANCELLED', 'Batalkan', AppColors.textSecondary));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: _BigStatus(status: t.status),
          ),
          const SizedBox(height: 20),

          // Ringkasan.
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga deal', style: theme.textTheme.bodySmall),
                  Text(
                    t.agreedPriceText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(height: 24),
                  _Row(
                    icon: Icons.inventory_2_outlined,
                    label: 'Listing',
                    value: t.listing?.title ?? t.listingId,
                    onTap: t.listing == null
                        ? null
                        : () => context.push('/listings/${t.listingId}'),
                  ),
                  const SizedBox(height: 10),
                  _Row(
                    icon: iAmSeller
                        ? Icons.person_outline_rounded
                        : Icons.storefront_outlined,
                    label: iAmSeller ? 'Pembeli' : 'Penjual',
                    value: counterpart,
                  ),
                  const SizedBox(height: 10),
                  if (t.createdAt != null)
                    _Row(
                      icon: Icons.schedule_rounded,
                      label: 'Diajukan',
                      value: formatRelativeTime(t.createdAt!),
                    ),
                  if (t.completedAt != null) ...[
                    const SizedBox(height: 10),
                    _Row(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Selesai',
                      value: formatRelativeTime(t.completedAt!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Penjelasan status.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              switch (t.status) {
                'PENDING' => iAmSeller
                    ? 'Mahasiswa ini mengajukan nego di listing lo. Terima untuk lanjut, atau tolak kalau harga gak cocok.'
                    : 'Nego lo lagi nunggu dibalas penjual. Cek berkala ya.',
                'ACCEPTED' =>
                  'Nego diterima. Temu di titik yang disepakati, terus tekan "Selesaikan" setelah barang/jasa diterima.',
                'COMPLETED' => 'Transaksi selesai. Jangan lupa kasih ulasan bintang 5 kalau puas!',
                'REJECTED' => 'Nego ditolak penjual. Coba ajukan harga lain.',
                'CANCELLED' => 'Transaksi dibatalkan.',
                _ => '',
              },
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ),

          // Aksi.
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final (status, label, color) in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FilledButton.icon(
                  onPressed: () => _changeStatus(context, ref, t, status),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(switch (status) {
                    'ACCEPTED' => Icons.check_rounded,
                    'REJECTED' => Icons.close_rounded,
                    'COMPLETED' => Icons.task_alt_rounded,
                    _ => Icons.cancel_outlined,
                  }),
                  label: Text(label),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    Transaction t,
    String status,
  ) async {
    try {
      await ref.read(transactionsProvider.notifier).changeStatus(t.id, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status → ${Transaction.statusLabels[status] ?? status}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _BigStatus extends StatelessWidget {
  const _BigStatus({required this.status});

  final String status;

  static const _map = {
    'PENDING': (Icons.hourglass_top_rounded, Colors.orange),
    'ACCEPTED': (Icons.handshake_rounded, AppColors.success),
    'COMPLETED': (Icons.verified_rounded, AppColors.success),
    'REJECTED': (Icons.block_rounded, AppColors.danger),
    'CANCELLED': (Icons.cancel_outlined, AppColors.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) =
        _map[status] ?? (Icons.help_outline_rounded, AppColors.textSecondary);

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          Transaction.statusLabels[status] ?? status,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}
