import 'package:cloud_firestore/cloud_firestore.dart';

enum StockMoveType { inbound, outbound }

class StockMoveModel {
  final String id;
  final String itemId;
  final String userId;
  final double qty;
  final StockMoveType type;
  final DateTime timestamp;
  final String? locationId;

  StockMoveModel({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.qty,
    required this.type,
    required this.timestamp,
    this.locationId,
  });

  factory StockMoveModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StockMoveModel(
      id: id,
      itemId: data['itemId'] ?? '',
      userId: data['userId'] ?? '',
      qty: (data['qty'] ?? 0).toDouble(),
      type: data['type'] == 'inbound'
          ? StockMoveType.inbound
          : StockMoveType.outbound,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      locationId: data['locationId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'userId': userId,
      'qty': qty,
      'type': type == StockMoveType.inbound ? 'inbound' : 'outbound',
      'timestamp': Timestamp.fromDate(timestamp),
      'locationId': locationId,
    };
  }
}

