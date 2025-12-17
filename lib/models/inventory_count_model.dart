import 'package:cloud_firestore/cloud_firestore.dart';

enum InventoryCountStatus { draft, completed, cancelled }

class InventoryCountModel {
  final String sessionId;
  final String userId;
  final String locationId;
  final DateTime date;
  final InventoryCountStatus status;

  InventoryCountModel({
    required this.sessionId,
    required this.userId,
    required this.locationId,
    required this.date,
    required this.status,
  });

  factory InventoryCountModel.fromFirestore(
      Map<String, dynamic> data, String sessionId) {
    return InventoryCountModel(
      sessionId: sessionId,
      userId: data['userId'] ?? '',
      locationId: data['locationId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _statusFromString(data['status'] ?? 'draft'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'locationId': locationId,
      'date': Timestamp.fromDate(date),
      'status': _statusToString(status),
    };
  }

  static InventoryCountStatus _statusFromString(String status) {
    switch (status) {
      case 'completed':
        return InventoryCountStatus.completed;
      case 'cancelled':
        return InventoryCountStatus.cancelled;
      default:
        return InventoryCountStatus.draft;
    }
  }

  static String _statusToString(InventoryCountStatus status) {
    switch (status) {
      case InventoryCountStatus.completed:
        return 'completed';
      case InventoryCountStatus.cancelled:
        return 'cancelled';
      default:
        return 'draft';
    }
  }
}

