import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import '../models/item_model.dart';
import 'theme_provider.dart';

/// Notification service for managing in-app notifications
class NotificationService extends StateNotifier<List<NotificationModel>> {
  final SharedPreferences _prefs;
  static const String _notificationsKey = 'app_notifications';
  static const String _settingsKey = 'notification_settings';

  NotificationService(this._prefs) : super([]) {
    _loadNotifications();
  }

  /// Load notifications from storage
  void _loadNotifications() {
    final notificationsJson = _prefs.getString(_notificationsKey);
    if (notificationsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(notificationsJson);
        state = decoded.map((item) => NotificationModel.fromMap(item)).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        state = [];
      }
    }
  }

  /// Save notifications to storage
  Future<void> _saveNotifications() async {
    final encoded = json.encode(state.map((n) => n.toMap()).toList());
    await _prefs.setString(_notificationsKey, encoded);
  }

  /// Add new notification
  Future<void> addNotification(NotificationModel notification) async {
    state = [notification, ...state];
    await _saveNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    state = state.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    await _saveNotifications();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    state = state.where((n) => n.id != notificationId).toList();
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    state = [];
    await _prefs.remove(_notificationsKey);
  }

  /// Get unread count
  int get unreadCount => state.where((n) => !n.isRead).length;

  /// Check for low stock items and create notifications
  Future<void> checkLowStock(List<ItemModel> items) async {
    final settings = getNotificationSettings();
    if (!settings['lowStockAlerts']) return;

    for (var item in items) {
      // Check if notification already exists for this item
      final existingNotification = state.firstWhere(
        (n) => n.itemId == item.id && n.type == NotificationType.lowStock,
        orElse: () => NotificationModel(
          id: '',
          title: '',
          message: '',
          type: NotificationType.info,
          timestamp: DateTime.now(),
        ),
      );

      if (existingNotification.id.isEmpty) {
        // No existing notification, check stock level
        // Note: You'll need to implement actual stock calculation
        // For now, using reorderLevel as threshold
        const currentStock = 0; // TODO: Calculate from stock moves

        if (currentStock <= item.reorderLevel && currentStock > 0) {
          await addNotification(NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Low Stock Alert',
            message: '${item.name} is running low ($currentStock units)',
            type: NotificationType.lowStock,
            timestamp: DateTime.now(),
            itemId: item.id,
            data: {'stock': currentStock, 'reorderLevel': item.reorderLevel},
          ));
        } else if (currentStock <= 0) {
          await addNotification(NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Out of Stock',
            message: '${item.name} is out of stock!',
            type: NotificationType.outOfStock,
            timestamp: DateTime.now(),
            itemId: item.id,
          ));
        }
      }
    }
  }

  /// Get notification settings
  Map<String, dynamic> getNotificationSettings() {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson);
      } catch (e) {
        return _defaultSettings();
      }
    }
    return _defaultSettings();
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings));
  }

  /// Default settings
  Map<String, dynamic> _defaultSettings() {
    return {
      'lowStockAlerts': true,
      'outOfStockAlerts': true,
      'stockMovementAlerts': false,
      'soundEnabled': true,
    };
  }
}

/// Notification provider
final notificationServiceProvider =
    StateNotifierProvider<NotificationService, List<NotificationModel>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationService(prefs);
  },
);

/// Unread count provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationServiceProvider);
  return notifications.where((n) => !n.isRead).length;
});
