class InventoryCountLineModel {
  final String sessionId;
  final String itemId;
  final double countedQty;
  final double systemQty;
  final double variance;

  InventoryCountLineModel({
    required this.sessionId,
    required this.itemId,
    required this.countedQty,
    required this.systemQty,
    required this.variance,
  });

  factory InventoryCountLineModel.fromFirestore(Map<String, dynamic> data) {
    final countedQty = (data['countedQty'] ?? 0).toDouble();
    final systemQty = (data['systemQty'] ?? 0).toDouble();
    return InventoryCountLineModel(
      sessionId: data['sessionId'] ?? '',
      itemId: data['itemId'] ?? '',
      countedQty: countedQty,
      systemQty: systemQty,
      variance: countedQty - systemQty,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'itemId': itemId,
      'countedQty': countedQty,
      'systemQty': systemQty,
      'variance': variance,
    };
  }
}

