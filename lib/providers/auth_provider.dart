import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream provider to track Firebase Authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

// Future provider to fetch the current user's profile from Firestore
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return await ref.read(authServiceProvider).getCurrentUserProfile();
  }
  return null;
});
