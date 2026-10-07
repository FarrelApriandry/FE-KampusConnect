import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/kc_logo.dart';
import '../../auth/presentation/auth_controller.dart';

/// Halaman Home — placeholder Iterasi 1.
/// Iterasi 2: feed listing + kategori + rekomendasi.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull?.user;
    final firstName = user?.name.split(' ').first ?? 'Mahasiswa';

    return Scaffold(
      appBar: AppBar(
        title: const KCLogo(size: 34, showWordmark: false),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Halo, $firstName!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Temukan barang bekas di sekitar kampusmu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.grid_view_rounded,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Feed listing segera hadir',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Fitur ini dibangun di iterasi berikutnya.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}