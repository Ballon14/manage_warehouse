import 'package:manage_your_logistic/repositories/item_repository.dart';
import 'package:manage_your_logistic/models/item_model.dart';

/// Mock implementation of ItemRepository for testing
class MockItemRepository implements ItemRepository {
  final List<ItemModel> _items = [];
  bool shouldThrowError = false;
  
  @override
  Stream<List<ItemModel>> getAll() {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to fetch items');
    }
    return Stream.value(_items);
  }

  @override
  Future<ItemModel?> getById(String id) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to fetch item');
    }
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> create(ItemModel item) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to create item');
    }
    _items.add(item);
  }

  @override
  Future<void> update(ItemModel item) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to update item');
    }
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to delete item');
    }
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<ItemModel>> search(String query) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to search items');
    }
    final queryLower = query.toLowerCase();
    return _items
        .where((item) =>
            item.name.toLowerCase().contains(queryLower) ||
            item.sku.toLowerCase().contains(queryLower))
        .toList();
  }

  @override
  Future<ItemModel?> getByBarcode(String barcode) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to fetch item by barcode');
    }
    try {
      return _items.firstWhere((item) => item.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ItemModel?> getBySku(String sku) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to fetch item by SKU');
    }
    try {
      return _items.firstWhere((item) => item.sku == sku);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> skuExists(String sku) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to check SKU');
    }
    final item = await getBySku(sku);
    return item != null;
  }

  @override
  Future<bool> barcodeExists(String barcode) async {
    if (shouldThrowError) {
      throw Exception('Mock error: Failed to check barcode');
    }
    final item = await getByBarcode(barcode);
    return item != null;
  }

  // Helper methods for tests
  void addItem(ItemModel item) {
    _items.add(item);
  }

  void clear() {
    _items.clear();
  }

  int get itemCount => _items.length;
}
