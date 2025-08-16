class LocationData {
  final double lat;
  final double long;
  final double accuracy;

  LocationData({
    required this.lat,
    required this.long,
    required this.accuracy,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'accuracy': accuracy,
    };
  }
}
