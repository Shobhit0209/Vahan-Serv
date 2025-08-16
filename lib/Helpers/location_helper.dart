import 'package:vahanserv/Models/location_data_model.dart';
import 'package:vahanserv/Services/location_services.dart';

class CCELocationHelper {
  // Method to get location data for image upload
  static Future<Map<String, dynamic>> getLocationForImageUpload() async {
    try {
      LocationData? locationData =
          await LocationService.getCurrentLocationData();

      if (locationData != null) {
        return {
          'lat': locationData.lat,
          'long': locationData.long,
          'accuracy': locationData.accuracy,
          'hasLocation': true
        };
      } else {
        return {
          'lat': null,
          'long': null,
          'accuracy': null,
          'hasLocation': false,
          'error': 'Could not get location'
        };
      }
    } catch (e) {
      return {
        'lat': null,
        'long': null,
        'accuracy': null,
        'hasLocation': false,
        'error': e.toString()
      };
    }
  }
}
