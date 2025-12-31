import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';
import '../core/utils/validators.dart';
import '../core/security/rate_limiter.dart';
import '../core/config/security_constants.dart';
import 'firestore_paths.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoginRateLimiter _rateLimiter = LoginRateLimiter();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    // Sanitize inputs
    final sanitizedEmail = Validators.sanitizeInput(email).toLowerCase().trim();

    // Check rate limiting
    if (!_rateLimiter.isLoginAllowed(sanitizedEmail)) {
      final lockoutEnd = _rateLimiter.getLockoutEnd(sanitizedEmail);
      if (lockoutEnd != null) {
        final remaining = lockoutEnd.difference(DateTime.now()).inMinutes;
        throw Exception(
          '${ErrorMessages.accountLocked} (${remaining + 1} menit lagi)',
        );
      }
    }

    try {
      AppLogger.auth('Attempting login for $sanitizedEmail');
      final credential = await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      if (credential.user != null) {
        AppLogger.success(
            'Firebase auth successful, fetching user data...', 'Auth');
        final userData = await getUserData(credential.user!.uid);
        if (userData != null) {
          AppLogger.success(
              'User data fetched successfully - ${userData.name}', 'Auth');
          // Record successful login
          _rateLimiter.recordAttempt(sanitizedEmail, success: true);
        } else {
          AppLogger.warning('User data is null!', 'Auth');
        }
        return userData;
      }
      AppLogger.warning('Credential user is null', 'Auth');
      return null;
    } on FirebaseAuthException catch (e) {
      // Record failed attempt
      _rateLimiter.recordAttempt(sanitizedEmail, success: false);

      AppLogger.error('FirebaseAuthException - ${e.code}', 'Auth');
      // Handle specific Firebase auth errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        case 'wrong-password':
          final remaining = _rateLimiter.getRemainingAttempts(sanitizedEmail);
          if (remaining > 0) {
            throw Exception('Password salah. Sisa percobaan: $remaining');
          } else {
            throw Exception('Password salah');
          }
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan. Coba lagi nanti');
        case 'network-request-failed':
          throw Exception('Koneksi internet bermasalah');
        default:
          throw Exception('Login gagal: ${e.message ?? e.code}');
      }
    } catch (e) {
      // Record failed attempt for unknown errors
      _rateLimiter.recordAttempt(sanitizedEmail, success: false);
      AppLogger.error('Unexpected error', 'Auth', e);
      throw Exception('Login gagal: $e');
    }
  }

  // Register new user
  Future<UserModel?> register(
      String email, String password, String name, String role) async {
    // Sanitize inputs
    final sanitizedEmail = Validators.sanitizeInput(email).toLowerCase().trim();
    final sanitizedName = Validators.sanitizeInput(name).trim();

    // Validate password strength
    final passwordError =
        Validators.validatePassword(password, requireStrong: true);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: sanitizedName,
          email: sanitizedEmail,
          role: role,
        );

        await _firestore
            .collection(FirestorePaths.users)
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'weak-password':
          throw Exception('Password terlalu lemah. Minimal 6 karakter');
        case 'operation-not-allowed':
          throw Exception('Registrasi tidak diizinkan');
        case 'network-request-failed':
          throw Exception('Koneksi internet bermasalah');
        default:
          throw Exception('Registrasi gagal: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      AppLogger.database('Fetching user data for uid: $uid');
      final doc =
          await _firestore.collection(FirestorePaths.users).doc(uid).get();

      if (doc.exists) {
        AppLogger.success('User document found in Firestore', 'Database');
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      AppLogger.warning(
          'User document does NOT exist in Firestore!', 'Database');
      return null;
    } catch (e) {
      AppLogger.error('Error fetching user data', 'Database', e);
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<UserModel> updateProfile(
      String uid, String newName, String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Update name in Firestore
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        'name': newName,
      });

      // Update email in Firebase Auth if changed
      if (newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      // Get updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw Exception('Failed to fetch updated user data');
      }

      return updatedUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Please logout and login again to update email');
        case 'email-already-in-use':
          throw Exception('Email sudah digunakan');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        default:
          throw Exception('Failed to update profile: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ============ ADMIN USER MANAGEMENT ============

  // Get all users stream (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection(FirestorePaths.users).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Create user by admin
  Future<UserModel> createUserByAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    // Sanitize inputs
    final sanitizedEmail = Validators.sanitizeInput(email).toLowerCase().trim();
    final sanitizedName = Validators.sanitizeInput(name).trim();

    // Validate password strength
    final passwordError =
        Validators.validatePassword(password, requireStrong: false);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: sanitizedName,
          email: sanitizedEmail,
          role: role,
        );

        // Save to Firestore
        await _firestore
            .collection(FirestorePaths.users)
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
      throw Exception('Failed to create user');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'weak-password':
          throw Exception('Password terlalu lemah. Minimal 6 karakter');
        default:
          throw Exception('Gagal membuat user: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Gagal membuat user: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Gagal mengubah role: $e');
    }
  }

  // Delete user (admin only)
  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Firestore
      await _firestore.collection(FirestorePaths.users).doc(uid).delete();

      // Note: Deleting from Firebase Auth requires admin SDK on backend
      // For now, we only delete from Firestore
      // User won't be able to login as their Firestore data is gone
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }
}
