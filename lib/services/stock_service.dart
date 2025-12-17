import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_level_model.dart';
import '../models/stock_move_model.dart';
import '../models/inventory_count_model.dart';
import '../models/inventory_count_line_model.dart';
import 'firestore_paths.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stock level for item at location
  Future<StockLevelModel?> getStockLevel(
      String itemId, String locationId) async {
    try {
      final docId = '${itemId}_$locationId';
      final doc = await _firestore
          .collection(FirestorePaths.stockLevels)
          .doc(docId)
          .get();

      if (doc.exists) {
        return StockLevelModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get stock level: $e');
    }
  }

  // Get all stock levels for an item
  Stream<List<StockLevelModel>> getStockLevelsForItem(String itemId) {
    return _firestore
        .collection(FirestorePaths.stockLevels)
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockLevelModel.fromFirestore(doc.data()))
            .toList());
  }

  // Inbound: increment stock and log movement
  Future<void> inbound(
      String itemId, double qty, String locationId, String userId) async {
    try {
      final docId = '${itemId}_$locationId';
      final batch = _firestore.batch();

      // Update or create stock level
      final stockLevelRef =
          _firestore.collection(FirestorePaths.stockLevels).doc(docId);
      final stockLevelDoc = await stockLevelRef.get();

      if (stockLevelDoc.exists) {
        final currentQty = (stockLevelDoc.data()!['qty'] ?? 0).toDouble();
        batch.update(stockLevelRef, {'qty': currentQty + qty});
      } else {
        batch.set(stockLevelRef, {
          'itemId': itemId,
          'locationId': locationId,
          'qty': qty,
        });
      }

      // Create stock move
      final stockMoveRef =
          _firestore.collection(FirestorePaths.stockMoves).doc();
      final stockMove = StockMoveModel(
        id: stockMoveRef.id,
        itemId: itemId,
        userId: userId,
        qty: qty,
        type: StockMoveType.inbound,
        timestamp: DateTime.now(),
        locationId: locationId,
      );
      batch.set(stockMoveRef, stockMove.toFirestore());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to process inbound: $e');
    }
  }

  // Outbound: decrement stock and log movement
  Future<void> outbound(
      String itemId, double qty, String locationId, String userId) async {
    try {
      final docId = '${itemId}_$locationId';
      final batch = _firestore.batch();

      // Check current stock
      final stockLevelRef =
          _firestore.collection(FirestorePaths.stockLevels).doc(docId);
      final stockLevelDoc = await stockLevelRef.get();

      if (!stockLevelDoc.exists) {
        throw Exception('No stock available for this item at this location');
      }

      final currentQty = (stockLevelDoc.data()!['qty'] ?? 0).toDouble();
      if (currentQty < qty) {
        throw Exception('Insufficient stock. Available: $currentQty');
      }

      // Update stock level
      batch.update(stockLevelRef, {'qty': currentQty - qty});

      // Create stock move
      final stockMoveRef =
          _firestore.collection(FirestorePaths.stockMoves).doc();
      final stockMove = StockMoveModel(
        id: stockMoveRef.id,
        itemId: itemId,
        userId: userId,
        qty: qty,
        type: StockMoveType.outbound,
        timestamp: DateTime.now(),
        locationId: locationId,
      );
      batch.set(stockMoveRef, stockMove.toFirestore());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to process outbound: $e');
    }
  }

  // Get stock moves (history)
  Stream<List<StockMoveModel>> getStockMoves({int? limit}) {
    var query = _firestore
        .collection(FirestorePaths.stockMoves)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => StockMoveModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Create inventory count session
  Future<String> createInventoryCount(
      String userId, String locationId) async {
    try {
      final sessionId = _firestore.collection(FirestorePaths.inventoryCounts).doc().id;
      final inventoryCount = InventoryCountModel(
        sessionId: sessionId,
        userId: userId,
        locationId: locationId,
        date: DateTime.now(),
        status: InventoryCountStatus.draft,
      );

      await _firestore
          .collection(FirestorePaths.inventoryCounts)
          .doc(sessionId)
          .set(inventoryCount.toFirestore());

      return sessionId;
    } catch (e) {
      throw Exception('Failed to create inventory count: $e');
    }
  }

  // Add inventory count line
  Future<void> addInventoryCountLine(
      String sessionId, String itemId, double countedQty) async {
    try {
      // Get system quantity
      final stockLevels = await _firestore
          .collection(FirestorePaths.stockLevels)
          .where('itemId', isEqualTo: itemId)
          .get();

      double systemQty = 0;
      for (var doc in stockLevels.docs) {
        systemQty += (doc.data()['qty'] ?? 0).toDouble();
      }

      final variance = countedQty - systemQty;

      final lineId = '${sessionId}_$itemId';
      final countLine = InventoryCountLineModel(
        sessionId: sessionId,
        itemId: itemId,
        countedQty: countedQty,
        systemQty: systemQty,
        variance: variance,
      );

      await _firestore
          .collection(FirestorePaths.inventoryCountLines)
          .doc(lineId)
          .set(countLine.toFirestore());
    } catch (e) {
      throw Exception('Failed to add inventory count line: $e');
    }
  }

  // Get inventory count lines for a session
  Stream<List<InventoryCountLineModel>> getInventoryCountLines(
      String sessionId) {
    return _firestore
        .collection(FirestorePaths.inventoryCountLines)
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                InventoryCountLineModel.fromFirestore(doc.data()))
            .toList());
  }

  // Complete inventory count
  Future<void> completeInventoryCount(String sessionId) async {
    try {
      await _firestore
          .collection(FirestorePaths.inventoryCounts)
          .doc(sessionId)
          .update({'status': 'completed'});
    } catch (e) {
      throw Exception('Failed to complete inventory count: $e');
    }
  }
}

