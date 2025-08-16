// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String taskId;
  final String taskDate;
  final String taskName;
  final String servedCustomer; // Customer ID
  final String customerName; // Added field for customer name
  final String location; // Added field for location/address
  final String asssignedToCCE;
  final String
      taskStatus; // Changed to String instead of List for simpler status handling
  final String taskCompletionImageUrl;
  final DateTime? scheduledTime; // Added field for task scheduling
  final bool isMissed; // Added field to track missed tasks

  Task({
    required this.taskId,
    required this.taskDate,
    required this.taskName,
    required this.servedCustomer,
    required this.customerName,
    required this.location,
    required this.asssignedToCCE,
    required this.taskStatus,
    required this.taskCompletionImageUrl,
    this.scheduledTime,
    this.isMissed = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'taskDate': taskDate,
      'taskStatus': taskStatus,
      'taskName': taskName,
      'servedCustomer': servedCustomer,
      'customerName': customerName,
      'location': location,
      'asssignedToCCE': asssignedToCCE,
      'taskCompletionImageUrl': taskCompletionImageUrl,
      'scheduledTime': scheduledTime,
      'isMissed': isMissed,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Timestamp to DateTime if it exists
    DateTime? scheduledTime;
    if (data['scheduledTime'] != null) {
      scheduledTime = (data['scheduledTime'] as Timestamp).toDate();
    }

    return Task(
      taskId: doc.id,
      taskDate: data['taskDate'] ?? '',
      taskName: data['taskName'] ?? '',
      taskStatus: data['taskStatus'] ?? 'pending', // Default to pending
      taskCompletionImageUrl: data['taskCompletionImageUrl'] ?? '',
      servedCustomer: data['servedCustomer'] ?? '',
      customerName: data['customerName'] ?? '',
      location: data['location'] ?? '',
      asssignedToCCE: data['asssignedToCCE'] ?? '',
      scheduledTime: scheduledTime,
      isMissed: data['isMissed'] ?? false,
    );
  }

  // Helper method to get status display text
  String get statusDisplayText {
    if (isMissed) return 'MISS';
    switch (taskStatus.toLowerCase()) {
      case 'completed':
        return 'COM';
      case 'pending':
      default:
        return 'PEN';
    }
  }

  // Helper method to get status color
  String get statusColor {
    if (isMissed) return 'red';
    switch (taskStatus.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'pending':
      default:
        return 'amber';
    }
  }
}
