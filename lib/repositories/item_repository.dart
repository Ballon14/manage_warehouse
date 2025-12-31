import '../models/item_model.dart';

/// Base repository interface for common CRUD operations
abstract class BaseRepository<T> {
  /// Get all items
  Stream<List<T>> getAll();

  /// Get item by ID
  Future<T?> getById(String id);

  /// Create new item
  Future<void> create(T item);

  /// Update existing item
  Future<void> update(T item);

  /// Delete item
  Future<void> delete(String id);
}

/// Repository interface for item operations
///
/// This interface defines the contract for item data access.
/// Implementations can use Firebase, local database, or mock data.
abstract class ItemRepository extends BaseRepository<ItemModel> {
  /// Search items by name or SKU
  Future<List<ItemModel>> search(String query);

  /// Get item by barcode
  Future<ItemModel?> getByBarcode(String barcode);

  /// Get item by SKU
  Future<ItemModel?> getBySku(String sku);

  /// Check if SKU exists
  Future<bool> skuExists(String sku);

  /// Check if barcode exists
  Future<bool> barcodeExists(String barcode);
}
