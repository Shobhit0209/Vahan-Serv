import 'package:cloud_firestore/cloud_firestore.dart';

class CCEEarningsSummary {
  final String cceId;
  final double dailyEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final int totalTasksCompleted;
  final int totalReferrals;
  final double pendingAmount;
  final double paidAmount;
  final DateTime lastUpdated;

  CCEEarningsSummary({
    required this.cceId,
    required this.dailyEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.totalTasksCompleted,
    required this.totalReferrals,
    required this.pendingAmount,
    required this.paidAmount,
    required this.lastUpdated,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'cceId': cceId,
      'dailyEarnings': dailyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'monthlyEarnings': monthlyEarnings,
      'totalEarnings': totalEarnings,
      'totalTasksCompleted': totalTasksCompleted,
      'totalReferrals': totalReferrals,
      'pendingAmount': pendingAmount,
      'paidAmount': paidAmount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory CCEEarningsSummary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CCEEarningsSummary(
      cceId: doc.id,
      dailyEarnings: (data['dailyEarnings'] ?? 0).toDouble(),
      weeklyEarnings: (data['weeklyEarnings'] ?? 0).toDouble(),
      monthlyEarnings: (data['monthlyEarnings'] ?? 0).toDouble(),
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      totalTasksCompleted: data['totalTasksCompleted'] ?? 0,
      totalReferrals: data['totalReferrals'] ?? 0,
      pendingAmount: (data['pendingAmount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
