import 'package:flutter/material.dart';

/// Notification model
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? itemId;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.itemId,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? itemId,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      itemId: itemId ?? this.itemId,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'itemId': itemId,
      'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.info,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      itemId: map['itemId'],
      data: map['data'],
    );
  }
}

/// Notification types
enum NotificationType {
  info,
  warning,
  error,
  success,
  lowStock,
  outOfStock,
  stockMovement,
}

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.outOfStock:
        return Icons.remove_shopping_cart;
      case NotificationType.stockMovement:
        return Icons.swap_horiz;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.outOfStock:
        return Colors.red;
      case NotificationType.stockMovement:
        return Colors.blue;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.info:
        return 'Info';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.error:
        return 'Error';
      case NotificationType.success:
        return 'Success';
      case NotificationType.lowStock:
        return 'Low Stock';
      case NotificationType.outOfStock:
        return 'Out of Stock';
      case NotificationType.stockMovement:
        return 'Stock Movement';
    }
  }
}
