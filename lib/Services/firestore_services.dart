// ignore_for_file: avoid_types_as_parameter_names, unused_local_variable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Helpers/location_helper.dart';
import 'package:vahanserv/Models/cce_earnings_summary_model.dart';
import 'package:vahanserv/Models/cce_model.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Models/flag_model.dart';
import 'package:vahanserv/Models/cce_earnings_model.dart';
import 'package:vahanserv/Models/uploaded_images_model.dart';
import 'package:vahanserv/Services/notification_services.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  NotificationServices notificationServices = NotificationServices();

  // ===== CCE METHODS =====

  // Get CCE by ID
  Future<CCE?> getCCE(String cceId) async {
    try {
      final docSnapshot = await _firestore.collection('cce').doc(cceId).get();
      if (docSnapshot.exists) {
        return CCE.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getCCEIdByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('cce')
          .where('mobile',
              isEqualTo:
                  phoneNumber) // Assuming 'phone' field stores the number
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Return the document ID (CCE ID)
      }
      return null; // CCE not found with this phone number
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching CCE ID: $e');
      }
      return null; // Or throw an error if you want to handle it differently
    }
  }

  // Update CCE information
  Future<void> updateCCE(String cceId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('cce').doc(cceId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCCELeavesLeft(String cceId, int leavesLeft) async {
    try {
      await _firestore.collection('cce').doc(cceId).update({
        'leavesLeft': leavesLeft,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ===== CUSTOMER METHODS =====

  // Get customers having subscription plan on the current date.
  Future<List<Customer>> getCustomersBySubPlan(
      String cceId, DateTime selectedDate) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      if (kDebugMode) {
        print("Firestore query date: $formattedDate");
      } // Debug

      final snapshot = await _firestore
          .collection('assignedCustomers')
          .where('assignedCCE', isEqualTo: cceId)
          .where('startDate', isLessThanOrEqualTo: selectedDate)
          .where('endDate', isGreaterThanOrEqualTo: selectedDate)
          .get();

      if (kDebugMode) {
        print("Firestore query returned ${snapshot.docs.length} documents");
      } // Debug

      return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Firestore error in getCustomersBySubPlan: $e");
      }
      return []; // Or throw an error if you want to handle it differe  ntly
    }
  }

  // Get customer by custID
  Future<Customer?> getCustomer(String custId) async {
    try {
      final docSnapshot =
          await _firestore.collection('assignedCustomers').doc(custId).get();
      if (docSnapshot.exists) {
        return Customer.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  //get car buy carId

  Future<Car?> getCar(String carId) async {
    try {
      final docSnapshot = await _firestore.collection('cars').doc(carId).get();
      if (docSnapshot.exists) {
        return Car.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  //private method
  Future<List<Customer>> _getCustomersUnderCCE(String cceId) async {
    try {
      if (kDebugMode) {
        print("Fetching customers for CCE: $cceId");
      }

      final snapshot = await _firestore.collection('assignedCustomers').get();

      List<Customer> matchingCustomers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        //  final cars = data['cars'] as List<dynamic>? ?? [];

        if (data['assignedCCE'] == cceId) {
          matchingCustomers.add(Customer.fromFirestore(doc));
        }

//////////////////////////////////////////////CAR ORIENTED METHOD STARTS./////////////////////////////////////////////

        // Check if any car has the matching assignedCCE
        // bool hasMatchingCCE = cars.any((car) =>
        //     car is Map<String, dynamic> && car['assignedCCE'] == cceId);

        // if (hasMatchingCCE) {
        //   matchingCustomers.add(Customer.fromFirestore(doc));
        // }
      }
//////////////////////////////////////////////CAR ORIENTED METHOD ENDS./////////////////////////////////////////////

      if (kDebugMode) {
        print("Found ${matchingCustomers.length} customers for CCE: $cceId");
      }

      return matchingCustomers;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching customers for CCE: $e");
      }
      return [];
    }
  }

  // Get tasks for a specific CCE by date
  Future<List<Customer>> getTasksOfTheDayForCCE(
      String cceId, DateTime date) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      List<Customer> customersUnderCCE = await _getCustomersUnderCCE(cceId);
      if (kDebugMode) {
        print("Firestore query date: $formattedDate");
        print(
            "Checking ${customersUnderCCE.length} customers for today's service");
      } // Debug
      List<Customer> customersWithTodaysService =
          await _getCustomersForCurrentDate(customersUnderCCE, date);
      List<Customer> customerNeedService = [];
      for (Customer customer in customersUnderCCE) {
        //if (customer.cars != null && customer.cars!.isNotEmpty) {}
        // Check if any car needs service today
        // List<Car> carsNeedingService =
        //     await _getCustomerCarsForCurrentDate(customer, date);

        // Create a new customer object with only the cars that need service

        if (customersWithTodaysService.isNotEmpty) {
          Customer finalCustomersneedService = Customer(
            custId: customer.custId,
            custName: customer.custName,
            custAddress: customer.custAddress,
            custMobile: customer.custMobile,
            custPhotoUrl: customer.custPhotoUrl,
            completionDate: customer.completionDate,
            flagged: customer.flagged,
            // cars: carsNeedingService,
            serviceImages: customer.serviceImages,
          );
          customerNeedService.add(finalCustomersneedService);
        } else {
          if (kDebugMode) {
            print(
                "Customer ${customer.custName}'s car will not be served today.");
          }
        }
      }
      return customersWithTodaysService;
    } catch (e) {
      if (kDebugMode) {
        print("Firestore error in getCarTasksByCCEAndDate: $e");
      }
      return []; // Or throw an error if you want to handle it differently
    }
  }

  // Future<List<Car>> getThenumberOfCarsForService(
  //     String cceId, DateTime date) async {
  //   try {
  //     final formattedDate = DateFormat('dd/MM/yyyy').format(date);
  //     List<Customer> allCustomers = await _getCustomersUnderCCE(cceId);
  //     if (kDebugMode) {
  //       print("Firestore query date: $formattedDate");
  //       print("Checking ${allCustomers.length} customers for today's service");
  //     } // Debug
  //     List<Car> carsNeedingService = [];
  //     for (Customer customer in allCustomers) {
  //       if (customer.cars != null && customer.cars!.isNotEmpty) {
  //         // Check if any car needs service today
  //         carsNeedingService =
  //             await _getCustomerCarsForCurrentDate(customer, date);
  //       }
  //     }
  //     return carsNeedingService;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Firestore error in getThenumberOfCarsForService: $e");
  //     }
  //     return []; // Or throw an error if you want to handle it differently
  //   }
  // }

// //CAR ORIENTED METHOD
//   Future<List<Car>> _getCustomerCarsForCurrentDate(
//       Customer customer, DateTime date) async {
//     List<Car> carsNeedingService = [];
//     final DateTime normalizedTargetDate =
//         DateTime(date.year, date.month, date.day);

//     if (_isFirstOrLastSundayOfMonth(normalizedTargetDate)) {
//       if (kDebugMode) {
//         print(
//             'DEBUG: ${DateFormat('dd-MM-yyyy').format(normalizedTargetDate)} is the first or last Sunday of the month. No service required.');
//       }
//       return [];
//     }

//     for (Car car in customer.cars!) {
//       if (!_isCarEligibleForService(car, date)) {
//         continue;
//       }

//       if (_isCarScheduledForService(car, normalizedTargetDate) ||
//           car.serviceStatus == 'completed') {
//         carsNeedingService.add(car);
//         if (car.serviceStatus == 'completed') {
//           if (kDebugMode) {
//             print(
//                 'DEBUG: Car ${car.numberPlate} (${car.carName}) has been served on ${DateFormat('dd-MM-yyyy').format(date)} and status is COMPLETED!.');
//           }
//         } else {
//           if (kDebugMode) {
//             print(
//                 'DEBUG: Car ${car.numberPlate} (${car.carName}) scheduled for service on ${DateFormat('dd-MM-yyyy').format(date)}');
//           }
//         }
//       }
//     }
//     return carsNeedingService;
//   }

  //CUSTOMER ORIENTED METHOD
  //CUSTOMER ORIENTED METHOD
  Future<List<Customer>> _getCustomersForCurrentDate(
      List<Customer> customers, DateTime date) async {
    List<Customer> customersNeedingService = [];

    for (Customer customer in customers) {
      if (!_isCustomerEligibleForService(customer, date)) {
        continue;
      }

      // Check if customer is due for service (including overdue)
      if (_isCustomerDueForService(customer, date)) {
        if (kDebugMode) {
          print(
              "adding ${customer.custName} - due for service on ${DateFormat('dd-MM-yyyy').format(date)}");
        }
        customersNeedingService.add(customer);
      }
    }

    if (kDebugMode) {
      print(
          'length of customer needing service list is ${customersNeedingService.length}');
    }
    return customersNeedingService;
  }

  bool _isCustomerEligibleForService(Customer customer, DateTime targetDate) {
    if (customer.startDate == null ||
        customer.endDate == null ||
        customer.subPlanFrequency == null ||
        customer.serviceNo == null) {
      if (kDebugMode) {
        print(
            "customer.startdate = ${customer.startDate}, customer.enddate= ${customer.endDate}, customer.supplanfreq = ${customer.subPlanFrequency},customer.servicenumber = ${customer.serviceNo} ");
        print(
            'DEBUG: ${customer.custName} has incomplete subscription data. Skipping.');
      }
      return false;
    }

    final DateTime normalizedTargetDate =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final DateTime normalizedStartDate = DateTime(customer.startDate!.year,
        customer.startDate!.month, customer.startDate!.day);
    final DateTime normalizedEndDate = DateTime(
        customer.endDate!.year, customer.endDate!.month, customer.endDate!.day);

    if (normalizedTargetDate.isBefore(normalizedStartDate) ||
        normalizedTargetDate.isAfter(normalizedEndDate)) {
      if (kDebugMode) {
        print(
            'DEBUG: Customer ${customer.custName} subscription not active on ${DateFormat('dd-MM-yyyy').format(targetDate)}');
      }
      return false;
    }

    if (kDebugMode) {
      print(
          'DEBUG: Customer ${customer.custName} subscription is active on ${DateFormat('dd-MM-yyyy').format(targetDate)} and Eligible for service');
    }
    return true;
  }

  bool _isCustomerDueForService(Customer customer, DateTime targetDate) {
    final DateTime normalizedStartDate = DateTime(customer.startDate!.year,
        customer.startDate!.month, customer.startDate!.day);
    final DateTime normalizedTargetDate =
        DateTime(targetDate.year, targetDate.month, targetDate.day);

    // Calculate the last served date and next due date
    DateTime lastServedDate = _getCustomerLastServedDate(
        normalizedStartDate, customer.subPlanFrequency!, customer.serviceNo!);

    bool isAnewCustomer =
        lastServedDate.difference(customer.startDate!).inDays < 0;

    DateTime nextDueDate = _getCustomerNextDueDate(
        normalizedStartDate, customer.subPlanFrequency!, customer.serviceNo!);

    // Customer is due if target date is on or after the next due date
    bool isDue = normalizedTargetDate.isAtSameMomentAs(nextDueDate) ||
        normalizedTargetDate.isAfter(nextDueDate); // ;

    if (kDebugMode) {
      print('DEBUG: Customer ${customer.custName}:');
      print(
          '  - Start Date: ${DateFormat('dd-MM-yyyy').format(normalizedStartDate)}');
      print('  - Number of times Served: ${customer.serviceNo}');
      isAnewCustomer
          ? print('  -First Day to serve')
          : print(
              '  - Last Served Date: ${DateFormat('dd-MM-yyyy').format(lastServedDate)}');
      print(
          '  - Next Due Date: ${DateFormat('dd-MM-yyyy').format(nextDueDate)}');
      print(
          '  - Target Date: ${DateFormat('dd-MM-yyyy').format(normalizedTargetDate)}');
      print('  - Frequency: ${customer.subPlanFrequency}');
      print('  - Is Due for today: $isDue');

      if (isDue && normalizedTargetDate.isAfter(nextDueDate)) {
        int daysMissed = normalizedTargetDate.difference(lastServedDate).inDays;
        print('  - OVERDUE by $daysMissed days.');
      }
    }

    return isDue;
  }

// Get the date when customer was last served
  DateTime _getCustomerLastServedDate(
      DateTime startDate, String frequency, int timesServed) {
    if (timesServed == 0) {
      // If never served, return a date before start date to indicate no service yet
      return startDate.subtract(Duration(days: 1));
    }

    DateTime lastServedDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    switch (frequency.toLowerCase()) {
      case 'daily':
        // If served 1 time = Day 0 (start date)
        // If served 2 times = Day 1, etc.
        lastServedDate = lastServedDate.add(Duration(days: timesServed - 1));
        break;
      case 'alternate':
        // If served 1 time = Day 0 (start date)
        // If served 2 times = Day 2, If served 3 times = Day 4, etc.
        lastServedDate =
            lastServedDate.add(Duration(days: (timesServed - 1) * 2));
        break;
      case 'weekly':
        // If served 1 time = Day 0 (start date)
        // If served 2 times = Day 7, If served 3 times = Day 14, etc.
        lastServedDate =
            lastServedDate.add(Duration(days: (timesServed - 1) * 7));
        break;
      case 'monthly':
        // If served 1 time = Month 0 (start month)
        // If served 2 times = Month 1, etc.
        lastServedDate = DateTime(
            startDate.year, startDate.month + (timesServed - 1), startDate.day);
        break;
      default:
        if (kDebugMode) {
          print('DEBUG: Unknown frequency: $frequency, defaulting to daily');
        }
        lastServedDate = lastServedDate.add(Duration(days: timesServed - 1));
    }

    return lastServedDate;
  }

// Get the next due date for service
  DateTime _getCustomerNextDueDate(
      DateTime startDate, String frequency, int timesServed) {
    DateTime nextDueDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    switch (frequency.toLowerCase()) {
      case 'daily':
        // Next service = current served count
        nextDueDate = nextDueDate.add(Duration(days: timesServed));
        break;
      case 'alternate':
        // Next service on alternate days
        nextDueDate = nextDueDate.add(Duration(days: timesServed * 2));
        break;
      case 'weekly':
        // Next service weekly
        nextDueDate = nextDueDate.add(Duration(days: timesServed * 7));
        break;
      case 'monthly':
        // Next service monthly
        nextDueDate = DateTime(
            startDate.year, startDate.month + timesServed, startDate.day);
        break;
      default:
        if (kDebugMode) {
          print('DEBUG: Unknown frequency: $frequency, defaulting to daily');
        }
        nextDueDate = nextDueDate.add(Duration(days: timesServed));
    }

    return nextDueDate;
  }

  //mark customer as unavailable
  Future<void> markCCEAsUnavailable(
      String cceId, String dateStr, int leavesLeft) async {
    await _firestore.collection('cceLeaves').doc('${cceId}_$dateStr').set({
      'cceId': cceId,
      'date': dateStr,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('cce').doc(cceId).update({
      'isActive': false,
      'lastInactiveTime': FieldValue.serverTimestamp(),
      'leavesLeft': leavesLeft,
    });

    if (kDebugMode) {
      print(
          '✅ STEP 1: CCE leave added to cceLeaves collection and marked as inactive');
    }
  }

  Future<void> extendAssignedCustomerSubscriptionsByOneDay(
      String cceId, DateTime currentDate) async {
    // Get all customers with active subscriptions (endDate >= today)
    QuerySnapshot activeCustomers = await _firestore
        .collection('assignedCustomers')
        .where('assignedCCE', isEqualTo: cceId)
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
        .get();

    if (activeCustomers.docs.isEmpty) {
      if (kDebugMode) {
        print('ℹ️ No active customers found to extend subscriptions');
      }
      return;
    }

    // Batch write for better performance
    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot customerDoc in activeCustomers.docs) {
      Map<String, dynamic> customerData =
          customerDoc.data() as Map<String, dynamic>;

      // Get current end date and extend by 1 day
      DateTime currentEndDate = (customerData['endDate'] as Timestamp).toDate();
      DateTime newEndDate = currentEndDate.add(Duration(days: 1));

      // Update customer's end date
      batch.update(customerDoc.reference, {
        'endDate': Timestamp.fromDate(newEndDate),
      });

      if (kDebugMode) {
        print('📅 Extending subscription for customer ${customerDoc.id}');
        print(
            '   Old end date: ${DateFormat('dd-MM-yyyy').format(currentEndDate)}');
        print(
            '   New end date: ${DateFormat('dd-MM-yyyy').format(newEndDate)}');
      }
    }

    // Commit all updates
    await batch.commit();

    if (kDebugMode) {
      print(
          '✅ STEP 2: Extended subscription end dates for ${activeCustomers.docs.length} customers');
    }
  }

  Future<void> decrementAssignedCustomerSubscriptionsByOneDay(
      String cceId, DateTime currentDate) async {
    QuerySnapshot activeCustomers = await _firestore
        .collection('assignedCustomers')
        .where('assignedCCE', isEqualTo: cceId)
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
        .get();

    if (activeCustomers.docs.isEmpty) {
      if (kDebugMode) {
        print('ℹ️ No active customers found to extend subscriptions');
      }
      return;
    }

    // Batch write for better performance
    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot customerDoc in activeCustomers.docs) {
      Map<String, dynamic> customerData =
          customerDoc.data() as Map<String, dynamic>;

      // Get current end date and extend by 1 day
      DateTime currentEndDate = (customerData['endDate'] as Timestamp).toDate();
      DateTime newEndDate = currentEndDate.subtract(Duration(days: 1));

      // Update customer's end date
      batch.update(customerDoc.reference, {
        'endDate': Timestamp.fromDate(newEndDate),
      });

      if (kDebugMode) {
        print('📅 Decrementing subscription for customer ${customerDoc.id}');
        print(
            '   Old end date: ${DateFormat('dd-MM-yyyy').format(currentEndDate)}');
        print(
            '   New end date: ${DateFormat('dd-MM-yyyy').format(newEndDate)}');
      }
    }

    // Commit all updates
    await batch.commit();

    if (kDebugMode) {
      print(
          '✅ STEP 2: Decremented subscription end dates for ${activeCustomers.docs.length} customers');
    }
  }

  //////////////////////////////////////////////CAR ORIENTED METHOD STARTS./////////////////////////////////////////////

  // bool _isCarEligibleForService(Car car, DateTime targetDate) {
  //   // Check if car has required subscription data
  //   if (car.startDate == null ||
  //       car.endDate == null ||
  //       car.subPlanFrequency == null ||
  //       car.serviceNo == null) {
  //     if (kDebugMode) {
  //       print(
  //           '${car.startDate} ; ${car.endDate} ; ${car.subPlanFrequency} ; ${car.serviceNo}');
  //       print(
  //           'DEBUG: Car ${car.numberPlate} has incomplete subscription data. Skipping.');
  //     }
  //     return false;
  //   }

  //   // Check if target date is within subscription period
  //   final DateTime normalizedTargetDate =
  //       DateTime(targetDate.year, targetDate.month, targetDate.day);
  //   final DateTime normalizedStartDate =
  //       DateTime(car.startDate!.year, car.startDate!.month, car.startDate!.day);
  //   final DateTime normalizedEndDate =
  //       DateTime(car.endDate!.year, car.endDate!.month, car.endDate!.day);

  //   if (normalizedTargetDate.isBefore(normalizedStartDate) ||
  //       normalizedTargetDate.isAfter(normalizedEndDate)) {
  //     if (kDebugMode) {
  //       print(
  //           'DEBUG: Car ${car.numberPlate} subscription not active on ${DateFormat('dd-MM-yyyy').format(targetDate)}');
  //     }
  //     return false;
  //   }
  //   if (kDebugMode) {
  //     print(
  //         'DEBUG: Car ${car.numberPlate} subscription is active on ${DateFormat('dd-MM-yyyy').format(targetDate)} and Eligible for service');
  //   }
  //   return true;
  // }

//   bool _isCarScheduledForService(Car car, DateTime targetDate) {
//     final DateTime normalizedStartDate =
//         DateTime(car.startDate!.year, car.startDate!.month, car.startDate!.day);

//     // Calculate next service date
//     DateTime nextServiceDate = _getNextCarServiceDate(
//         normalizedStartDate, car.subPlanFrequency!, car.serviceNo!);

//     return _isSameDate(nextServiceDate, targetDate);
//   }

// // Helper method to calculate next service date for a car
//   DateTime _getNextCarServiceDate(
//       DateTime startDate, String frequency, int serviceNo) {
//     DateTime nextDate =
//         DateTime(startDate.year, startDate.month, startDate.day);

//     switch (frequency.toLowerCase()) {
//       case 'daily':
//         nextDate = nextDate.add(Duration(days: serviceNo));
//         break;
//       case 'alternate':
//         nextDate = nextDate.add(Duration(days: serviceNo * 2));
//         break;
//       default:
//         if (kDebugMode) {
//           print('DEBUG: Unknown frequency: $frequency, defaulting to daily');
//         }
//         nextDate = nextDate.add(Duration(days: serviceNo));
//     }
//     if (kDebugMode) {
//       print('next service date: ${nextDate.toString()}');
//     }
//     return nextDate;
//   }

// // Helper method to check if two dates are the same day
//   bool _isSameDate(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

//   bool _isFirstOrLastSundayOfMonth(DateTime date) {
//     if (date.weekday != DateTime.sunday) {
//       return false; // Agar Sunday nahi hai, toh false
//     }
//     final int dayOfMonth = date.day;
//     final int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
//     if (dayOfMonth <= 7) {
//       return true;
//     }
//     if (dayOfMonth >= (daysInMonth - 6)) {
//       return true;
//     }
//     return false;
//   }

//////////////////////////////////////////////CAR ORIENTED METHOD STARTS./////////////////////////////////////////////

  // Get all tasks for a specific CCE
  Future<List<Customer>> getAllCustomersUnderCCE(String cceId) async {
    try {
      final snapshot = await _firestore
          .collection('assignedCustomers')
          .where('assignedCCE', isEqualTo: cceId)
          .get();
      return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String custId, int serviceNo) async {
    try {
      final batch = _firestore.batch();
      final customerDocRef =
          _firestore.collection('assignedCustomers').doc(custId);
      final docSnapshot = await customerDocRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Customer with ID $custId not found.');
      }

      final customerData = docSnapshot.data();
      final String customerName =
          customerData?['custName'] ?? 'Unknown Customer';
      final String assignedCCE = customerData?['assignedCCE'] ?? '';
      final String address = customerData?['custAddress'] ?? '';

      // Get the cars array
      // final List<dynamic>? carsData = customerData?['cars'];
      // if (carsData == null || carsData.isEmpty) {
      //   throw Exception('No cars found for customer $custId');
      // }

      // // Find and update the specific car
      // bool carFound = false;
      // List<Map<String, dynamic>> updatedCars = [];

      // for (var carData in carsData) {
      //   Map<String, dynamic> car = Map<String, dynamic>.from(carData);

      //   if (car['numberPlate'] == carId) {
      //     // Update the specific car's status

      //     //car['serviceStatus'] = newStatus;
      //     car['lastServiced'] = completionDate;
      //     car['serviceNo'] = serviceNo + 1;
      //     carFound = true;

      //     // If task is marked as completed, create earning entry for this specific car
      //     // if (newStatus == 'completed') {
      //     //   await _createCarEarningEntry(
      //     //     custId: custId,
      //     //     carId: carId,
      //     //     customerName: customerName,
      //     //     assignedCCE: assignedCCE,
      //     //     carName: car['carName'] ?? 'Unknown Car',
      //     //     address: address,
      //     //     subPlan: car['subPlan'] ?? 'General Service',
      //     //     serviceNo: serviceNo,
      //     //   );
      //     // }
      //   }

      //   updatedCars.add(car);
      // }

      // if (!carFound) {
      //   throw Exception('Car with ID $carId not found for customer $custId');
      // }

      // Calculate overall customer status and completion percentage
      // final overallStatus = _calculateOverallCustomerStatus(updatedCars);
      //  final completionPercentage = _calculateCompletionPercentage(updatedCars);

      // Update the customer document with updated cars array and overall status
      final updateCustomerData = {
        //'cars': updatedCars,
        //'overallStatus': overallStatus,
        // 'completionPercentage': completionPercentage,
        'lastUpdated': FieldValue.serverTimestamp(),
        'serviceNo': customerData!['serviceNo'] + 1
      };
      batch.update(customerDocRef, updateCustomerData);
      await customerDocRef.update(updateCustomerData);

      // final carDocRef = _firestore.collection('cars').doc(carId);
      // final carUpdateData = {
      //   // 'serviceStatus': newStatus,
      //   'lastServiced': completionDate,
      //   'serviceNo': serviceNo + 1,
      //   'lastUpdated': FieldValue.serverTimestamp(),
      // };

      // batch.update(carDocRef, carUpdateData);
      // await batch.commit();

      // if (kDebugMode) {
      //   print(
      //       'Status updated in both collections for customer and car: $customerName, car: $carId');
      // }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating car status: $e');
      }
      rethrow;
    }
  }

  // Helper function to calculate overall customer status based on individual car statuses
  // ignore: unused_element
  String _calculateOverallCustomerStatus(List<Map<String, dynamic>> cars) {
    if (cars.isEmpty) return 'pending';

    int completedCount = 0;
    int inProgressCount = 0;

    for (var car in cars) {
      final status = car['serviceStatus'] ?? 'pending';
      if (status == 'completed') {
        completedCount++;
      } else if (status == 'in_progress') {
        inProgressCount++;
      }
    }

    if (completedCount == cars.length) {
      return 'completed';
    } else if (inProgressCount > 0 || completedCount > 0) {
      return 'pending';
    } else {
      return 'pending';
    }
  }

  // ignore: unused_element
  double _calculateCompletionPercentage(List<Map<String, dynamic>> cars) {
    if (cars.isEmpty) return 0.0;

    int completedCount =
        cars.where((car) => car['serviceStatus'] == 'completed').length;
    return completedCount / cars.length;
  }

// Helper function to create earning entry for individual car completion
  // ignore: unused_element
  Future _createCarEarningEntry({
    required String custId,
    required String carId,
    required String customerName,
    required String assignedCCE,
    required String carName,
    required String address,
    required String subPlan,
    required int serviceNo,
  }) async {
    try {
      final String earningId = _firestore.collection('cceEarnings').doc().id;
      if (kDebugMode) {
        print(earningId);
      }

      final Map<String, dynamic> earningData = {
        'earningId': earningId,
        'cceId': assignedCCE,
        'customerId': custId,
        'customerName': customerName,
        'taskName': subPlan,
        'amount': _calculateTaskEarning(
            subPlan), // You might want to adjust this for per-car calculation
        'time': FieldValue.serverTimestamp(),
        'status': 'approved',
        'description':
            'Car service completion earning for $customerName - $carName ($carId)',
        'carName': carName,
        'address': address,
        'numberPlate': carId,
        'serviceNo': serviceNo,
        'metadata': {},
      };

      await _createEarningsEntry(earningData, earningId);

      if (kDebugMode) {
        print('Car earning entry created for $customerName - $carName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating car earning entry: $e');
      }
      // Don't rethrow here to avoid breaking the main flow
    }
  }

  Future<void> _createEarningsEntry(
      Map<String, dynamic> earnings, String earningId) async {
    try {
      await _firestore.collection('cceEarnings').doc(earningId).set(earnings);

      // Update CCE earnings summary
      //await _updateCCEEarningsSummary(earnings.cceId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfCarHasUploadedImages(
    String custId, {
    required DateTime uploadedOnOrAfterDate,
  }) async {
    try {
      DocumentSnapshot carDoc =
          await _firestore.collection('assignedCustomers').doc(custId).get();

      if (!carDoc.exists) {
        if (kDebugMode) {
          print('Car $custId document not found in cars collection.');
        }
        return false; // Car document doesn't exist
      }

      final Map<String, dynamic>? docData =
          carDoc.data() as Map<String, dynamic>?;

      if (docData == null || !docData.containsKey('serviceImages')) {
        if (kDebugMode) {
          print(
              'Car $custId document exists, but "serviceImages" field is missing or null.');
        }
        return false; // Field is missing or null
      }

      final dynamic rawServiceImagesData = docData['serviceImages'];

      List<Map<String, dynamic>>? serviceImagesList;

      // Check if it's already the correct List<Map<String, dynamic>>
      if (rawServiceImagesData is List) {
        // It's a list, but might contain non-map elements or be nested.
        List<Map<String, dynamic>> tempParsedList = [];
        bool containsValidMaps = false;

        for (var item in rawServiceImagesData) {
          // Handle potential nested lists from old data (if any still exist)
          if (item is List) {
            if (kDebugMode) {
              print(
                  'DEBUG: Found nested list in serviceImagesData. Attempting to flatten.');
            }
            for (var nestedItem in item) {
              if (nestedItem is Map<String, dynamic>) {
                tempParsedList.add(nestedItem);
                containsValidMaps = true;
              } else {
                if (kDebugMode) {
                  print(
                      'DEBUG: Nested item is not a Map<String, dynamic>: $nestedItem (Type: ${nestedItem.runtimeType})');
                }
              }
            }
          }
          // Handle direct maps (the desired current structure)
          else if (item is Map<String, dynamic>) {
            tempParsedList.add(item);
            containsValidMaps = true;
          } else {
            if (kDebugMode) {
              print(
                  'DEBUG: Unexpected item type in serviceImagesData: $item (Type: ${item.runtimeType})');
            }
          }
        }

        if (containsValidMaps) {
          serviceImagesList = tempParsedList;
        }
      }

      if (serviceImagesList == null || serviceImagesList.isEmpty) {
        if (kDebugMode) {
          print(
              'Customer $custId has no valid service images (list is null, empty, or contains no maps).');
        }
        return false;
      }

      // Normalize the date to compare only year, month, and day, ignoring time.
      final DateTime normalizedCheckDate = DateTime(
        uploadedOnOrAfterDate.year,
        uploadedOnOrAfterDate.month,
        uploadedOnOrAfterDate.day,
      );

      // Iterate through each image map in the list to find a match.
      for (var item in serviceImagesList) {
        // Ensure the item is a map and contains the 'uploadedDate' key.
        if (item.containsKey('uploadedDate')) {
          final dynamic uploadedDateValue = item['uploadedDate'];

          // Ensure the 'uploadedDate' value is a Firestore Timestamp.
          if (uploadedDateValue is Timestamp) {
            final DateTime actualUploadDate = uploadedDateValue.toDate();
            // Normalize the actual upload date from Firestore for day-level comparison.
            final DateTime normalizedActualUploadDate = DateTime(
              actualUploadDate.year,
              actualUploadDate.month,
              actualUploadDate.day,
            );

            // Check if the image was uploaded on or after the specified date.
            if (normalizedActualUploadDate
                    .isAtSameMomentAs(normalizedCheckDate) ||
                normalizedActualUploadDate.isAfter(normalizedCheckDate)) {
              if (kDebugMode) {
                print(
                    'Customer $custId has images uploaded on or after ${uploadedOnOrAfterDate.toLocal()}.');
              }
              return true; // Found at least one image matching the criteria.
            }
          } else {
            if (kDebugMode) {
              print(
                  'Warning: uploadedDate for an item in serviceImages is not a Timestamp for Customer $custId: $uploadedDateValue (Type: ${uploadedDateValue.runtimeType})');
            }
          }
        } else {
          if (kDebugMode) {
            print(
                'Warning: An item in serviceImages for Customer $custId does not contain uploadedDate key: $item');
          }
        }
      }
      // If the loop completes, no images were found that match the date criteria.
      if (kDebugMode) {
        print(
            'Customer $custId has images, but none match the date criteria (${uploadedOnOrAfterDate.toLocal()}).');
      }
      return false;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
            'Firebase Error checking for uploaded images for car $custId: ${e.code} - ${e.message}');
      }
      return false; // Assume no images if there's a Firebase error.
    } catch (e) {
      if (kDebugMode) {
        print('General Error checking for uploaded images for car $custId: $e');
      }
      return false; // Assume no images if there's a general error.
    }
  }

  Future<List<String>> getUploadedImageUrlsForCustomer(
      String custId, String cceId) async {
    try {
      final querySnapshot = await _firestore
          .collection('uploadedImages')
          .where('custId', isEqualTo: custId)
          .where('uploadedByCCE', isEqualTo: cceId)
          .orderBy('uploadedDate', descending: true) // Get latest uploads first
          .get();
      List<String> allImageUrls = [];
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data.containsKey('imageURLs')) {
            // Add all image URLs from this document's 'imageURLs' array
            // to our master list
            allImageUrls.addAll(List<String>.from(data['imageURLs']));
          }
        }
      }
      return allImageUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting uploaded image URLs for $custId: $e');
      }
      return [];
    }
  }

  // Mark task as missed
  Future<void> markTaskAsMissed(String taskId, bool isMissed) async {
    try {
      await _firestore.collection('assignedTasks').doc(taskId).update({
        'isMissed': isMissed,
        'missedAt': isMissed ? FieldValue.serverTimestamp() : null,
      });

      // If marking as missed, create a penalty earning entry
      if (isMissed) {
        final taskDoc =
            await _firestore.collection('assignedTasks').doc(taskId).get();
        if (taskDoc.exists) {
          final taskData = taskDoc.data() as Map<String, dynamic>;
          await _createMissedTaskPenalty(taskId, taskData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload task completion image and update URL

  Future<void> addUploadedImageBatchDetails({
    required String imageUrl,
    required String custId,
    required String uploadedByCCE,
  }) async {
    try {
      if (kDebugMode) {
        print('Adding new image to serviceImages array for custId: $custId');
      }

      Map<String, dynamic> locationData =
          await CCELocationHelper.getLocationForImageUpload();

      // Create the new image object with timestamp
      final newImageData = {
        'imageUrl': imageUrl,
        'uploadedDate': Timestamp.now(),
        'uploadedBy': uploadedByCCE,
        'latitude': locationData['lat'],
        'longitude': locationData['long'],
      };

      if (!locationData['hasLocation']) {
        newImageData['locationError'] = locationData['error'];
      }

      // Use arrayUnion to add the new image to the serviceImages array
      // This will create the array if it doesn't exist, or append to existing array
      await _firestore.collection('assignedCustomers').doc(custId).update({
        'serviceImages': FieldValue.arrayUnion([newImageData]),
      });

      if (kDebugMode) {
        print(
            'Successfully added new service image to customer document: $imageUrl');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
            'Firebase Error (addUploadedImageBatchDetails): ${e.code} - ${e.message}');
      }
      rethrow; // Re-throw the error to be caught by the calling provider
    } catch (e) {
      if (kDebugMode) {
        print('General Error (addUploadedImageBatchDetails): $e');
      }
      rethrow;
    }
  }

  // ===== EARNINGS METHODS =====

  // Get CCE earnings stream
  Future<List<CCEEarnings>> getCCEEarnings(String cceId) async {
    try {
      final snapshot = await _firestore
          .collection('cceEarnings')
          .where('cceId', isEqualTo: cceId)
          .orderBy('time', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => CCEEarnings.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get CCE earnings for a specific date range
  Future<List<CCEEarnings>> getCCEEarningsInRange(
    String cceId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('cceEarnings')
          .where('cceId', isEqualTo: cceId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('time', isLessThanOrEqualTo: endDate)
          .orderBy('time', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CCEEarnings.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get CCE earnings summary
  Future<CCEEarningsSummary?> getCCEEarningsSummary(String cceId) async {
    try {
      final docSnapshot =
          await _firestore.collection('cceEarningsSummary').doc().get();
      if (docSnapshot.exists) {
        return CCEEarningsSummary.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCCETotals(String cceId) async {
    try {
      // Get all earnings for this CCE
      final earningsSnapshot = await _firestore
          .collection('cceEarnings')
          .where('cceId', isEqualTo: cceId)
          .get();

      // Get current CCE document
      final cceDoc = await _firestore.collection('cce').doc(cceId).get();

      // Check if document exists
      if (!cceDoc.exists) {
        if (kDebugMode) {
          print('CCE document not found: $cceId');
        }
        return;
      }

      final cceData = cceDoc.data()!;
      final lastUpdated = cceData['lastUpdated'] as Timestamp?;

      double todayTotal = 0.0;
      double monthlyTotal = 0.0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final monthStart = DateTime(now.year, now.month, 1);

      // Handle month end correctly (avoid December overflow)
      final monthEnd = now.month == 12
          ? DateTime(now.year + 1, 1, 1).subtract(Duration(milliseconds: 1))
          : DateTime(now.year, now.month + 1, 1)
              .subtract(Duration(milliseconds: 1));

      // Determine if we need to reset totals
      bool shouldResetDaily = false;
      bool shouldResetMonthly = false;

      if (lastUpdated != null) {
        final lastUpdateDate = lastUpdated.toDate();
        final lastUpdateDay = DateTime(
            lastUpdateDate.year, lastUpdateDate.month, lastUpdateDate.day);
        final lastUpdateMonth =
            DateTime(lastUpdateDate.year, lastUpdateDate.month, 1);

        // Reset daily if last update was on a different day
        shouldResetDaily = lastUpdateDay.isBefore(todayStart);

        // Reset monthly if last update was in a different month
        shouldResetMonthly = lastUpdateMonth.isBefore(monthStart);
      } else {
        // If no last update, we need to calculate everything from scratch
        shouldResetDaily = true;
        shouldResetMonthly = true;
      }

      // Handle daily reset - start fresh for new day
      if (shouldResetDaily) {
        todayTotal = 0.0; // Reset to 0 for new day

        if (kDebugMode) {
          print('Daily earnings reset to 0 for CCE: $cceId (new day detected)');
        }
      } else {
        // Same day - start with existing total
        todayTotal = (cceData['todayEarning'] as num?)?.toDouble() ?? 0.0;
      }

      // Handle monthly reset
      if (shouldResetMonthly) {
        monthlyTotal = 0.0; // Reset to 0 for new month

        if (kDebugMode) {
          print(
              'Monthly earnings reset to 0 for CCE: $cceId (new month detected)');
        }
      } else {
        // Same month - start with existing total
        monthlyTotal = (cceData['monthlyEarning'] as num?)?.toDouble() ?? 0.0;
      }

      // Now add relevant earnings based on reset status
      for (var doc in earningsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['time'] as Timestamp?;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        if (timestamp != null) {
          final earningDate = timestamp.toDate();

          // For monthly totals
          if (shouldResetMonthly) {
            // If month reset, add all earnings from current month
            if (earningDate
                    .isAfter(monthStart.subtract(Duration(milliseconds: 1))) &&
                earningDate.isBefore(monthEnd.add(Duration(milliseconds: 1)))) {
              monthlyTotal += amount;
            }
          } else {
            // If no month reset, add only new earnings since last update
            if (lastUpdated != null &&
                earningDate.isAfter(lastUpdated.toDate())) {
              if (earningDate.isAfter(
                      monthStart.subtract(Duration(milliseconds: 1))) &&
                  earningDate
                      .isBefore(monthEnd.add(Duration(milliseconds: 1)))) {
                monthlyTotal += amount;
              }
            }
          }

          // For daily totals
          if (shouldResetDaily) {
            // If day reset, add all earnings from today only
            if (earningDate
                    .isAfter(todayStart.subtract(Duration(milliseconds: 1))) &&
                earningDate.isBefore(todayEnd.add(Duration(milliseconds: 1)))) {
              todayTotal += amount;
            }
          } else {
            // If no day reset, add only new earnings since last update that are from today
            if (lastUpdated != null &&
                earningDate.isAfter(lastUpdated.toDate())) {
              if (earningDate.isAfter(
                      todayStart.subtract(Duration(milliseconds: 1))) &&
                  earningDate
                      .isBefore(todayEnd.add(Duration(milliseconds: 1)))) {
                todayTotal += amount;
              }
            }
          }
        }
      }

      // Update CCE document with calculated totals
      await _firestore.collection('cce').doc(cceId).update({
        'todayEarning': todayTotal,
        'monthlyEarning': monthlyTotal,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('CCE totals updated for $cceId:');
        print(
            '  Today: Rs. $todayTotal ${shouldResetDaily ? '(reset applied)' : '(incremental)'}');
        print(
            '  Monthly: Rs. $monthlyTotal ${shouldResetMonthly ? '(reset applied)' : '(incremental)'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating CCE totals: $e');
      }
      rethrow;
    }
  }

  Future<void> resetAllDailyEarnings() async {
    try {
      final cceSnapshot = await _firestore.collection('cce').get();

      if (kDebugMode) {
        print('Starting daily reset for ${cceSnapshot.docs.length} CCEs');
      }

      for (var doc in cceSnapshot.docs) {
        await updateCCETotals(doc.id);
      }

      if (kDebugMode) {
        print('Daily reset completed for all CCEs');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during daily reset: $e');
      }
      rethrow;
    }
  }

// Helper function to schedule daily reset (call this at app startup or use a scheduler)
  void scheduleDailyReset() {
    Timer.periodic(Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      // Check if it's midnight (00:00) - adjust time as needed
      if (now.hour == 0 && now.minute < 5) {
        if (kDebugMode) {
          print('Midnight detected - triggering daily reset');
        }
        await resetAllDailyEarnings();
      }
      if (kDebugMode) {
        print('Its not midnight');
      }
    });
  }

  // Create referral earning
  Future<void> createReferralEarning(
    String cceId,
    String cceName,
    String referredCCEId,
    String referredCCEName,
    double amount,
  ) async {
    try {
      final earnings = CCEEarnings(
        earningId: '',
        cceId: cceId,
        taskId: 'referral_$referredCCEId',
        customerId: '',
        customerName: '',
        taskName: 'Referral Bonus',
        amount: amount,
        time: Timestamp.now(),
        earningType: 'referral',
        status: 'approved',
        description: 'Referral bonus for $referredCCEName',
        metadata: {
          'referredCCEId': referredCCEId,
          'referredCCEName': referredCCEName,
        },
        numberPlate: '',
        serviceNo: null,
        address: '',
      );

      //await _createEarningsEntry(earnings);
    } catch (e) {
      rethrow;
    }
  }

  // ===== PRIVATE HELPER METHODS =====

  // Create task completion earning
  Future<void> createTaskCompletionEarning(
      Map<String, dynamic> earningData) async {
    try {
      // Calculate earning amount based on task type
      double amount = _calculateTaskEarning(earningData['taskName'] ?? 0.0);

      final earnings = CCEEarnings(
        earningId: earningData['earningId'],
        cceId: earningData['asssignedToCCE'] ?? '',
        taskId: '',
        customerId: earningData['customerId'] ?? '',
        customerName: earningData['customerName'] ?? '',
        taskName: earningData['taskName'] ?? '',
        amount: amount,
        time: Timestamp.now(),
        earningType: 'task_completion',
        status: 'approved',
        description: 'Task completion earning',
        metadata: {},
        numberPlate: '',
        serviceNo: null,
        address: '',
      );

      // await _createEarningsEntry(earnings);
    } catch (e) {
      rethrow;
    }
  }

  // Create missed task penalty
  Future<void> _createMissedTaskPenalty(
      String taskId, Map<String, dynamic> taskData) async {
    try {
      // Calculate penalty amount
      double penaltyAmount =
          _calculateMissedTaskPenalty(taskData['taskName'] ?? '');

      final earnings = CCEEarnings(
        earningId: '',
        cceId: taskData['asssignedToCCE'] ?? '',
        taskId: taskId,
        customerId: taskData['servedCustomer'] ?? '',
        customerName: taskData['customerName'] ?? '',
        taskName: taskData['taskName'] ?? '',
        amount: penaltyAmount,
        time: Timestamp.now(),
        earningType: 'penalty',
        status: 'approved',
        description: 'Penalty for missed task',
        metadata: {
          'taskDate': taskData['taskDate'],
          'location': taskData['location'],
        },
        numberPlate: '',
        serviceNo: null,
        address: '',
      );

      //await _createEarningsEntry(earnings);
    } catch (e) {
      rethrow;
    }
  }

  // Calculate task earning based on task type
  double _calculateTaskEarning(String subPlan) {
    Map<String, double> taskRates = {
      'Hatchback Plan': 36.0,
      'Hatchback Alternate Plan': 36.0, // Rs. 599/month
      'Hatchback Daily Plan': 31.0, // Rs. 999/month
      '5 Seater Alternate SUV Plan': 45.0, // Rs. 699/month
      '5 Seater Daily SUV Plan': 38.0, // Rs. 1199/month
      '7 Seater Alternate SUV Plan': 50.0, // Rs. 799/month
      '7 Seater Daily SUV Plan': 45.0, // Rs. 1399/month
      'Sedan Plan': 40.0,
      'Interior Clean': 75.0,
      'Wax & Polish': 100.0,
    };

    return taskRates[subPlan] ?? 0.0; // Default rate
  }

  // Calculate penalty for missed task
  double _calculateMissedTaskPenalty(String taskName) {
    // Penalty is usually 50% of the earning rate
    return _calculateTaskEarning(taskName) * 0.5;
  }

  // Update CCE earnings summary
  // Future<void> _updateCCEEarningsSummary(String cceId) async {
  //   try {
  //     final now = DateTime.now();
  //     final today = DateTime(now.year, now.month, now.day);
  //     final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  //     final startOfMonth = DateTime(now.year, now.month, 1);

  //     // Get daily earnings
  //     //final dailyEarnings = await getCCEDailyEarnings(cceId, today);

  //     // Get weekly earnings
  //     final weeklyEarnings =
  //         await getCCEEarningsInRange(cceId, startOfWeek, now);
  //     final weeklyTotal = weeklyEarnings.fold<double>(0, (sum, earning) {
  //       return sum +
  //           (earning.earningType == 'penalty'
  //               ? -earning.amount!
  //               : earning.amount!);
  //     });

  //     // Get monthly earnings
  //     final monthlyTotal = await getCCEMonthlyEarnings(cceId, now);

  //     // Get all earnings for totals
  //     final allEarnings = await _firestore
  //         .collection('cceEarnings')
  //         .where('cceId', isEqualTo: cceId)
  //         .where('status', whereIn: ['approved', 'paid']).get();

  //     double totalEarnings = 0;
  //     double pendingAmount = 0;
  //     double paidAmount = 0;
  //     int totalTasks = 0;
  //     int totalReferrals = 0;

  //     for (var doc in allEarnings.docs) {
  //       final data = doc.data();
  //       final amount = (data['amount'] as num).toDouble();
  //       final earningType = data['earningType'] as String;
  //       final status = data['status'] as String;

  //       if (earningType == 'penalty') {
  //         totalEarnings -= amount;
  //       } else {
  //         totalEarnings += amount;
  //       }

  //       if (status == 'pending') {
  //         pendingAmount += amount;
  //       } else if (status == 'paid') {
  //         paidAmount += amount;
  //       }

  //       if (earningType == 'task_completion') {
  //         totalTasks++;
  //       } else if (earningType == 'referral') {
  //         totalReferrals++;
  //       }
  //     }

  //     final summary = CCEEarningsSummary(
  //       cceId: cceId,
  //       dailyEarnings: dailyEarnings,
  //       weeklyEarnings: weeklyTotal,
  //       monthlyEarnings: monthlyTotal,
  //       totalEarnings: totalEarnings,
  //       totalTasksCompleted: totalTasks,
  //       totalReferrals: totalReferrals,
  //       pendingAmount: pendingAmount,
  //       paidAmount: paidAmount,
  //       lastUpdated: DateTime.now(),
  //     );

  //     await _firestore
  //         .collection('cceEarningsSummary')
  //         .doc(cceId)
  //         .set(summary.toFirestore(), SetOptions(merge: true));
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Get all flags for a customer
  Future<List<CustomerFlag>> getCustomerFlags(
      String customerId, String cceId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('customerId', isEqualTo: customerId)
          .where('flaggedBy', isEqualTo: cceId)
          .orderBy('flaggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CustomerFlag.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer flags: $e');
      }
      return [];
    }
  }

  Future<List<CustomerFlag>> getUnresolvedFlags() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('resolvedAt', isNull: true)
          .orderBy('flaggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CustomerFlag.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching unresolved flags: $e');
      }
      return [];
    }
  }

  Future<bool> resolveFlag(String flagId) async {
    try {
      await _firestore.collection(collectionName).doc(flagId).update({
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving flag: $e');
      }
      return false;
    }
  }

  Future<List<CustomerFlag>> getFlagsByCCE(String cceId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('flaggedBy', isEqualTo: cceId)
          .orderBy('flaggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CustomerFlag.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching CCE flags: $e');
      }
      return [];
    }
  }

  Future<bool> deleteFlag(String flagId) async {
    try {
      await _firestore.collection(collectionName).doc(flagId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting flag: $e');
      }
      return false;
    }
  }

  //upload Image method.

  Future<void> saveUploadedImages(UploadedImages image) async {
    await _firestore.collection('uploadedImages').add(image.toFirestore());
  }

  //Get uploaded images
  Stream<List<UploadedImages>> getUploadedImagesForCustomer(String customerId) {
    return _firestore
        .collection('uploadedImages')
        .where('custId', isEqualTo: customerId)
        .orderBy('uploadedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UploadedImages.fromFirestore(doc as Map<String, dynamic>))
            .toList());
  }
}
