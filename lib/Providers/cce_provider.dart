// ignore_for_file: prefer_final_fields

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vahanserv/Models/cce_earnings_summary_model.dart';
import 'package:vahanserv/Models/cce_model.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Models/cce_earnings_model.dart';
import 'package:vahanserv/Models/flag_model.dart';
import 'package:vahanserv/Models/uploaded_images_model.dart';
import 'package:vahanserv/Services/firestore_services.dart';

class CCEProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  // States
  CCE? _currentCCE;
  Customer? _customer;
  Car? _currentCar;
//  CustomerFlag? _flag;
  List<Customer> _assignedCustomers = [];
  List<Car> _cars = [];
  List<Customer> _allCustomers = [];
  List<Car> _missedTasks = [];
  List<CustomerFlag> _customerFlags = [];
  List<CCEEarnings> _earnings = [];
  CCEEarningsSummary? _earningsSummary;
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  int? _leavesLeft; // Default to 2 for the first month

  // Getters
  CCE? get currentCCE => _currentCCE;
  Customer? get customer => _customer;
  Car? get currentCar => _currentCar;
  List<Customer> get assignedCustomers => _assignedCustomers;
  List<Car> get cars => _cars;
  List<CustomerFlag> get customerFlags => _customerFlags;
  int? get leavesLeft => _leavesLeft;

  List<Customer> get allCustomers => _allCustomers;
  List<Car> get missedTasks => _missedTasks; // Changed return type
  List<CCEEarnings> get earnings => _earnings;
  CCEEarningsSummary? get earningsSummary => _earningsSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDateString {
    // Name it something descriptive
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  DateTime? get selectedDate => _selectedDate;

  // Get counts for dashboard metrics
  int get totalCustomers => _allCustomers.length;
  int get totalCars => _cars.length; // New getter for total cars
  int get pendingTasksToday =>
      _cars.where((car) => car.serviceStatus == 'pending').length;
  int get completedTasksToday =>
      _cars.where((car) => car.serviceStatus == 'completed').length;
  int get missedTasksToday => _cars
      .where((car) => car.serviceStatus == 'missed')
      .length; // Fixed the negative sign

  // Get earnings data
  double get todayEarnings {
    // Primary: Use stored value from database
    double storedValue = _currentCCE?.todayEarning ?? 0.0;
    // Fallback: Calculate from earnings if stored value seems wrong
    if (storedValue == 0.0 && _earnings.isNotEmpty) {
      return _calculateTodayEarnings();
    }
    return storedValue;
  }

  double get monthlyEarnings {
    // Primary: Use stored value from database
    double storedValue = _currentCCE?.monthlyEarning ?? 0.0;
    // Fallback: Calculate from earnings if stored value seems wrong
    if (storedValue == 0.0 && _earnings.isNotEmpty) {
      return _calculateMonthlyEarnings();
    }
    return storedValue;
  }

  double get totalEarnings => _earningsSummary?.totalEarnings ?? 0.0;
  double get pendingEarnings => _earningsSummary?.pendingAmount ?? 0.0;

  // Initialize with CCE ID
  Future<void> initCCE(String cceId) async {
    if (kDebugMode) {
      print('initCCE called with cceId: $cceId');
    }

    try {
      // Get CCE data
      _setLoading(true);
      final cce = await _firestore.getCCE(cceId);
      if (cce == null) {
        _setError('CCE not found');
        return;
      }
      _currentCCE = cce;

      await loadCustomersForTheDay(DateTime.now());
      //await loadDailyEarningPerCustomer(cceId);

      // await loadEarningsSummary(cceId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load CCE data: $e');
    } finally {
      if (kDebugMode) {
        print(
            'initCCE completed, _currentCCE: ${_currentCCE!.name}, _isLoading: $_isLoading, _error: $_error');
      }
    }
  }

  //inititialise Customers
  Future<void> initCustomer(String custId) async {
    try {
      _setLoading(true);
      final customer = await _firestore.getCustomer(custId);
      final customerFlags =
          await _firestore.getCustomerFlags(custId, _currentCCE!.cceId);
      if (customer == null || _currentCCE == null) {
        _setError('customer or cce not found $e');
      }
      _customer = customer;
      _customerFlags = customerFlags;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load customer data: $e');
    }
  }

  //Initialise Cars
  Future<void> initCar(String carId) async {
    try {
      _setLoading(true);
      final currentCar = await _firestore.getCar(carId);
      if (currentCar == null) {
        _setError('car not found $e');
      }
      _currentCar = currentCar;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load Car data: $e');
    }
  }

  // Load tasks for a specific date
  Future<void> loadCustomersForTheDay(DateTime date) async {
    _selectedDate = date;
    try {
      if (_currentCCE == null) {
        _setError(error);
        return;
      }

      // Set up task listener for the selected date
      // _setupTasksListener(_currentCCE!.cceId, _selectedDate);
      await _setupCustomerListener(_currentCCE!.cceId, _selectedDate);
    } catch (e) {
      _setError('Failed to load tasks: $e');
    }
  }

  //update cce leaves left
  Future<void> updateLeavesLeft(int leavesLeft) async {
    try {
      if (_currentCCE == null) {
        _setError('CCE not initialized');
        return;
      }

      await _firestore.updateCCELeavesLeft(_currentCCE!.cceId, leavesLeft);
      _leavesLeft = leavesLeft; // Update local state
      notifyListeners();
    } catch (e) {
      _setError('Failed to update leaves left: $e');
    }
  }

  // Load earnings summary
  Future<void> loadEarningsSummary(String cceId) async {
    try {
      final summary = await _firestore.getCCEEarningsSummary(cceId);
      _earningsSummary = summary;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load earnings summary: $e');
      }
      // Don't throw error for earnings summary as it's not critical
    }
  }

  // Set up listener for customers
  Future<void> _setupCustomerListener(String cceId, DateTime date) async {
    if (currentCCE!.isActive == false) {
      _assignedCustomers = [];
    } else {
      List<Customer> fetchedCustomers =
          await _firestore.getTasksOfTheDayForCCE(cceId, date);
      // List<Car> fethchedCars =
      //     await _firestore.getThenumberOfCarsForService(cceId, date);

      // for (var customer in fetchedCustomers) {
      //   final hasImages = await _firestore.checkIfCarHasUploadedImages(
      //     customer.custId,
      //     uploadedOnOrAfterDate: selectedDate!,
      //   );
      //   customer.hasUploadedImages = hasImages;
      // }
      // Process each customer and their cars
      _assignedCustomers = fetchedCustomers;
      // _cars = fethchedCars;

      if (kDebugMode) {
        print(
            "Number of customers loaded for daily tasks: ${_assignedCustomers.length} and the total cars to be served are ${_cars.length} ");
        // Print detailed info
        for (var customer in _assignedCustomers) {
          print(
              "Customer: ${customer.custName} has ${customer.numberOfCars ?? 0} cars needing service");
        }
      }
    }

    notifyListeners();
  }

  // Set up listener for tasks on a specific date
  // ignore: unused_element

  // Set up listener for all tasks
  Future<void> getAllCustomersUnderCCE(String cceId) async {
    try {
      final allCustomers = await _firestore.getAllCustomersUnderCCE(cceId);
      _allCustomers = allCustomers;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        _setError('Failed to load customer data: $e');
      }

      // Don't throw error for earnings summary as it's not critical
    }
  }

  // Set up listener for missed tasks
/*  void _setupMissedTasksListener(String cceId) {
    _firestore.getMissedTasksByCCE(cceId).listen((tasks) {
      _missedTasks = tasks;
      notifyListeners();
    }, onError: (e) {
      _setError('Error loading missed tasks: $e');
    });
  }*/

  // Set up listener for earnings

  Future<void> loadDailyEarningPerCustomer(String cceId) async {
    try {
      final earning = await _firestore.getCCEEarnings(cceId);
      _earnings = earning;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load daily earnings per customer: $e');
      }
      // Don't throw error for earnings summary as it's not critical
    }
  }

  Future<void> resetDaily() async {
    try {
      _firestore.scheduleDailyReset();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to reset: $e');
      }
    }
  }
  // Future<void> getCustomer(String custId) async {
  //   try {
  //     final customer = await _firestore.getCustomer(custId);
  //     _customer = customer;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Failed to load customer: $e');
  //     }
  //   }
  // }

  int getCustomerServiceNumber(String custId) {
    final customer = _assignedCustomers.firstWhere(
      (customer) => customer.custId == custId,
      orElse: () => Customer(
          custId: '',
          custName: 'Unknown',
          custPhotoUrl: '',
          custAddress: '',
          custMobile: '',
          flagged: 0,
          completionDate: '',
          cars: [],
          serviceNo: 0),
    );
    return customer.serviceNo!;
  }

  // Get customer by ID
  Customer? getCustomerById(String custId) {
    try {
      return _assignedCustomers.firstWhere(
        (customer) => customer.custId == custId,
      );
    } catch (e) {
      return null;
    }
  }

  //mark cce as unavailable
  Future<void> markCCEasUnavilable(
      String cceId, String dateStr, int leavesLeft) async {
    try {
      return _firestore.markCCEAsUnavailable(cceId, dateStr, leavesLeft);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark as unavailable: $e');
      }
    }
  }

  Future<void> extendAssignedCustomerSubscriptionsByOneDay(
      String cceId, DateTime currentDate) async {
    try {
      return _firestore.extendAssignedCustomerSubscriptionsByOneDay(
          cceId, currentDate);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to extend end date by one day: $e');
      }
    }
  }

  Future<void> decrementAssignedCustomerSubscriptionsByOneDay(
      String cceId, DateTime currentDate) async {
    try {
      return _firestore.decrementAssignedCustomerSubscriptionsByOneDay(
          cceId, currentDate);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to decrease end date by one day: $e');
      }
    }
  }

  // Get tasks for a specific customer
  // List<Task> getTasksForCustomer(String custId) {
  //   return _allTasks.where((task) => task.servedCustomer == custId).toList();
  // }

  // // Get pending tasks for a customer
  // List<Task> getPendingTasksForCustomer(String custId) {
  //   return _allTasks
  //       .where((task) =>
  //           task.servedCustomer == custId && task.taskStatus == 'pending')
  //       .toList();
  // }

  // // Get completed tasks for a customer
  // List<Task> getCompletedTasksForCustomer(String custId) {
  //   return _allTasks
  //       .where((task) =>
  //           task.servedCustomer == custId && task.taskStatus == 'completed')
  //       .toList();
  // }

  // // Get tasks by status
  // List<Task> getTasksByStatus(String status) {
  //   return _allTasks.where((task) => task.taskStatus == status).toList();
  // }

  // // Get tasks for date range
  // List<Task> getTasksForDateRange(DateTime startDate, DateTime endDate) {
  //   return _allTasks.where((task) {
  //     try {
  //       final taskDate = DateFormat('dd-MM-yyyy').parse(task.taskDate);
  //       return taskDate.isAfter(startDate.subtract(Duration(days: 1))) &&
  //           taskDate.isBefore(endDate.add(Duration(days: 1)));
  //     } catch (e) {
  //       return false;
  //     }
  //   }).toList();
  // }

  // Update task status, earning status, images.
  Future<void> updateTaskStatus(
    String custId,
    int serviceNo,
    /*String carId, String newStatus,*/
  ) async {
    _setLoading(true);
    try {
      await _firestore.updateTaskStatus(custId, serviceNo);
      _setLoading(false);

      // Show success message
      _setSuccessMessage('Task status updated successfully');
    } catch (e) {
      _setError('Failed to update task: $e');
    }
  }

  Future<void> addEarningAndUpdateTotals(String cceId) async {
    try {
      // Calculate new totals from all earnings

      await _firestore.updateCCETotals(cceId);

      // Refresh local data
      await initCCE(cceId);
    } catch (e) {
      _setError('Failed to add earning: $e');
    }
  }

  Future<void> recalculateAllTotals(String cceId) async {
    try {
      _setLoading(true);
      await _firestore.updateCCETotals(cceId);
      await initCCE(cceId); // Reload CCE data
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to recalculate totals: $e');
    }
  }

  double _calculateTodayEarnings() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return _earnings.where((earning) {
      final earningDate = earning.time?.toDate();
      return earningDate != null &&
          earningDate.isAfter(todayStart) &&
          earningDate.isBefore(todayEnd);
    }).fold(0.0, (sum, earning) => sum + (earning.amount ?? 0.0));
  }

  double _calculateMonthlyEarnings() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    return _earnings.where((earning) {
      final earningDate = earning.time?.toDate();
      return earningDate != null &&
          earningDate.isAfter(monthStart) &&
          earningDate.isBefore(monthEnd);
    }).fold(0.0, (sum, earning) => sum + (earning.amount ?? 0.0));
  }

  // Mark task as missed
  Future<void> markTaskAsMissed(String taskId, bool isMissed) async {
    _setLoading(true);
    try {
      await _firestore.markTaskAsMissed(taskId, isMissed);
      _setLoading(false);

      if (isMissed) {
        _setSuccessMessage('Task marked as missed');
      } else {
        _setSuccessMessage('Task unmarked as missed');
      }
    } catch (e) {
      _setError('Failed to mark task as missed: $e');
    }
  }

  // Upload task completion image
  Future<void> uploadTaskCompletionImage(
      String imageUrl, String custId, String uploadedByCCE) async {
    _setLoading(true);
    try {
      if (_currentCCE == null) {
        _setError('Failed to upload image: CCE data not initialized.');
        _setLoading(
            false); // Make sure to unset loading if an error occurs early
        return;
      }

      uploadedByCCE = _currentCCE!.cceId;
      custId = _customer!.custId;

      await _firestore.addUploadedImageBatchDetails(
          imageUrl: imageUrl, uploadedByCCE: uploadedByCCE, custId: custId);

      _setLoading(false);
    } catch (e) {
      _setError('Failed to upload image: $e');
    }
  }

  Future<List<String>> getUploadedImageUrls(String custId, String cceId) async {
    return await _firestore.getUploadedImageUrlsForCustomer(custId, cceId);
  }

  Future<void> saveUploadImages(UploadedImages uploadImages) async {
    _setLoading(true);
    try {
      await _firestore.saveUploadedImages(uploadImages);
      _setLoading(false);
      _setSuccessMessage('Image Uploaded');
    } catch (e) {
      _setError('Failed to upload image: $e');
    }
  }

  // Get earnings for date range
  Future<List<CCEEarnings>> getEarningsForDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      if (_currentCCE == null) return [];

      return await _firestore.getCCEEarningsInRange(
          _currentCCE!.cceId, startDate, endDate);
    } catch (e) {
      _setError('Failed to get earnings: $e');
      return [];
    }
  }

  // Get monthly earnings

  // Refresh all data
  Future<void> refreshData() async {
    if (_currentCCE == null) return;

    _setLoading(true);
    try {
      // Reload CCE data
      final cce = await _firestore.getCCE(_currentCCE!.cceId);
      if (cce != null) {
        _currentCCE = cce;
      }

      // Reload tasks for current date
      await loadCustomersForTheDay(_selectedDate);

      // Reload earnings summary
      // await loadEarningsSummary(_currentCCE!.cceId);

      _setLoading(false);
      _setSuccessMessage('Data refreshed successfully');
    } catch (e) {
      _setError('Failed to refresh data: $e');
    }
  }

  // Get task statistics
  // Map<String, int> getTaskStatistics() {
  //   final completed =
  //       _allTasks.where((task) => task.taskStatus == 'completed').length;
  //   final pending =
  //       _allTasks.where((task) => task.taskStatus == 'pending').length;
  //   final missed = _missedTasks.length;

  //   return {
  //     'completed': completed,
  //     'pending': pending,
  //     'missed': missed,
  //     'total': _allTasks.length
  //   };
  // }

  // Get customer statistics
  // Map<String, dynamic> getCustomerStatistics() {
  //   final totalCustomers = _assignedCustomers.length;
  //   final activeCustomers = _assignedCustomers.where((customer) {
  //     final customerTasks = getTasksForCustomer(customer.custId);
  //     return customerTasks.any((task) => task.taskStatus == 'pending');
  //   }).length;

  //   return {
  //     'total': totalCustomers,
  //     'active': activeCustomers,
  //     'inactive': totalCustomers - activeCustomers,
  //   };
  // }

  // Get earnings statistics
  Map<String, double> getEarningsStatistics() {
    final taskEarnings = _earnings
        .where((earning) => earning.earningType == 'task_completion')
        .fold<double>(0, (sum, earning) => sum + earning.amount!);

    final referralEarnings = _earnings
        .where((earning) => earning.earningType == 'referral')
        .fold<double>(0, (sum, earning) => sum + earning.amount!);

    final bonusEarnings = _earnings
        .where((earning) => earning.earningType == 'bonus')
        .fold<double>(0, (sum, earning) => sum + earning.amount!);

    final penalties = _earnings
        .where((earning) => earning.earningType == 'penalty')
        .fold<double>(0, (sum, earning) => sum + earning.amount!);

    return {
      'taskEarnings': taskEarnings,
      'referralEarnings': referralEarnings,
      'bonusEarnings': bonusEarnings,
      'penalties': penalties,
      'netEarnings':
          taskEarnings + referralEarnings + bonusEarnings - penalties,
    };
  }

  // Helper methods for state changes
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    // You can implement a success message system here
    // For now, just clear any existing errors
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose method to clean up listeners
  @override
  void dispose() {
    // Clean up any stream subscriptions if needed
    super.dispose();
  }
}
