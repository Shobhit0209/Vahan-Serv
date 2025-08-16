// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Helpers/image_helper.dart';
import 'package:vahanserv/Models/notification_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/notification_provider.dart';
import 'package:vahanserv/Services/notification_services.dart';

class DisplayImages extends StatefulWidget {
  final XFile? images; // Single image
  final String custId;
  final int serviceNo;

  const DisplayImages({
    super.key,
    required this.images,
    required this.custId,
    required this.serviceNo,
  });

  @override
  State<DisplayImages> createState() => _DisplayImagesState();
}

class _DisplayImagesState extends State<DisplayImages> {
  final firestore = FirebaseFirestore.instance;
  bool isUploading = false;
  String uploadUrl = '';
  double uploadProgress = 0;
  NotificationServices notificationServices = NotificationServices();
  late NotificationProvider _notificationProvider;
  String locationMessage = '';
  late bool isLoading;

  Future<void> uploadImage(String cceId) async {
    if (isUploading || widget.images == null) return;

    setState(() {
      isUploading = true;
      uploadUrl = '';
      uploadProgress = 0;
    });

    try {
      final cceProvider = Provider.of<CCEProvider>(context, listen: false);
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String? firebaseToken = await user.getIdToken();
        log('Firebase Token: $firebaseToken');

        // Upload single image to storage
        final image = File(widget.images!.path);
        final downloadUrl = await ImageHelper().uploadImageToStorage(image);

        if (downloadUrl != null) {
          uploadUrl = downloadUrl;
          log('Image uploaded successfully. URL: $downloadUrl');

          setState(() {
            uploadProgress = 0.5; // 50% after storage upload
          });

          // Initialize customer data
          Provider.of<CCEProvider>(context, listen: false)
              .initCustomer(widget.custId);

          // Use the corrected method to add image to array

          await cceProvider.uploadTaskCompletionImage(
            uploadUrl,
            widget.custId,
            cceProvider.currentCCE?.cceId ?? 'unknown',
          );

          setState(() {
            uploadProgress = 0.8; // 80% after Firestore update
          });

          // Update task status
          await cceProvider.updateTaskStatus(widget.custId, widget.serviceNo);

          // Add earnings
          // await cceProvider
          //     .addEarningAndUpdateTotals(cceProvider.currentCCE!.cceId);

          setState(() {
            uploadProgress = 1.0; // 100% complete
          });

          // Show success notification
          final notification = NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Image Uploaded for ${cceProvider.customer!.custName}',
            body: 'Successfully uploaded after service image',
            type: 'task_completion',
            timestamp: DateTime.now(),
            data: {
              'type': 'task_completion',
              'custId': widget.custId,
            },
          );
          _notificationProvider.addNotification(notification, cceId);
          notificationServices.showLocalNotification(
              title: notification.title,
              body: notification.body,
              payload: notification.id);

          // Navigate back after short delay
          await Future.delayed(Duration(seconds: 1));
          PersistentNavBarNavigator.pop(context);
          PersistentNavBarNavigator.pop(context);

          setState(() {
            isUploading = false;
          });
        } else {
          throw Exception('Failed to get download URL from storage');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        uploadProgress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      log('Error uploading image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false)
          .initCustomer(widget.custId);

      _initializeNotifications();
    });
  }

  void _initializeNotifications() async {
    _notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Load saved notifications

    // Set notification provider in service
    notificationServices.setNotificationProvider(_notificationProvider);
    // Initialize notification services
    notificationServices.initLocalNotification(context);
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
    notificationServices.isRefreshToken();

    // Get FCM token
    String token = await notificationServices.getDeviceToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: white,
        titleSpacing: 0,
        title: Text(
          'Service Image',
          style: fh16mediumWhite,
        ),
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 20,
          ),
        ),
        actions: [
          if (!isUploading && widget.images != null)
            Consumer<CCEProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                    shape: ContinuousRectangleBorder(borderRadius: br10),
                  ),
                  onPressed: () => uploadImage(provider.currentCCE!.cceId),
                  child: Text(
                    'Upload',
                    style: fh14mediumBlue,
                  ),
                );
              },
            ),
          if (isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                width: 80,
                child: Center(
                  child: CircularProgressIndicator(
                    color: white,
                    strokeWidth: 2,
                    value: uploadProgress,
                  ),
                ),
              ),
            ),
        ],
        actionsPadding: pad8,
      ),
      body: Consumer<CCEProvider>(builder: (context, provider, child) {
        if (provider.isLoading && !isUploading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/cce/second animation.json',
                  height: 60,
                  width: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading customer data...',
                  style: fh16regularBlack,
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: fh16regularBlack,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.initCustomer(widget.custId);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (isUploading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  'assets/cce/second animation.json',
                  height: 80,
                  width: 80,
                ),
                SizedBox(height: 24),
                Text(
                  'Uploading service image...',
                  style: fh16mediumBlue,
                ),
                SizedBox(height: 16),
                Text(
                  'Please do not go back',
                  style: fh14regularBlack,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(blue),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '${(uploadProgress * 100).toInt()}% Complete',
                  style: fh14regularBlue,
                ),
              ],
            ),
          );
        }

        // Display single image
        return widget.images != null
            ? Container(
                padding: pad12,
                child: Column(
                  children: [
                    // Customer info card
                    if (provider.customer != null)
                      Container(
                        width: double.infinity,
                        padding: pad12,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: br10,
                          border: Border.all(color: blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer: ${provider.customer!.custName ?? 'N/A'}',
                              style: fh14SemiboldBlue,
                            ),
                          ],
                        ),
                      ),

                    // Image preview
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: br10,
                          border: Border.all(color: blue, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(widget.images!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Image Available',
                      style: fh20boldBlue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please go back and capture an image',
                      style: fh14regularBlack,
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
