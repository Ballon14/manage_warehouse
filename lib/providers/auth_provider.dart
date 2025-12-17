import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap((user) async {
    if (user != null) {
      print('👤 AuthStateProvider: User auth state changed - ${user.uid}');
      try {
        final userData = await authService.getUserData(user.uid);
        print('👤 AuthStateProvider: User data retrieved - ${userData?.name}');
        return userData;
      } catch (e) {
        print('❌ AuthStateProvider: Error getting user data - $e');
        return null;
      }
    }
    print('👤 AuthStateProvider: User is null (logged out)');
    return null;
  });
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

