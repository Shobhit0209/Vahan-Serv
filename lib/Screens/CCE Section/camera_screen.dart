// ignore_for_file: public_member_api_docs, sort_constructors_first, library_private_types_in_public_api

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CCE%20Section/display_images.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.custId,
    required this.serviceNo,
  });
  final String custId;
  final int serviceNo;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  XFile? _capturedImage; // Changed from _capturedImages to _capturedImage
  bool _isCapturing = false;
  bool isInitialized = false;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          error = 'No cameras available';
          isLoading = false;
        });
        return;
      }

      // Initialize camera controller with the first camera (usually back camera)
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize the controller
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          isInitialized = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to initialize camera: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.isTakingPicture ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
      if (kDebugMode) {
        print("Photo captured: ${image.path}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error taking picture: $e");
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  // Method to retake photo
  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 4,
        title: Text('Capture Image', style: fh16mediumBlue),
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, size: 20),
        ),
        foregroundColor: blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Unknown error occurred',
              style: fh14SemiboldBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  error = null;
                  isLoading = true;
                  isInitialized = false;
                });
                _initializeCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 4,
        title: Text('Capture Image', style: fh16mediumBlue),
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, size: 20),
        ),
        foregroundColor: blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              'assets/cce/second animation.json',
              height: 60,
              width: 60,
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: fh14regularBlack,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle error state
    if (error != null) {
      return _buildErrorWidget();
    }

    // Handle loading state
    if (isLoading || !isInitialized || _cameraController == null) {
      return _buildLoadingWidget();
    }
    if (!_cameraController!.value.isInitialized) {
      return _buildLoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 4,
        title: Text('Capture Image', style: fh16mediumBlue),
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, size: 20),
        ),
        foregroundColor: blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          // Bottom controls
          Container(
            padding: pad8,
            decoration: BoxDecoration(color: white),
            child: Column(
              children: [
                // Capture/Show Image button
                InkWell(
                  onTap: _capturedImage == null
                      ? _capturePhoto
                      : () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            withNavBar: false,
                            screen: DisplayImages(
                              images: _capturedImage,
                              custId: widget.custId,
                              serviceNo: widget.serviceNo,
                            ),
                          );
                        },
                  child: _capturedImage == null
                      ? (_isCapturing
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Capturing...',
                                  style: fh16regularBlue,
                                ),
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.07,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(color: blue, width: 4),
                              ),
                              child: CircleAvatar(
                                backgroundColor: blue,
                              ),
                            ))
                      : Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Show Image',
                              style: fh16regularWhite,
                            ),
                          ),
                        ),
                ),

                // Image preview section
                if (_capturedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        // Image preview
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: blue, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(_capturedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Retake button
                        InkWell(
                          onTap: _retakePhoto,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Retake',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
