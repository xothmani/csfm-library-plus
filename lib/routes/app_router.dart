import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/learner/home_screen.dart';
import '../screens/admin/admin_dashboard.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
    redirect: (context, state) {
      // If auth state is still loading, wait on splash screen
      if (authState.isLoading) return '/splash';

      final user = authState.value;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register';

      if (user == null) {
        // Not logged in and not on login/register => redirect to login
        if (!isLoggingIn && state.uri.path != '/splash') {
          return '/login';
        }
        return null;
      }

      // If logged in, wait for profile to load to determine role
      if (userProfileAsync.isLoading) {
        return '/splash';
      }

      final profile = userProfileAsync.value;
      
      // Once logged in, redirect away from auth screens
      if (isLoggingIn || state.uri.path == '/splash') {
        if (profile != null) {
          if (profile.role == 'Administrateur' || profile.role == 'Bibliothécaire') {
            return '/admin';
          }
          return '/home';
        }
        return '/home'; // fallback
      }

      // Basic role protection (admin shouldn't enter /home, learner shouldn't enter /admin)
      if (state.uri.path == '/admin' && profile != null && 
          profile.role != 'Administrateur' && profile.role != 'Bibliothécaire') {
        return '/home';
      }

      return null; // no redirect
    },
  );
});
