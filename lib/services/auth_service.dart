import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with Email & Password
  Future<UserCredential> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required bool isLodged,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user model
        final newUser = UserModel(
          uid: user.uid,
          fullName: fullName,
          email: email,
          role: role,
          isLodged: isLodged,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestoreService.createUserProfile(newUser);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fetch full user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestoreService.getUserProfile(user.uid);
    }
    return null;
  }
}
