class StockLevelModel {
  final String itemId;
  final String locationId;
  final double qty;

  StockLevelModel({
    required this.itemId,
    required this.locationId,
    required this.qty,
  });

  factory StockLevelModel.fromFirestore(Map<String, dynamic> data) {
    return StockLevelModel(
      itemId: data['itemId'] ?? '',
      locationId: data['locationId'] ?? '',
      qty: (data['qty'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'locationId': locationId,
      'qty': qty,
    };
  }
}
