import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/chat/presentation/inbox_page.dart';
import '../features/explore/presentation/explore_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/listing/presentation/listing_detail_page.dart';
import '../features/listing/presentation/sell_page.dart';
import '../features/onboarding/presentation/shell_page.dart';
import '../features/onboarding/presentation/splash_page.dart';
import '../features/profile/presentation/me_page.dart';
import '../features/transaction/presentation/transaction_detail_page.dart';

/// Provider GoRouter. Auth redirect otomatis:
/// - sesi loading        → /splash
/// - belum login         → /login (kecuali /login, /register)
/// - sudah login         → / (shell), keluar dari halaman auth
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, _) {
    refresh.value++;
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final authState = auth.valueOrNull;
      final loc = state.matchedLocation;

      final isAuthPage = loc == '/login' || loc == '/register';

      // Masih restore sesi → tahan di splash.
      if (authState == null) {
        return loc == '/splash' ? null : '/splash';
      }

      if (authState.isAuthenticated) {
        if (isAuthPage || loc == '/splash') return '/';
        return null;
      }

      // Guest: halaman auth boleh, sisanya → login.
      if (isAuthPage) return null;
      return '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const HomePage(),
              ),
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (_, _) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sell',
                builder: (_, _) => const SellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (_, _) => const InboxPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (_, _) => const MePage(),
              ),
            ],
          ),
        ],
      ),
      // Detail listing di luar shell (full screen, tanpa bottom nav).
      GoRoute(
        path: '/listings/:id',
        builder: (context, state) => ListingDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      // Detail transaksi (dari Inbox).
      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) => TransactionDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});