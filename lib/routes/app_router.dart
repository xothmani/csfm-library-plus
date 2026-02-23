import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

// Auth
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Learner shell + screens
import '../screens/shell/main_shell.dart';
import '../screens/learner/home_screen.dart';
import '../screens/learner/catalogue_screen.dart';
import '../screens/learner/detail_screen.dart';
import '../screens/learner/loans_screen.dart';
import '../screens/learner/notifications_screen.dart';
import '../screens/learner/placeholder_screens.dart';
import '../screens/learner/reservations_screen.dart';

// Admin shell + screens
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_documents_screen.dart';
import '../screens/admin/admin_loans_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── AUTH ─────────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // ── LEARNER SHELL (IndexedStack tabs) ────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/catalogue',
              builder: (_, __) => const CatalogueScreen(),
              routes: [
                GoRoute(path: 'document/:id', builder: (_, s) => DetailScreen(documentId: s.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/loans', builder: (_, __) => const LoansScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'reservations', builder: (_, __) => const ReservationsScreen()),
              ],
            ),
          ]),
        ],
      ),

      // ── ADMIN SHELL (IndexedStack tabs) ──────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdminShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/documents', builder: (_, __) => const AdminDocumentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/loans', builder: (_, __) => const AdminLoansScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';
      final user = authState.value;
      final isAuthRoute = ['/login', '/register', '/splash'].contains(state.uri.path);

      if (user == null) return isAuthRoute ? null : '/login';
      if (profileAsync.isLoading) return '/splash';

      final profile = profileAsync.value;
      final isAdmin = profile?.role == 'Administrateur' || profile?.role == 'Bibliothécaire';
      final isAdminRoute = state.uri.path.startsWith('/admin');
      final isLearnerRoute = !isAdminRoute && !isAuthRoute;

      if (isAuthRoute) {
        return isAdmin ? '/admin' : '/home';
      }

      // Block learner from admin routes and vice versa
      if (isAdmin && isLearnerRoute) return '/admin';
      if (!isAdmin && isAdminRoute) return '/home';

      return null;
    },
  );
});
