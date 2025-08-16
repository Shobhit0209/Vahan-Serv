// lib/Providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vahanserv/Models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  late String _userNotificationsKey;
  static const String _baseKey = 'notifications_';

  // Constructor: Load notifications when the provider is instantiated
  NotificationProvider({required String cceId}) {
    _userNotificationsKey = '$_baseKey$cceId';
    _loadNotifications(cceId); // Call the async load method
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Add new notification
  void addNotification(NotificationModel notification, String cceId) {
    _notifications.insert(0, notification); // Add to beginning of list
    if (!notification.isRead) {
      _unreadCount++;
    }
    _saveNotificationsAndNotify(cceId); // Save and notify in one go
  }

  // Mark notification as read
  void markAsRead(String notificationId, String cceId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // Create a new NotificationModel instance with isRead set to true
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      _saveNotificationsAndNotify(cceId); // Save and notify
    }
  }

  // Mark all as read
  void markAllAsRead(String cceId) {
    bool changed = false;
    _notifications = _notifications.map((n) {
      if (!n.isRead) {
        changed = true;
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (changed) {
      // Only update if something actually changed
      _unreadCount = 0;
      _saveNotificationsAndNotify(cceId);
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String cceId) async {
    if (_notifications.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userNotificationsKey);
      await prefs.remove('unread_count_$cceId');
      _notifications = [];
      _unreadCount = 0;
      _saveNotificationsAndNotify(cceId);
    }
  }

  // Remove specific notification
  void removeNotification(String notificationId, String cceId) {
    final int initialLength = _notifications.length;
    _notifications.removeWhere((n) {
      if (n.id == notificationId) {
        if (!n.isRead) {
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
        return true; // Remove this notification
      }
      return false;
    });
    if (_notifications.length < initialLength) {
      // Only save/notify if a notification was actually removed
      _saveNotificationsAndNotify(cceId);
    }
  }

  // Helper to save notifications and notify listeners
  Future<void> _saveNotificationsAndNotify(String cceId) async {
    await _saveNotifications(cceId);
    notifyListeners();
  }

  // Save notifications to local storage
  Future<void> _saveNotifications(String cceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(
          _userNotificationsKey, jsonEncode(notificationsJson));
      await prefs.setInt('unread_count_$cceId', _unreadCount);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notifications: $e');
      }
    }
  }

  // Load notifications from local storage
  // This is now private as it's called internally by the constructor
  Future<void> _loadNotifications(String cceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_userNotificationsKey);
      _unreadCount = prefs.getInt('unread_count_$cceId') ?? 0;

      if (notificationsString != null && notificationsString.isNotEmpty) {
        final List<dynamic> notificationsJson = jsonDecode(notificationsString);
        _notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json as Map<String,
                dynamic>)) // Add 'as Map<String, dynamic>' for safety
            .toList();
        // Recalculate unread count on load to ensure accuracy,
        // especially if _unreadCountKey might be out of sync or missing initially
        _unreadCount = _notifications.where((n) => !n.isRead).length;

        // Sort notifications by timestamp (newest first) after loading
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else {
        _notifications = []; // Ensure it's an empty list if nothing loaded
        _unreadCount = 0; // Reset unread count if no notifications
      }
      notifyListeners(); // Notify listeners once after loading
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notifications: $e');
      }
      // In case of error, ensure state is reset to a safe default
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    }
  }
}
