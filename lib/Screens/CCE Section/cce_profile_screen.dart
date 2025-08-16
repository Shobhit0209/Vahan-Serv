// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/cce_model.dart';
import 'package:vahanserv/Providers/auth_provider.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/about_app_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/account_deletion_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/add_cce_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/add_customer_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/manage_customers_screen.dart';
import 'package:vahanserv/Screens/nav_bar.dart';
import 'package:vahanserv/Services/image_deletion_service.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CCEProfileScreen extends StatefulWidget {
  const CCEProfileScreen({
    super.key,
    required this.cceId,
  });
  final String cceId;

  @override
  State<CCEProfileScreen> createState() => _CCEProfileScreenState();
}

class _CCEProfileScreenState extends State<CCEProfileScreen> {
  void _performLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      await Provider.of<AuthProvidar>(context, listen: false).logout();

      // Close loading dialog
      Navigator.of(context).pop();

      context.go('/role');

      // Show success message
      Fluttertoast.showToast(
        msg: "Logged Out Succesfully",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      // Show error message
      Fluttertoast.showToast(
        msg: "Log Out Failed",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false).initCCE(widget.cceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        if (navBarKey.currentState != null) {
          navBarKey.currentState!.pageController.jumpToTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.profile,
          index: 0,
          space: 12,
          isleadingNeeded: false,
        ),
        body: Consumer<CCEProvider>(
          builder: (context, provider, child) {
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.initCCE(widget.cceId);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (provider.isLoading) {
              return Center(
                  child: Lottie.asset(
                'assets/cce/second animation.json',
                height: 60,
                width: 60,
              ));
            }
            final cce = provider.currentCCE!;
            return SingleChildScrollView(
              physics: PageScrollPhysics(),
              child: Padding(
                padding: pad8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    ClipRRect(
                      borderRadius: br10,
                      child: _buildProfileCard(cce),
                    ),
                    InkWell(
                      borderRadius: br10,
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: ManageCustomerScreen(
                              cceId: cce.cceId,
                            ),
                            withNavBar: false);
                      },
                      child: ClipRRect(
                        borderRadius: br10,
                        child: Card(
                          color: white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.mngcust,
                                  style: fh12SemiboldBlue,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: blue,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: br10,
                      child: _buildContactCard(cce),
                    ),
                    ClipRRect(
                      borderRadius: br10,
                      child: _buildSettingsCard(),
                    ),
                    _buildAccountDeleteCard(context),
                    if (provider.currentCCE!.cceId == 'RAVI1234')
                      _buildAddCustomer(context),
                    if (provider.currentCCE!.cceId == 'RAVI1234')
                      _buildAddCCE(context),
                    if (provider.currentCCE!.cceId == 'RAVI1234')
                      _buildManuallyDeleteImages(context)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountDeleteCard(BuildContext context) {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: AccountDeletionScreen(
              cceId: widget.cceId,
            ),
            withNavBar: false);
      },
      borderRadius: br10,
      child: ClipRRect(
        borderRadius: br10,
        child: Card(
          color: white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Delete Account',
                  style: fh12SemiboldRed,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: red,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCCE(BuildContext context) {
    return InkWell(
      borderRadius: br10,
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: AddCCEScreen(), withNavBar: false);
      },
      child: ClipRRect(
        borderRadius: br10,
        child: Card(
          color: white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add CCE',
                  style: fh12SemiboldBlue,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: blue,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomer(BuildContext context) {
    return InkWell(
      borderRadius: br10,
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: AddCustomerScreen(), withNavBar: false);
      },
      child: ClipRRect(
        borderRadius: br10,
        child: Card(
          color: white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add Customers',
                  style: fh12SemiboldBlue,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: blue,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
        color: white,
        child: Padding(
          padding: pad8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Text(
                AppLocalizations.of(context)!.settings,
                style: fh12SemiboldBlue,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        String cleanNumber = '9528202134'
                            .toString()
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanNumber.length >= 10) {
                          String last10Digits =
                              cleanNumber.substring(cleanNumber.length - 10);
                          await _makePhoneCall('+91$last10Digits');
                        }
                      },
                      splashColor: Colors.transparent,
                      child: Text(
                        AppLocalizations.of(context)!.hANDs,
                        style: fh12mediumBlack,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: AboutAppScreen(),
                          withNavBar: false),
                      child: Text(
                        AppLocalizations.of(context)!.aboutapp,
                        style: fh12mediumBlack,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _buildLogoutDialogBox();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.logout,
                        style: fh12mediumRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Future<dynamic> _buildLogoutDialogBox() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: white,
            title: Text(
              AppLocalizations.of(context)!.logout,
              style: fh16mediumBlue,
            ),
            content: Text(
              AppLocalizations.of(context)!.questionforlogout,
              style: fh12regularBlack,
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: fh12regularGrey,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _performLogout(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  style: fh12mediumRed,
                ),
              ),
            ],
            insetPadding: pad8,
            actionsAlignment: MainAxisAlignment.spaceEvenly);
      },
    );
  }

  Widget _buildContactCard(CCE cce) {
    return Card(
      color: white,
      child: Padding(
          padding: pad8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.continfo,
                    style: fh12SemiboldBlue,
                  ),
                  // InkWell(
                  //   onTap: () {},
                  //   child: ImageIcon(
                  //     AssetImage(
                  //       'assets/cce/edit.png',
                  //     ),
                  //     color: blue,
                  //   ),
                  // )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.mobile,
                    style: fh12mediumBlack,
                  ),
                  Text(
                    '+91${cce.mobile}',
                    style: fh12regularGrey,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.email,
                    style: fh12mediumBlack,
                  ),
                  Text(
                    cce.email,
                    style: fh12regularGrey,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.address,
                      style: fh12mediumBlack,
                    ),
                  ),
                  Text(
                    cce.address,
                    style: fh12regularGrey,
                  )
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildProfileCard(CCE cce) {
    return Card(
      color: white,
      child: Padding(
        padding: pad8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildProfileAvatar(cce.photoUrl, cce),
                ],
              ),
            ),
            SizedBox(width: 50), // Add spacing between avatar and text
            Expanded(
              // Keep Expanded here since it's inside a Row
              flex: 2, // Give more space to the text section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cce.name,
                    style: fh16SemiboldBlue,
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.id} - ${cce.cceId}',
                    style: fh12regularGrey,
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.doj} - ${cce.doj}',
                    style: fh12regularGrey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? imageUrl, CCE cce) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: cardColorLightBlue,
        child: imageUrl == null || imageUrl.isEmpty
            ? Icon(
                Icons.person,
                size: 60,
                color: grey,
              )
            : ClipOval(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _getProfileImage(imageUrl),
                ),
              ),
      ),
      SizedBox(
        height: 10,
      ),
      InkWell(
        onTap: () => _showImagePickerDialog(context, cce),
        child: Text(
          'Change Image',
          style: fh10mediumBlue,
        ),
      ),
    ]);
  }

  Widget _getProfileImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 50,
            color: Colors.grey[400],
          ),
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 300),
          fadeOutDuration: Duration(milliseconds: 300),
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 50,
            color: Colors.grey[400],
          ),
        );
      }
    }

    // Return default profile icon when no image URL
    return Icon(
      Icons.person,
      size: 50,
      color: Colors.grey[400],
    );
  }

  void _showImagePickerDialog(BuildContext context, CCE cce) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: white,
          title: Text(
            'Select Profile Picture',
            style: fh14SemiboldBlue,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(
                  'Choose from Gallery',
                  style: fh12mediumBlue,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, cce, context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo', style: fh12mediumBlue),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, cce, context);
                },
              ),
              if (cce.photoUrl.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Photo', style: fh12mediumBlue),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage(cce, context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
      ImageSource source, CCE cce, BuildContext context) async {
    // Capture all necessary references while context is valid
    final cceProvider = Provider.of<CCEProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    bool dialogShown = false;

    try {
      // Pick image
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      // Show loading dialog only if context is still mounted
      if (context.mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Uploading...'),
                ],
              ),
            );
          },
        );
      }

      // Compress to target size (5-10 KB)
      final Uint8List? compressedImage =
          await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 150,
        minHeight: 150,
        quality: 60,
        format: CompressFormat.jpeg,
      );

      if (compressedImage == null) throw Exception('Compression failed');

      // Check size and adjust if needed
      Uint8List finalImage = compressedImage;
      if (compressedImage.length > 10 * 1024) {
        // If > 10KB, compress more aggressively
        finalImage = await FlutterImageCompress.compressWithFile(
              image.path,
              minWidth: 100,
              minHeight: 100,
              quality: 40,
              format: CompressFormat.jpeg,
            ) ??
            compressedImage;
      }

      // Upload and update
      final String downloadUrl =
          await _uploadCompressedImage(finalImage, cce.cceId);
      await _updateCCEProfileImage(cce.cceId, downloadUrl);

      // Close dialog if it was shown
      if (dialogShown && navigator.canPop()) {
        navigator.pop();
        print('Dialog closed successfully');
      }

      // Show success message
      Fluttertoast.showToast(msg: 'Profile pic updated!');
      print('Toast shown successfully');

      // Force UI update using captured provider
      try {
        await cceProvider.refreshData();
        print('Data refreshed successfully');
      } catch (e) {
        print('Error refreshing data: $e');
        try {
          cceProvider.initCCE(widget.cceId);
          print('CCE reinitialized successfully');
        } catch (e2) {
          print('Error reinitializing CCE: $e2');
        }
      }

      // Force widget rebuild if still mounted
      if (mounted) {
        setState(() {});
        print('setState called successfully');
      }
    } catch (e) {
      print('Error in _pickImage: $e');

      // Close dialog on error if it was shown
      if (dialogShown && navigator.canPop()) {
        navigator.pop();
      }

      // Show error message
      Fluttertoast.showToast(msg: 'Upload Failed: ${e.toString()}');
    }
  }

// Ultra simple upload
  Future<String> _uploadCompressedImage(
      Uint8List imageBytes, String cceId) async {
    final ref = FirebaseStorage.instance.ref(
        'cce_profiles/profile_${cceId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  }

  Future<void> _updateCCEProfileImage(String cceId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('cce') // Adjust collection name as needed
          .doc(cceId)
          .update({'photoUrl': imageUrl});
    } catch (e) {
      throw Exception('Failed to update profile in database: $e');
    }
  }

  Future<void> _removeProfileImage(CCE cce, BuildContext context) async {
    // Capture the provider reference early while context is still valid
    final cceProvider = Provider.of<CCEProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Removing...'),
            ],
          ),
        );
      },
    );

    try {
      // Delete image from Firebase Storage if it exists
      if (cce.photoUrl.isNotEmpty && cce.photoUrl.startsWith('http')) {
        try {
          final Reference storageRef =
              FirebaseStorage.instance.refFromURL(cce.photoUrl);
          await storageRef.delete();
          print('Image deleted from storage successfully');
        } catch (e) {
          if (kDebugMode) {
            print('Error deleting image from storage: $e');
          }
        }
      }

      // Update CCE profile to remove image URL
      await _updateCCEProfileImage(cce.cceId, '');
      print('Database updated successfully');

      // Close dialog using the captured navigator
      if (navigator.canPop()) {
        navigator.pop();
        print('Dialog closed successfully');
      }

      // Show success message
      Fluttertoast.showToast(msg: 'Profile pic removed.');
      print('Toast shown successfully');

      // Refresh the data using the captured provider reference
      try {
        cceProvider.refreshData();
        print('Data refreshed successfully');
      } catch (e) {
        print('Error refreshing data: $e');
        try {
          cceProvider.initCCE(widget.cceId);
          print('CCE reinitialized successfully');
        } catch (e2) {
          print('Error reinitializing CCE: $e2');
        }
      }

      // Force setState to rebuild the widget if still mounted
      if (mounted) {
        setState(() {});
        print('setState called successfully');
      }
    } catch (e) {
      print('Error in _removeProfileImage main try block: $e');

      // Close dialog on error using captured navigator
      if (navigator.canPop()) {
        navigator.pop();
      }

      // Show error message
      Fluttertoast.showToast(
        msg: 'Failed to remove: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  _buildManuallyDeleteImages(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.cleaning_services),
      title: Text('Clean Old Images'),
      subtitle: Text('Remove images older than 30 days'),
      onTap: () async {
        final result = await ImageCleanupService.deleteOldImages();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['message'] ?? 'Cleanup completed')),
        );
      },
    );
  }
}
