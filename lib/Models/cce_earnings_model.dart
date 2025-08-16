// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class CCEEarnings {
  final String? earningId;
  final String? cceId;
  final String? taskId;
  final String? customerId;
  final String? customerName;
  final String? taskName;
  final double? amount;
  final Timestamp? time;
  final String?
      earningType; // 'task_completion', 'bonus', 'referral', 'penalty'
  final String? status; // 'pending', 'approved', 'paid'
  final String? description;
  final Map<String, dynamic>?
      metadata; // Additional data like task details, referral info, etc.
  final String? numberPlate;
  final String? address;
  final int? serviceNo;

  CCEEarnings({
    required this.earningId,
    required this.cceId,
    required this.taskId,
    required this.customerId,
    required this.customerName,
    required this.taskName,
    required this.amount,
    required this.time,
    required this.earningType,
    required this.status,
    this.description,
    this.metadata,
    required this.numberPlate,
    required this.address,
    required this.serviceNo,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'earningId': earningId,
      'cceId': cceId,
      'taskId': taskId,
      'customerId': customerId,
      'customerName': customerName,
      'taskName': taskName,
      'amount': amount,
      'time': time,
      'earningType': earningType,
      'status': status,
      'description': description,
      'metadata': metadata,
      'numberPlate': numberPlate,
      'serviceNo': serviceNo,
      'address': address
    };
  }

  factory CCEEarnings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CCEEarnings(
      earningId: doc.id,
      cceId: data['cceId'] ?? '',
      taskId: data['taskId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      taskName: data['taskName'] ?? '',
      amount: (data['amount'] ?? 0),
      time: data['time'] as Timestamp,
      earningType: data['earningType'] ?? 'task_completion',
      status: data['status'] ?? 'pending',
      description: data['description'],
      metadata: data['metadata'],
      numberPlate: data['numberPlate'] ?? '',
      serviceNo: data['serviceNo'] ?? 0,
      address: data['address'] ?? '',
    );
  }

  // Helper method to get earning type display text
  String get earningTypeDisplayText {
    switch (earningType) {
      case 'task_completion':
        return 'Task Completion';
      case 'bonus':
        return 'Bonus';
      case 'referral':
        return 'Referral';
      case 'penalty':
        return 'Penalty';
      default:
        return 'Other';
    }
  }

  // Helper method to get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'paid':
        return 'Paid';
      default:
        return 'Unknown';
    }
  }
}
