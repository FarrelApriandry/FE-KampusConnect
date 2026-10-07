import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/session_store.dart';
import '../../features/auth/data/auth_remote_datasource.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// ===== Global wiring: session, dio, datasource, repository =====

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionStore(),
);

final dioProvider = Provider<Dio>(
  (ref) => createApiClient(
    sessionStore: ref.watch(sessionStoreProvider),
  ),
);

final authDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authDatasourceProvider),
    ref.watch(sessionStoreProvider),
  ),
);