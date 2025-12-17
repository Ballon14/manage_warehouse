class FirestorePaths {
  // Collections
  static const String users = 'users';
  static const String items = 'items';
  static const String locations = 'locations';
  static const String warehouses = 'warehouses';
  static const String stockLevels = 'stock_levels';
  static const String stockMoves = 'stock_moves';
  static const String inventoryCounts = 'inventory_counts';
  static const String inventoryCountLines = 'inventory_count_lines';

  // User paths
  static String user(String uid) => '$users/$uid';

  // Item paths
  static String item(String itemId) => '$items/$itemId';

  // Location paths
  static String location(String locationId) => '$locations/$locationId';

  // Warehouse paths
  static String warehouse(String warehouseId) => '$warehouses/$warehouseId';

  // Stock level paths
  static String stockLevel(String itemId, String locationId) =>
      '$stockLevels/${itemId}_$locationId';

  // Stock move paths
  static String stockMove(String moveId) => '$stockMoves/$moveId';

  // Inventory count paths
  static String inventoryCount(String sessionId) =>
      '$inventoryCounts/$sessionId';

  // Inventory count line paths
  static String inventoryCountLine(String sessionId, String itemId) =>
      '$inventoryCountLines/${sessionId}_$itemId';
}

