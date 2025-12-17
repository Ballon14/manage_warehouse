import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/item_service.dart';
import '../models/item_model.dart';

final itemServiceProvider = Provider<ItemService>((ref) => ItemService());

final itemsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final itemService = ref.watch(itemServiceProvider);
  return itemService.getItemsStream();
});

final itemsSearchProvider =
    StateProvider<String>((ref) => '');

final filteredItemsProvider = StreamProvider<List<ItemModel>>((ref) {
  final itemService = ref.watch(itemServiceProvider);
  final searchQuery = ref.watch(itemsSearchProvider);
  return itemService.searchItems(searchQuery);
});

final itemByIdProvider =
    FutureProvider.autoDispose.family<ItemModel?, String>((ref, itemId) async {
  final itemService = ref.watch(itemServiceProvider);
  return itemService.getItemById(itemId);
});

