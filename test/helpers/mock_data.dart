import 'package:flutter_test/flutter_test.dart';
import 'package:manage_your_logistic/models/item_model.dart';
import 'package:manage_your_logistic/models/user_model.dart';
import 'package:manage_your_logistic/models/stock_move_model.dart';

/// Mock data helper for tests
class MockData {
  // Mock Users
  static UserModel get adminUser => UserModel(
        uid: 'admin-123',
        name: 'Admin User',
        email: 'admin@test.com',
        role: 'admin',
      );

  static UserModel get staffUser => UserModel(
        uid: 'staff-123',
        name: 'Staff User',
        email: 'staff@test.com',
        role: 'staff',
      );

  // Mock Items
  static ItemModel get testItem1 => ItemModel(
        id: 'item-1',
        name: 'Test Item 1',
        sku: 'SKU-001',
        barcode: 'BC-001',
        description: 'Test description 1',
        category: 'Category A',
        unit: 'pcs',
        reorderLevel: 10,
        createdBy: 'admin-123',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  static ItemModel get testItem2 => ItemModel(
        id: 'item-2',
        name: 'Test Item 2',
        sku: 'SKU-002',
        barcode: 'BC-002',
        description: 'Test description 2',
        category: 'Category B',
        unit: 'box',
        reorderLevel: 20,
        createdBy: 'admin-123',
        createdAt: DateTime(2025, 1, 2),
        updatedAt: DateTime(2025, 1, 2),
      );

  static List<ItemModel> get testItems => [testItem1, testItem2];

  // Mock Stock Moves
  static StockMoveModel get inboundMove => StockMoveModel(
        id: 'move-1',
        itemId: 'item-1',
        locationId: 'loc-1',
        qty: 100,
        type: 'inbound',
        userId: 'admin-123',
        notes: 'Initial stock',
        timestamp: DateTime(2025, 1, 1),
      );

  static StockMoveModel get outboundMove => StockMoveModel(
        id: 'move-2',
        itemId: 'item-1',
        locationId: 'loc-1',
        qty: 50,
        type: 'outbound',
        userId: 'staff-123',
        notes: 'Sales order',
        timestamp: DateTime(2025, 1, 2),
      );

  // Helper methods
  static ItemModel createItem({
    required String id,
    required String name,
    required String sku,
  }) {
    return ItemModel(
      id: id,
      name: name,
      sku: sku,
      barcode: 'BC-$id',
      description: 'Test item $name',
      category: 'Test Category',
      unit: 'pcs',
      reorderLevel: 10,
      createdBy: 'test-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static UserModel createUser({
    required String uid,
    required String name,
    required String email,
    String role = 'staff',
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      role: role,
    );
  }
}
