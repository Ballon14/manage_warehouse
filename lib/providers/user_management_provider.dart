import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

// Provider for all users stream
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getAllUsers();
});
