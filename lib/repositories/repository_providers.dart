import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'item_repository.dart';
import 'item_repository_impl.dart';

/// Provider for ItemRepository
/// 
/// This provides the default Firebase implementation.
/// Can be overridden in tests with a mock implementation.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl();
});
