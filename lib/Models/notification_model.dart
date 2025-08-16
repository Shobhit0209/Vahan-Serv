import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isRead; // Keep final for immutability, update via copyWith

  // Create a Uuid generator instance
  static const _uuid = Uuid();

  NotificationModel({
    String? id, // Make id optional in constructor
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.data = const {}, // Default to empty map
    this.isRead = false,
  }) : id = id ?? _uuid.v4(); // Generate UUID if ID is not provided

  factory NotificationModel.fromFirebaseMessage(RemoteMessage message) {
    // Ensure message.data is not null; default to empty map if it is
    final Map<String, dynamic> messageData = message.data;

    return NotificationModel(
      // Prefer messageId if available, otherwise generate a UUID
      id: message.messageId ?? _uuid.v4(),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      type: messageData['type'] as String? ??
          'general', // Safely cast and provide default
      timestamp: DateTime.now(), // Timestamp for when it's received
      data: messageData,
      isRead: false,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String, // Cast directly, should always be String
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(
          json['timestamp'] as String), // Cast to String before parsing
      // Ensure 'data' is treated as a Map<String, dynamic>, handling potential null or wrong type
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      isRead:
          json['isRead'] as bool? ?? false, // Handle potential null for isRead
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'isRead': isRead,
    };
  }

  // copyWith method for creating new instances with modified properties
  // Added optional parameters for all final fields to make it more flexible
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}
