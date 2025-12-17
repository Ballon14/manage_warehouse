import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_paths.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      print('🔑 AuthService: Attempting login for $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ AuthService: Firebase auth successful, fetching user data...');
        final userData = await getUserData(credential.user!.uid);
        if (userData != null) {
          print('✅ AuthService: User data fetched successfully - ${userData.name}');
        } else {
          print('⚠️ AuthService: User data is null!');
        }
        return userData;
      }
      print('⚠️ AuthService: Credential user is null');
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ AuthService: FirebaseAuthException - ${e.code}');
      // Handle specific Firebase auth errors
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        case 'wrong-password':
          throw Exception('Password salah');
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
      print('❌ AuthService: Unexpected error - $e');
      throw Exception('Login gagal: $e');
    }
  }

  // Register new user
  Future<UserModel?> register(
      String email, String password, String name, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
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
      print('📚 AuthService: Fetching user data for uid: $uid');
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();

      if (doc.exists) {
        print('✅ AuthService: User document found in Firestore');
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      print('⚠️ AuthService: User document does NOT exist in Firestore!');
      return null;
    } catch (e) {
      print('❌ AuthService: Error fetching user data - $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}

