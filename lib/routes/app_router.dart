import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/learner/home_screen.dart';
import '../screens/learner/catalogue_screen.dart';
import '../screens/learner/detail_screen.dart';
import '../screens/learner/placeholder_screens.dart';
import '../screens/admin/admin_dashboard.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/catalogue', builder: (_, __) => const CatalogueScreen()),
      GoRoute(
        path: '/document/:id',
        builder: (_, state) => DetailScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/loans', builder: (_, __) => const LoansScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
    ],
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';

      final user = authState.value;
      final isAuthScreen = ['/login', '/register', '/splash'].contains(state.uri.path);

      if (user == null) {
        return isAuthScreen ? null : '/login';
      }

      if (profileAsync.isLoading) return '/splash';

      if (isAuthScreen) {
        final profile = profileAsync.value;
        if (profile?.role == 'Administrateur' || profile?.role == 'Bibliothécaire') {
          return '/admin';
        }
        return '/home';
      }

      return null;
    },
  );
});
