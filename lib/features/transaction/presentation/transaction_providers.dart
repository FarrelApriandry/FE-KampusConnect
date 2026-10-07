import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../../core/providers/providers.dart';
import '../data/transaction_remote_datasource.dart';
import '../domain/models/transaction.dart';

final transactionDatasourceProvider = Provider<TransactionRemoteDatasource>(
  (ref) => TransactionRemoteDatasource(ref.watch(dioProvider)),
);

/// Filter tab inbox: semua / sebagai pembeli / sebagai penjual.
enum TxRoleFilter { all, buyer, seller }

class TransactionsController
    extends AutoDisposeAsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final role = ref.watch(txRoleFilterProvider);
    final me = ref.watch(authControllerProvider).valueOrNull;
    if (me?.user?.id == null) return const [];

    final r = await ref.watch(transactionDatasourceProvider).list(
          limit: 50,
          role: role == TxRoleFilter.all
              ? null
              : (role == TxRoleFilter.buyer ? 'BUYER' : 'SELLER'),
        );
    return r.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Transaction>>().copyWithPrevious(state);
    ref.invalidateSelf();
  }

  /// Terima / tolak / selesaikan / batalkan — state machine divalidasi BE.
  Future<void> changeStatus(String id, String status) async {
    final updated =
        await ref.read(transactionDatasourceProvider).updateStatus(
              id: id,
              status: status,
            );
    state = state.whenData(
      (items) =>
          items.map((t) => t.id == updated.id ? updated : t).toList(),
    );
  }

  /// Ajukan negosiasi dari halaman detail — refresh feed transaksi.
  Future<Transaction> offer({
    required String listingId,
    required num agreedPrice,
  }) async {
    final t = await ref.read(transactionDatasourceProvider).create(
          listingId: listingId,
          agreedPrice: agreedPrice,
        );
    ref.invalidateSelf();
    return t;
  }
}

final txRoleFilterProvider =
    StateProvider<TxRoleFilter>((ref) => TxRoleFilter.all);

final transactionsProvider = AutoDisposeAsyncNotifierProvider<
    TransactionsController, List<Transaction>>(TransactionsController.new);
