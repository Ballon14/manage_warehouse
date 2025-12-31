import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../services/firestore_paths.dart';
import '../core/errors/exceptions.dart';
import 'item_repository.dart';

/// Firebase implementation of ItemRepository
///
/// This class handles all Firestore operations for items.
/// It converts Firestore exceptions to domain exceptions.
class ItemRepositoryImpl implements ItemRepository {
  final FirebaseFirestore _firestore;

  ItemRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ItemModel>> getAll() {
    try {
      return _firestore
          .collection(FirestorePaths.items)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw ServerException(message: 'Failed to fetch items: $e');
    }
  }

  @override
  Future<ItemModel?> getById(String id) async {
    try {
      final doc =
          await _firestore.collection(FirestorePaths.items).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return ItemModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch item: $e');
    }
  }

  @override
  Future<void> create(ItemModel item) async {
    try {
      await _firestore
          .collection(FirestorePaths.items)
          .doc(item.id)
          .set(item.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to create item: $e');
    }
  }

  @override
  Future<void> update(ItemModel item) async {
    try {
      await _firestore
          .collection(FirestorePaths.items)
          .doc(item.id)
          .update(item.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to update item: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(FirestorePaths.items).doc(id).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete item: $e');
    }
  }

  @override
  Future<List<ItemModel>> search(String query) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _firestore.collection(FirestorePaths.items).get();

      return snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
          .where((item) =>
              item.name.toLowerCase().contains(queryLower) ||
              item.sku.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search items: $e');
    }
  }

  @override
  Future<ItemModel?> getByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.items)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ItemModel.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch item by barcode: $e');
    }
  }

  @override
  Future<ItemModel?> getBySku(String sku) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.items)
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ItemModel.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch item by SKU: $e');
    }
  }

  @override
  Future<bool> skuExists(String sku) async {
    try {
      final item = await getBySku(sku);
      return item != null;
    } catch (e) {
      throw ServerException(message: 'Failed to check SKU existence: $e');
    }
  }

  @override
  Future<bool> barcodeExists(String barcode) async {
    try {
      final item = await getByBarcode(barcode);
      return item != null;
    } catch (e) {
      throw ServerException(message: 'Failed to check barcode existence: $e');
    }
  }
}
