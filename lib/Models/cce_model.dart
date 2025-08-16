// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class CCE {
  final String cceId;
  final String name;
  final String mobile;
  final String email;
  final int? age;
  final String doj;
  final String address;
  final String photoUrl;
  late final double monthlyEarning;
  late final double todayEarning;
  final String nextPayoutDate;
  final int completedTasks;
  final int pendingTasks;
  final int missedTasks;
  final int totalCustomers;
  final String referralCode;
  final bool isActive;
  final int? leavesLeft;

  CCE({
    required this.cceId,
    required this.name,
    required this.mobile,
    this.email = '',
    required this.age,
    required this.doj,
    this.address = '',
    required this.photoUrl,
    required this.monthlyEarning,
    required this.todayEarning,
    required this.nextPayoutDate,
    required this.completedTasks,
    required this.pendingTasks,
    required this.missedTasks,
    required this.totalCustomers,
    required this.referralCode,
    this.isActive = true,
    this.leavesLeft,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'cceId': cceId,
      'name': name,
      'address': address,
      'age': age,
      'mobile': mobile,
      'doj': doj,
      'photoUrl': photoUrl,
      'monthlyEarning': monthlyEarning,
      'todayEarning': todayEarning,
      'nextPayoutDate': nextPayoutDate,
      'totalCustomers': totalCustomers,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'missedTasks': missedTasks,
      'referralCode': referralCode,
      'isActive': isActive,
      'leavesLeft': leavesLeft ?? 2, // Default to 2 if null
    };
  }

  factory CCE.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CCE(
        cceId: doc.id,
        name: data['name'] ?? '',
        mobile: data['mobile'] ?? '',
        age: data['age'] ?? 0,
        email: data['email'] ?? '',
        doj: data['doj'] ?? '',
        address: data['address'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
        monthlyEarning: (data['monthlyEarning'] ?? 0).toDouble() ?? 0.0,
        todayEarning: (data['todayEarning'] ?? 0).toDouble() ?? 0.0,
        referralCode: data['referralCode'] ?? '',
        nextPayoutDate: data['nextPayoutDate'] ?? '',
        completedTasks: data['completedTasks'] ?? 0,
        pendingTasks: data['pendingTasks'] ?? 0,
        missedTasks: data['missedTasks'] ?? 0,
        totalCustomers: data['totalCustomers'] ?? 0,
        isActive: data['isActive'] ?? true,
        leavesLeft:
            data['leavesLeft'] != null ? (data['leavesLeft'] as int) : 2);
  }
}
