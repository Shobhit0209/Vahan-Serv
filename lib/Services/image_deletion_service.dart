import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class ImageCleanupService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Simple call with default 45 days
  static Future<Map<String, dynamic>?> deleteOldImages() async {
    try {
      final callable = _functions.httpsCallable('manualDeleteOldImages');
      final result = await callable.call({'daysOld': 30});

      if (kDebugMode) {
        print('Cleanup result: ${result.data}');
      }
      return result.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error calling cleanup function: $e');
      }
      return null;
    }
  }
}
