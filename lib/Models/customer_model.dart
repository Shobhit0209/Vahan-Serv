// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Car {
  final String carName;
  final String carType;
  final String numberPlate;
  final String? lastServicedDate;
  final String serviceStatus; // per-car status
  final DateTime? startDate;
  final DateTime? endDate;
  final String? subPlan;
  final String? subPlanFrequency;
  final int? serviceNo;
  final String? assignedCCE;

  Car({
    required this.carName,
    required this.carType,
    required this.numberPlate,
    this.lastServicedDate,
    this.serviceStatus = 'pending',
    this.startDate,
    this.endDate,
    this.subPlan,
    this.subPlanFrequency,
    this.serviceNo,
    this.assignedCCE,
  });

  // carId is now derived from numberPlate
  String get carId => numberPlate;

  Map<String, dynamic> toFirestore() {
    return {
      'carName': carName,
      'carType': carType,
      'numberPlate': numberPlate,
      'lastServicedDate': lastServicedDate,
      'serviceStatus': serviceStatus,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'subPlan': subPlan,
      'subPlanFrequency': subPlanFrequency,
      'serviceNo': serviceNo,
      'assignedCCE': assignedCCE,
    };
  }

  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      carName: data['carName'] ?? '',
      carType: data['carType'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      lastServicedDate: data['lastServicedDate'],
      serviceStatus: data['serviceStatus'] ?? 'pending',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      subPlan: data['subPlan'],
      subPlanFrequency: data['subPlanFrequency'],
      serviceNo: data['serviceNo'],
      assignedCCE: data['assignedCCE'] ?? '',
    );
  }

  // Alternative factory for creating Car from Map (useful for nested data)
  factory Car.fromMap(Map<String, dynamic> data) {
    return Car(
      carName: data['carName'] ?? '',
      carType: data['carType'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      lastServicedDate: data['lastServicedDate'],
      serviceStatus: data['serviceStatus'] ?? 'pending',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      subPlan: data['subPlan'],
      subPlanFrequency: data['subPlanFrequency'],
      serviceNo: data['serviceNo'],
      assignedCCE: data['assignedCCE'] ?? '',
    );
  }

  Color get statusColor {
    switch (serviceStatus.toLowerCase()) {
      case 'completed':
        return Color(0xff4DFF00);
      case 'missed':
        return Color(0xffFF0000);
      case 'pending':
      default:
        return Color(0xffFFFB00);
    }
  }

  String get statusDisplayText {
    switch (serviceStatus.toLowerCase()) {
      case 'completed':
        return 'COM';
      case 'missed':
        return 'MIS';
      case 'pending':
      default:
        return 'PEN';
    }
  }
}

class Customer {
  final String custId;
  final String? custName;
  final String? custAddress;
  final String? custMobile;
  final String? custPhotoUrl;
  final String? completionDate;
  final int? flagged;
  bool? hasUploadedImages;
  List<Map<String, dynamic>>? serviceImages;
  final List<Car>? cars;
  final String? assignedCCE;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? subPlan;
  final String? subPlanFrequency;
  final int? serviceNo;
  final int? numberOfCars;

  Customer(
      {required this.custId,
      required this.custName,
      required this.custAddress,
      required this.custMobile,
      required this.custPhotoUrl,
      required this.completionDate,
      required this.flagged,
      this.startDate,
      this.endDate,
      this.subPlan,
      this.subPlanFrequency,
      this.serviceNo,
      this.cars,
      this.serviceImages,
      this.hasUploadedImages,
      this.numberOfCars,
      this.assignedCCE});

  Map<String, dynamic> toFirestore() {
    return {
      'custId': custId,
      'custName': custName,
      'custAddress': custAddress,
      'custMobile': custMobile,
      'custPhotoUrl': custPhotoUrl,
      'flagged': flagged,
      'completionDate': completionDate,
      'serviceImages': serviceImages,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'subPlan': subPlan,
      'subPlanFrequency': subPlanFrequency,
      'serviceNo': serviceNo ?? 0,
      'cars': cars?.map((car) => car.toFirestore()).toList() ?? [],
      'assignedCCE': assignedCCE,
      'numberOfCars': numberOfCars ?? 1
    };
  }

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (kDebugMode) {
      print('DEBUG: Parsing Customer from Firestore for ID: ${doc.id}');
    }

    List<Map<String, dynamic>>? getServiceImages(dynamic value) {
      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) {
            return e;
          }
          return <String, dynamic>{};
        }).toList();
      }
      return null;
    }

    List<Car>? getCars(dynamic value) {
      if (value is List) {
        return value.map((carData) {
          // Handle both DocumentSnapshot and Map<String, dynamic>
          if (carData is DocumentSnapshot) {
            return Car.fromFirestore(carData);
          } else if (carData is Map<String, dynamic>) {
            return Car.fromMap(carData);
          }
          // Fallback for invalid data
          return Car(
            carName: '',
            carType: '',
            numberPlate: '',
            assignedCCE: '',
          );
        }).toList();
      }
      return null;
    }

    return Customer(
        custId: doc.id,
        custName: data['custName'] ?? '',
        custAddress: data['custAddress'] ?? '',
        custMobile: data['custMobile'],
        custPhotoUrl: data['custPhotoUrl'] ?? '',
        startDate: data['startDate'] != null
            ? (data['startDate'] as Timestamp).toDate()
            : null,
        endDate: data['endDate'] != null
            ? (data['endDate'] as Timestamp).toDate()
            : null,
        subPlan: data['subPlan'],
        subPlanFrequency: data['subPlanFrequency'],
        serviceNo: data['serviceNo'],
        flagged: data['flagged'] ?? 0,
        completionDate: data['completionDate']?.toString(),
        serviceImages: getServiceImages(data['serviceImages']),
        cars: getCars(data['cars']),
        assignedCCE: data['assignedCCE'] ?? '',
        numberOfCars: data['numberOfCars']);
  }

  String get overallStatusDisplayText {
    if (cars == null || cars!.isEmpty) return 'PEN';

    final completedCars =
        cars!.where((car) => car.serviceStatus == 'completed').length;
    final totalCars = cars!.length;

    if (completedCars == totalCars) return 'COM';
    if (completedCars == 0) return 'PEN';
    return 'IN-PRO'; // Partially completed
  }

  Color get overallStatusColor {
    if (cars == null || cars!.isEmpty) return Color(0xffFFFB00);

    final completedCars =
        cars!.where((car) => car.serviceStatus == 'completed').length;
    final totalCars = cars!.length;

    if (completedCars == totalCars) return Color(0xff4DFF00);
    if (completedCars == 0) return Color(0xffFFFB00);
    return Color(0xffFFA500); // Orange for partial completion
  }

  // Get completion percentage
  double get completionPercentage {
    if (cars == null || cars!.isEmpty) return 0.0;

    final completedCars =
        cars!.where((car) => car.serviceStatus == 'completed').length;
    return completedCars / cars!.length;
  }
}
