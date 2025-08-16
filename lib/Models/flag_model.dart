import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Flag Reason enum for predefined reasons
enum FlagReasonType {
  incorrectAddress('INCORRECT_ADDRESS', 'Incorrect address of the customer'),
  customerRefusedService(
      'CUSTOMER_REFUSED_SERVICE', "Customer refused to take service today"),
  forcedServiceExpired('FORCED_SERVICE_EXPIRED',
      'Customer forces to serve even on expiration of their subscription plan'),
  carLockedUnavailable('CAR_LOCKED_UNAVAILABLE',
      'Car is locked or not available at the location'),
  unsafeBehavior('UNSAFE_BEHAVIOR', 'Rude, abusive, or unsafe behavior'),
  extremelyDirtyCar('EXTREMELY_DIRTY_CAR',
      'Extremely dirty or damaged car not fit for regular cleaning'),
  serviceNotCovered('SERVICE_NOT_COVERED',
      'Customer demands service not covered under the booked plan'),
  differentCar('DIFFERENT_CAR',
      'The car at the location is different from the one registered'),
  repeatedReschedule(
      'REPEATED_RESCHEDULE', 'Repeated rescheduling or cancellation'),

  subscriptionExpired(
      'SUBSCRIPTION_EXPIRED', 'Subscription Expired / Service Not Renewed');

  const FlagReasonType(this.code, this.title);
  final String code;
  final String title;
}

enum HindiFlagReasonType {
  incorrectAddress('INCORRECT_ADDRESS', ' ग्राहक का पता गलत है'),
  customerRefusedService(
      'CUSTOMER_REFUSED_SERVICE', "ग्राहक ने आज सर्विस लेने से इनकार कर दिया"),
  forcedServiceExpired('FORCED_SERVICE_EXPIRED',
      'ग्राहकों को उनकी सदस्यता योजना की समाप्ति पर भी सेवा देने के लिए बाध्य किया जा रहा है'),
  carLockedUnavailable(
      'CAR_LOCKED_UNAVAILABLE', 'कार लॉक है या स्थान पर उपलब्ध नहीं है'),
  unsafeBehavior('UNSAFE_BEHAVIOR', 'असभ्य, अपमानजनक या असुरक्षित व्यवहार'),
  extremelyDirtyCar('EXTREMELY_DIRTY_CAR',
      'अत्यधिक गंदी या क्षतिग्रस्त कार जो नियमित सफाई के लिए उपयुक्त नहीं'),
  serviceNotCovered('SERVICE_NOT_COVERED',
      'ग्राहक द्वारा बुक की गई योजना के अंतर्गत कवर न की गई सेवा की मांग'),
  differentCar('DIFFERENT_CAR', 'स्थान पर मौजूद कार पंजीकृत कार से भिन्न है'),
  repeatedReschedule(
      'REPEATED_RESCHEDULE', 'बार-बार पुनर्निर्धारण या रद्दीकरण'),

  subscriptionExpired(
      'SUBSCRIPTION_EXPIRED', 'सदस्यता समाप्त / सेवा नवीनीकृत नहीं।');

  const HindiFlagReasonType(this.code, this.title);
  final String code;
  final String title;
}

class CustomerFlag {
  final String flagId;
  final String flagReason;
  final String note;
  final String flaggedBy;
  final String customerId;
  final DateTime flaggedAt;
  final DateTime? resolvedAt;

  const CustomerFlag({
    required this.flagId,
    required this.flagReason,
    required this.note,
    required this.flaggedBy,
    required this.customerId,
    required this.flaggedAt,
    this.resolvedAt,
  });

  // Factory constructor for creating from Firestore
  factory CustomerFlag.fromFirestore(Map<String, dynamic> data) {
    return CustomerFlag(
      flagId: data['flagId'] as String,
      flagReason: data['flagReason'] as String,
      note: data['note'] as String,
      flaggedBy: data['flaggedBy'] as String,
      customerId: data['customerId'] as String,
      flaggedAt: (data['flaggedAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'flagId': flagId,
      'flagReason': flagReason,
      'note': note,
      'flaggedBy': flaggedBy,
      'customerId': customerId,
      'flaggedAt': Timestamp.fromDate(flaggedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  // Create a new flag (used when CCE submits)
  factory CustomerFlag.create({
    required String flagReason,
    required String note,
    required String flaggedBy,
    required String customerId,
  }) {
    return CustomerFlag(
      flagId: const Uuid().v4(),
      flagReason: flagReason,
      note: note,
      flaggedBy: flaggedBy,
      customerId: customerId,
      flaggedAt: DateTime.now(),
    );
  }

  CustomerFlag copyWith({
    String? flagId,
    String? flagReason,
    String? note,
    String? flaggedBy,
    String? customerId,
    DateTime? flaggedAt,
    DateTime? resolvedAt,
  }) {
    return CustomerFlag(
      flagId: flagId ?? this.flagId,
      flagReason: flagReason ?? this.flagReason,
      note: note ?? this.note,
      flaggedBy: flaggedBy ?? this.flaggedBy,
      customerId: customerId ?? this.customerId,
      flaggedAt: flaggedAt ?? this.flaggedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() {
    return 'CustomerFlag(flagId: $flagId, customerId: $customerId, reason: $flagReason)';
  }
}
