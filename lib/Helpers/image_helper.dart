import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ImageHelper {
  final currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  Future<String?> uploadImageToStorage(File imageFile) async {
    final fileExtension = imageFile.path.split('.').last;
    final uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final imagePathInFirebase = 'images/$currentDate/$uniqueFileName';

    if (kDebugMode) {
      print('Local Image File Path: ${imageFile.path}');
    }
    final storageRef = firebaseStorage.ref().child(imagePathInFirebase);

    // 2. Upload the file
    final uploadTask = storageRef.putFile(File(imageFile.path));
    final snapshot = await uploadTask.whenComplete(() => {});
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
