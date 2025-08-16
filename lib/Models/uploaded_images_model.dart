import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Ensure this is imported

class UploadedImages {
  final String? custId;
  final String? imageURLs;
  final Timestamp? uploadedDate;
  final String? uploadedByCCE; // CCE ID

  UploadedImages({
    this.custId,
    this.imageURLs,
    this.uploadedDate,
    this.uploadedByCCE,
  });

  // Getter to easily access upload date as a Dart DateTime object
  DateTime? get uploadDateTime => uploadedDate?.toDate();

  // Factory method to create an UploadedImages object from a Firestore document
  // Added optional SnapshotOptions to match standard fromFirestore signature
  factory UploadedImages.fromFirestore(Map<String, dynamic> data) {
    // Safely parse imageURLs:
    String? url;
    final dynamic rawImageURLs = data['imageURLs'];

    if (rawImageURLs is String && rawImageURLs.isNotEmpty) {
      // If it's a non-empty string, wrap it in a list
      url = rawImageURLs;
    }
    // If it's null or an empty string, `urls` will remain null, or you can set it to `[]`

    if (kDebugMode) {
      print('DEBUG: Parsed Image URLs: $url');
    }

    return UploadedImages(
      custId: data['custId'] as String?,
      imageURLs: url, // Assign the safely parsed list
      uploadedDate: data['uploadedDate'] as Timestamp?,
      uploadedByCCE: data['uploadedByCCE'] as String?,
    );
  }

  // Method to convert UploadedImages object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'custId': custId,
      'imageURLs': imageURLs, // Keep consistent field name
      'uploadedDate': uploadedDate,
      'uploadedByCCE': uploadedByCCE,
    };
  }

  // Optional: Override toString for easier debugging
  @override
  String toString() {
    return 'UploadedImages(custId: $custId, imageURLs: $imageURLs, uploadedDate: $uploadedDate, uploadedByCCE: $uploadedByCCE)';
  }
}
