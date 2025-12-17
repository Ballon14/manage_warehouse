import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import 'firestore_paths.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream all items
  Stream<List<ItemModel>> getItemsStream() {
    return _firestore
        .collection(FirestorePaths.items)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get item by ID
  Future<ItemModel?> getItemById(String itemId) async {
    try {
      final doc =
          await _firestore.collection(FirestorePaths.items).doc(itemId).get();
      if (doc.exists) {
        return ItemModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get item: $e');
    }
  }

  // Get item by barcode
  Future<ItemModel?> getItemByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.items)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ItemModel.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get item by barcode: $e');
    }
  }

  // Search items by name or SKU
  Stream<List<ItemModel>> searchItems(String query) {
    if (query.isEmpty) {
      return getItemsStream();
    }

    final lowerQuery = query.toLowerCase();
    return _firestore
        .collection(FirestorePaths.items)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc.data(), doc.id))
            .where((item) =>
                item.name.toLowerCase().contains(lowerQuery) ||
                item.sku.toLowerCase().contains(lowerQuery))
            .toList());
  }

  // Create item
  Future<String> createItem(ItemModel item) async {
    try {
      final docRef =
          await _firestore.collection(FirestorePaths.items).add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // Update item
  Future<void> updateItem(String itemId, ItemModel item) async {
    try {
      await _firestore
          .collection(FirestorePaths.items)
          .doc(itemId)
          .update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection(FirestorePaths.items).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}

