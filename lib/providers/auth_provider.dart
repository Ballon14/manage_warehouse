import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap((user) async {
    if (user != null) {
      AppLogger.auth('User auth state changed - ${user.uid}');
      try {
        final userData = await authService.getUserData(user.uid);
        AppLogger.success('User data retrieved - ${userData?.name}', 'Auth');
        return userData;
      } catch (e) {
        AppLogger.error('Error getting user data', 'Auth', e);
        return null;
      }
    }
    AppLogger.info('User is null (logged out)', 'Auth');
    return null;
  });
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

