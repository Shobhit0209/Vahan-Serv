// ignore_for_file: use_build_context_synchronously, must_be_immutable, deprecated_member_use, unused_element
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Providers/auth_provider.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/language_provider.dart';
import 'package:vahanserv/Providers/notification_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/camera_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/customer_profile_screen.dart';
import 'package:vahanserv/Services/cce_auth_service.dart';
import 'package:vahanserv/Services/notification_services.dart';
import 'package:vahanserv/l10n/app_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CCEDashboardScreen extends StatefulWidget {
  final String cceId;
  final String cceName;

  const CCEDashboardScreen({
    super.key,
    required this.cceId,
    required this.cceName,
  });

  @override
  State<CCEDashboardScreen> createState() => _CCEDashboardScreenState();
}

enum Language { english, hindi }

class _CCEDashboardScreenState extends State<CCEDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Language? selectedLanguage;
  DateTime selectedDate = DateTime.now();
  int? _expandedIndex;
  NotificationServices notificationServices = NotificationServices();
  late NotificationProvider _notificationProvider;
  CCEAuthService auth = CCEAuthService();
  DateTime? lastInactiveTime;
  bool canToggleToActive = true;
  Timer? _restrictionTimer;
  Timer? _uiUpdateTimer;
  late int numberOfTimesToggled;
  DateTime? _lastPressed;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLastInactiveTime();
    _startUIUpdateTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<CCEProvider>(context, listen: false)
          .initCCE(widget.cceId);
      getNumberOfLeavesLeft(context);
      Provider.of<AuthProvidar>(context, listen: false);
      Provider.of<LanguageProvider>(context, listen: false);
    });
    _requestCameraPermission();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
    notificationServices.getDeviceToken().then(
      (value) {
        if (kDebugMode) {
          print('Device token $value');
        }
      },
    );
    _notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    // Set notification provider in service
    notificationServices.setNotificationProvider(_notificationProvider);
    // Initialize notification services
    notificationServices.initLocalNotification(context);
  }

  @override
  void dispose() {
    _restrictionTimer?.cancel();
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  void getNumberOfLeavesLeft(BuildContext context) async {
    final provider = Provider.of<CCEProvider>(context, listen: false);

    if (selectedDate.day == 1) {
      setState(() {
        numberOfTimesToggled = 2;
      });
      provider.updateLeavesLeft(2);
    } else {
      setState(() {
        // Ensure provider.leavesLeft is not null before assigning
        //log('Leaves left: ${provider.currentCCE?.leavesLeft}');
        numberOfTimesToggled = provider.currentCCE?.leavesLeft ?? 0;
        print('$numberOfTimesToggled');
      });
      // ignore: avoid_print
    }
  }

  Future<void> _checkLastInactiveTime() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cce')
          .doc(widget.cceId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('lastInactiveTime') &&
            data['lastInactiveTime'] != null) {
          lastInactiveTime = (data['lastInactiveTime'] as Timestamp).toDate();
          _updateToggleRestriction();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking last inactive time: $e');
      }
    }
  }

  void _startUIUpdateTimer() {
    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!canToggleToActive && lastInactiveTime != null) {
        final now = DateTime.now();
        final timeDifference = now.difference(lastInactiveTime!);

        if (timeDifference.inHours >= 10) {
          // Time restriction has ended
          setState(() {
            canToggleToActive = true;
          });
          _uiUpdateTimer?.cancel();
        } else {
          // Update UI to show current remaining time

          setState(() {});
        }
      } else {
        _uiUpdateTimer?.cancel();
      }
    });
  }

  void _updateToggleRestriction() {
    if (lastInactiveTime != null) {
      final now = DateTime.now();
      final timeDifference = now.difference(lastInactiveTime!);

      if (timeDifference.inHours < 10) {
        setState(() {
          canToggleToActive = false;
        });
        _startUIUpdateTimer();
        // Set timer to enable toggle after remaining time
        final remainingTime = Duration(hours: 10) - timeDifference;
        _restrictionTimer?.cancel();
        _restrictionTimer = Timer(remainingTime, () {
          setState(() {
            canToggleToActive = false;
          });
          _uiUpdateTimer?.cancel();
        });
      } else {
        setState(() {
          canToggleToActive = true;
        });
        _uiUpdateTimer?.cancel();
      }
    }
  }

  Future<void> _handleCCEActiveFlow(FirebaseFirestore firestore, bool isActive,
      CCEProvider cceProvider, DateTime today) {
    return Future.delayed(Duration(milliseconds: 500), () async {
      try {
        await firestore.collection('cce').doc(widget.cceId).update({
          'isActive': true,
          'lastInactiveTime': null,
        });

        setState(() {
          isActive = true;
          isLoading = false;
          lastInactiveTime = null;
          canToggleToActive = true;
        });
        _restrictionTimer?.cancel();
        _uiUpdateTimer?.cancel();
        // await cceProvider.decrementAssignedCustomerSubscriptionsByOneDay(
        //     widget.cceId, today);
        await Provider.of<CCEProvider>(context, listen: false)
            .initCCE(widget.cceId);
        Fluttertoast.showToast(msg: 'Marked as available for today.');
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _handleCCEInactiveFlow(
      String cceId, CCEProvider cceProvider, bool isActive) async {
    setState(() {
      isLoading = true;
    });

    try {
      final DateTime today = DateTime.now();
      final String todayStr = DateFormat('dd-MM-yyyy').format(today);

      // STEP 1: Mark CCE as unavailable in leaves collection
      await cceProvider.markCCEasUnavilable(
          cceId, todayStr, numberOfTimesToggled);

      // STEP 2: Extend subscription end dates for ALL customers (not just assigned ones)
      await cceProvider.extendAssignedCustomerSubscriptionsByOneDay(
          cceId, today);

      setState(() {
        isActive = false;
        lastInactiveTime = today;
        canToggleToActive = false;
      });
      _startUIUpdateTimer();
      _restrictionTimer?.cancel();
      _restrictionTimer = Timer(Duration(hours: 10), () {
        setState(() {
          canToggleToActive = true;
        });
        _uiUpdateTimer?.cancel();
      });

      await Provider.of<CCEProvider>(context, listen: false)
          .initCCE(widget.cceId);
      Fluttertoast.showToast(msg: 'Marked as absent for today.');
    } catch (e) {
      if (kDebugMode) {
        print('Error in CCE unavailable flow: $e');
      }

      Fluttertoast.showToast(msg: 'Failed to update status. Try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void sendWhatsAppReminder(String phoneNumber, String endDate) async {
    // Yeh message customer ko pre-filled milega
    String message =
        "Hi, आपकी VahanServ Car Washing Subscrption की अंतिम तिथि $endDate है, जो कुछ ही दिनों में समाप्त होने वाली है। इसे ज़ारी रखने के लिए अभी कॉल करें +919536609652";

    String encodedMessage = Uri.encodeComponent(message);

    // WhatsApp Business API ka URL
    // final Uri whatsappUrl =
    //     Uri.parse("whatsapp://send?phone=$phoneNumber&text=$encodedMessage");

    // Phone number ko verify karne ke liye
    final Uri finalUrl =
        Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');

    // Launching URL
    if (await canLaunchUrl(finalUrl)) {
      await launchUrl(finalUrl);
    } else {
      // Agar WhatsApp install nahi hai to error handle karein
      if (kDebugMode) {
        print("WhatsApp is not installed on the device.");
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    final recstatus = await Permission.microphone.request();
    final callstatus = await Permission.phone.request();

    if (status.isGranted && recstatus.isGranted && callstatus.isGranted) {
      if (kDebugMode) {
        print("Camera and Microphone permissions granted.");
      }
    } else if (status.isDenied && recstatus.isDenied && callstatus.isDenied) {
      if (kDebugMode) {
        print(
            "Camera and Microphone permissions denied. User explicitly denied.");
      }
      // Optionally show a dialog explaining why permission is needed
    } else if (status.isPermanentlyDenied &&
        recstatus.isPermanentlyDenied &&
        callstatus.isPermanentlyDenied) {
      if (kDebugMode) {
        print(
            "Camera and Microphone permissions permanently denied. User needs to enable from settings.");
      }
      // Guide user to app settings
      openAppSettings(); // Opens app settings for user to manually grant
    } else if (status.isRestricted &&
        recstatus.isRestricted &&
        callstatus.isRestricted) {
      if (kDebugMode) {
        print(
            "Camera and Microphone permissions restricted (e.g., parental controls).");
      }
    }
  }

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

      context.go('/cce');

      // Show success message
      Fluttertoast.showToast(
        msg: "Logged Out Succesfully!",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      // Show error message
      Fluttertoast.showToast(
        msg: "Failed Logging Out!",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents the default pop behavior
      onPopInvoked: (bool didPop) {
        if (didPop) {
          // This case is for when a pop is cancelled, so we can ignore it.
          return;
        }
        final now = DateTime.now();
        final timeDifference = now.difference(_lastPressed ?? now);
        if (timeDifference.inSeconds <= 2) {
          SystemNavigator.pop();
        } else {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: white,
        key: _scaffoldKey,
        drawer: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: _buildDrawer(context),
        ),
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 4,
          backgroundColor: blue,
          leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text: '${AppLocalizations.of(context)!.welcome} CCE ',
                      style: fh20boldWhite,
                      children: [
                    TextSpan(
                        text: widget.cceName.split(' ').first.toUpperCase(),
                        style: fh20boldGreen)
                  ])),
            ],
          ),
          actions: _buildAction(context),
          actionsPadding: pad12,
        ),
        body: RefreshIndicator(
          color: blue,
          backgroundColor: cardColorLightBlue,
          onRefresh: () async {
            await Provider.of<CCEProvider>(context, listen: false)
                .initCCE(widget.cceId);
          },
          child: Consumer<CCEProvider>(
            builder: (context, provider, child) {
              if (kDebugMode) {
                print(
                    'Consumer builder called: isLoading: ${provider.isLoading}, error: ${provider.error}, currentCCE: ${provider.currentCCE?.name}');
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.error}',
                        style: fh14mediumBlack,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(blue)),
                        onPressed: () {
                          provider.clearError();
                          provider.initCCE(widget.cceId);
                        },
                        child: Text(
                          'Retry',
                          style: fh14mediumWhite,
                        ),
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
              if (provider.currentCCE == null) {
                return Center(
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
                        'Loading..',
                        style: fh14regularBlue,
                      )
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: pad8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: buildTimeRestrictionIndicator()),
                      _buildDateSelector(),
                      SizedBox(
                        height: 10,
                      ),
                      provider.assignedCustomers.isNotEmpty
                          ? _buildDailyTasksList(provider)
                          : Center(
                              heightFactor: 6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline_sharp,
                                    size: 40,
                                    color: blue,
                                  ),
                                  SizedBox(height: 10),
                                  Text('No Customers Lined Up',
                                      style: fh14regularGrey),
                                ],
                              ),
                            )
                      //_buildMissedTasksList(provider),
                      //_buildReferralCard(provider),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTimeRestrictionIndicator() {
    if (!canToggleToActive && lastInactiveTime != null) {
      final remaining =
          Duration(hours: 10) - DateTime.now().difference(lastInactiveTime!);
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        return SizedBox.shrink();
      }
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;

      return Container(
        padding: pad8,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(),
        child: Text(
          '${AppLocalizations.of(context)!.markactivein}\n${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: fh12mediumRed,
        ),
      );
    }
    return SizedBox.shrink();
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      InkWell(
        onTap: () {
          showDialog(
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
        },
        child: Icon(
          Icons.logout_rounded,
          size: 24,
          color: white,
        ),
      )
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    final provider = Provider.of<CCEProvider>(context, listen: false);
    final isActive = provider.currentCCE?.isActive ?? true;

    return Drawer(
      backgroundColor: white,
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () {
                launchUrl(Uri.parse(
                    'https://youtu.be/buMLa4p0QQY?si=VoGTJBZv9JdT-NdG'));
              },
              title: Text(
                AppLocalizations.of(context)!.trainingresources,
                style: fh12mediumBlack,
              ),
              leading: Icon(
                Icons.ondemand_video_sharp,
                color: blue,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.language,
                color: blue,
              ),
              title: Consumer<LanguageProvider>(
                builder: (context, provider, child) {
                  return _buildLangBox(provider);
                },
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.active,
                  style: fh12mediumBlack),
              leading: Icon(
                LineIcons.calendarMinusAlt,
                color: red,
              ),
              trailing: Switch(
                  value: isActive,
                  onChanged: (value) {
                    if (!canToggleToActive) {
                      _showRestrictionDialog();
                      return;
                    } else if (numberOfTimesToggled >= 0) {
                      _showLeaveConfirmationDialog(isActive, provider);
                    }
                  },
                  activeColor: white,
                  activeTrackColor: blue,
                  trackOutlineColor: MaterialStateProperty.all<Color>(blue),
                  inactiveTrackColor: white,
                  inactiveThumbColor: blue),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showLeaveConfirmationDialog(
      bool isActive, CCEProvider provider) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isActive
                ? AppLocalizations.of(context)!.masin
                : AppLocalizations.of(context)!.masact,
            style: fh14mediumBlue,
          ),
          content: Text(
            isActive
                ? 'Leaves Remaining for this month: $numberOfTimesToggled\n\n${AppLocalizations.of(context)!.markinactive}'
                : AppLocalizations.of(context)!.markactive,
            style: fh12regularGrey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: fh12regularBlue),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (numberOfTimesToggled > 0 && isActive == true) {
                  _toggleLeaveStatus(isActive);
                } else if (isActive == false) {
                  _toggleLeaveStatus(isActive);
                } else {
                  Fluttertoast.showToast(
                      msg: 'You have 0 leaves left for this month.');
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? red : blue),
              child: Text(
                isActive
                    ? AppLocalizations.of(context)!.masin
                    : AppLocalizations.of(context)!.masact,
                style: fh12mediumWhite,
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleLeaveStatus(bool isActive) {
    final cceProvider = Provider.of<CCEProvider>(context, listen: false);
    final DateTime today = DateTime.now();
    final firestore = FirebaseFirestore.instance;
    if (isActive) {
      setState(() {
        isLoading = true;
        numberOfTimesToggled--;
      });
      _handleCCEInactiveFlow(widget.cceId, cceProvider, isActive);
    } else {
      _handleCCEActiveFlow(firestore, isActive, cceProvider, today);
    }
  }

  void _showRestrictionDialog() {
    if (lastInactiveTime == null) return;

    final now = DateTime.now();
    final timeDifference = now.difference(lastInactiveTime!);
    final remainingTime = Duration(hours: 10) - timeDifference;

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.cannotmarkactive,
              style: fh14mediumBlue),
          content: Text(
            '${AppLocalizations.of(context)!.markactivein} ${hours}h ${minutes}m.',
            style: fh12regularGrey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: fh12regularBlue),
            ),
          ],
        );
      },
    );
  }

  Container _buildLangBox(LanguageProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300), borderRadius: br10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Language>(
          borderRadius: br10,
          dropdownColor: white,
          alignment: AlignmentDirectional.topCenter,
          value: provider.currentLanguage,
          hint: Text(
            'Select Language',
            style: fh12regularGrey,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_sharp,
            color: blue,
          ),
          items: <DropdownMenuItem<Language>>[
            DropdownMenuItem(
              value: Language.english,
              child: Text('English', style: fh12mediumBlue),
            ),
            DropdownMenuItem(
              value: Language.hindi,
              child: Text('हिन्दी', style: fh12mediumBlue),
            ),
          ],
          onChanged: (Language? item) async {
            if (item != null) {
              setState(() {
                selectedLanguage = item;
              });

              if (item == Language.english) {
                Future.delayed(Duration(milliseconds: 1000), () async {
                  provider.changeLang(Locale('en'));
                  await Fluttertoast.showToast(
                      msg:
                          'Language: ${selectedLanguage.toString().split('.').last.toUpperCase()}');
                });
              } else {
                Future.delayed(Duration(milliseconds: 1000), () async {
                  provider.changeLang(Locale('hi'));
                  await Fluttertoast.showToast(
                      msg:
                          'Language: ${selectedLanguage.toString().split('.').last.toUpperCase()}');
                });
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildEarningCard(CCEProvider provider, bool isDarkMode) {
    //final totalEarning = provider.monthlyEarnings;

    return Container(
      padding: pad8,
      decoration: BoxDecoration(
        color: blue,
        borderRadius: br10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.today,
                  style: fh14SemiboldWhite),
              SizedBox(height: 4),
              Card(
                color: white,
                child: Padding(
                  padding: pad8,
                  child: Column(
                    children: [
                      _buildStatusRow(AppLocalizations.of(context)!.com,
                          provider.completedTasksToday),
                      _buildStatusRow(
                          AppLocalizations.of(context)!.pen,
                          provider.pendingTasksToday +
                              provider.missedTasksToday),
                      Divider(),
                      _buildStatusRow(
                          AppLocalizations.of(context)!.tt,
                          provider.completedTasksToday +
                              provider.pendingTasksToday),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: fh12boldBlue),
          Text(count.toString(), style: fh12mediumBlack),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return ClipRRect(
      borderRadius: br10,
      child: Card(
        elevation: 0,
        color: Colors.grey.shade200,
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Expanded(
                  child: Text(AppLocalizations.of(context)!.todaydate,
                      style: fh14mediumBlack)),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: pad8,
                  decoration: BoxDecoration(
                      borderRadius: br10,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 0),
                            blurRadius: 2,
                            spreadRadius: 0,
                            color: shadow)
                      ],
                      color: white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MMM-yyyy').format(selectedDate),
                        style: fh12mediumBlack,
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: blue,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      // Load tasks for the selected date
      Provider.of<CCEProvider>(context, listen: false)
          .loadTasksForDate(selectedDate);
    }
  }*/

  Widget _buildDailyTasksList(CCEProvider provider) {
    final assignedCustomers = provider.assignedCustomers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.dailyassignedtasks,
            style: fh14boldBlack),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration:
                BoxDecoration(color: cardColorLightBlue, borderRadius: br10),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: assignedCustomers.length,
              itemBuilder: (context, index) {
                final customer = assignedCustomers[index];
                // Pass only the customer's cars, not all cars
                return _buildTaskItem(index + 1, customer, provider);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(int index, Customer customer, CCEProvider provider) {
    final isExpanded = _expandedIndex == index;
    final customerCars = customer.cars!;

    //final bool hasUploadedImages = customer.hasUploadedImages == true;
    return InkWell(
      borderRadius: br10,
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedIndex = null;
          } else {
            _expandedIndex = index;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
            color: isExpanded ? blue : cardColorLightBlue,
            borderRadius: br10,
            border: Border.all(color: grey, width: 1)),
        padding: pad8,
        child: isExpanded
            ? _buildExpandedTaskView(customer, customerCars)
            : _buildCollapsedTaskView(index, customer),
      ),
    );
  }

  Widget _buildCollapsedTaskView(int index, Customer customer) {
    return Row(
      children: [
        Text('$index. ', style: fh12mediumBlack),
        Expanded(
          flex: 6,
          child: Text(
            customer.custName!,
            style: fh12mediumBlack,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${customer.numberOfCars} car${customer.numberOfCars! > 1 ? 's' : ''}',
            style: fh12mediumBlack,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Show completion progress for multiple cars
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        //   decoration: BoxDecoration(
        //     color: customer.overallStatusColor,
        //     borderRadius: BorderRadius.circular(5),
        //   ),
        //   child: Text(
        //     customer.overallStatusDisplayText,
        //     style: fh12mediumBlack,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildExpandedTaskView(Customer customer, List<Car> cars) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Customer basic info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            ReusableRow(
                preTitle1: 'Name- ', title1: customer.custName ?? 'N/A'),
            ReusableRow(
                preTitle1: 'Mobile- ', title1: customer.custMobile ?? 'N/A'),
            ReusableRow(preTitle1: 'Address- ', title1: customer.custAddress!),
            ReusableRow(
                preTitle1: 'Start Date- ',
                title1: DateFormat('dd-MM-yyyy').format(customer.startDate!)),
            ReusableRow(
                preTitle1: 'End Date- ',
                title1: DateFormat('dd-MM-yyyy').format(customer.endDate!)),
            if (customer.endDate!.difference(selectedDate).inDays <= 4)
              Text(
                'Subscription ending in ${customer.endDate!.difference(selectedDate).inDays} days.',
                style: fh12mediumRed,
              )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            InkWell(
              onTap: () {
                _handleCarAction(customer.custId, customer.serviceNo!);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    LineIcons.camera,
                    color: white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Upload',
                    style: fh12boldWhite,
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CustomerProfileScreen(
                        custId: customer.custId, cceId: widget.cceId),
                    withNavBar: false);
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: Text(
                    'View Account',
                    style: fh12mediumBlue,
                  ),
                ),
              ),
            ),
            if (customer.endDate!.difference(selectedDate).inDays <= 4)
              InkWell(
                onTap: () {
                  sendWhatsAppReminder(customer.custMobile.toString(),
                      customer.endDate.toString());
                },
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      LineIcons.bell,
                      color: red,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Notify',
                      style: fh12mediumRed,
                    ),
                  ],
                ),
              )
          ],
        ),

        //SizedBox(height: 8),
//cars.isNotEmpty && cars.first.endDate != null
        // Cars section
        // ...cars.asMap().entries.map((entry) {
        //   final carIndex = entry.key;
        //   final car = entry.value;
        //   return _buildCarItem(carIndex + 1, car, customer.custId);
        // }),
        // Overall status
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Container(
        //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        //       decoration: BoxDecoration(
        //         color: customer.overallStatusColor,
        //         borderRadius: BorderRadius.circular(5),
        //       ),
        //       child: Text(
        //         'Overall: ${customer.overallStatusDisplayText}',
        //         style: fh12mediumBlack,
        //       ),
        //     ),
        //     if (cars.length > 1)
        //       Text(
        //         customer.overallStatusDisplayText == 'COM'
        //             ? 'Completed'
        //             : 'Progress: ${(customer.completionPercentage * 100).toInt()}%',
        //         style: fh12mediumWhite,
        //       ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildCarItem(int carIndex, Car car, String custId) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: br10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$carIndex. ',
                style: fh12mediumWhite,
              ),
              Expanded(
                child: Text(
                  '${car.carName} (${car.numberPlate})',
                  style: fh12SemiboldWhite,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: car.statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  car.statusDisplayText,
                  style: fh12mediumBlack,
                ),
              ),
            ],
          ),
          ReusableRow(title1: car.subPlan ?? 'N/A'),
          ReusableRow(
              preTitle1: 'Start Date-',
              title1: DateFormat('dd-MMM-yyyy').format(car.startDate!)),
          ReusableRow(
              preTitle1: 'End Date-',
              title1: DateFormat('dd-MMM-yyyy').format(car.endDate!)),
          // Action buttons for individual car
        ],
      ),
    );
  }

  void _handleCarAction(String custId, int serviceNo) {
    // Navigate to camera for specific car
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: CameraScreen(
        custId: custId,
        serviceNo: serviceNo,
      ),
      withNavBar: false,
    );
  }

  Widget _buildReferralCard(CCEProvider provider) {
    final cce = provider.currentCCE;
    if (cce == null) {
      return SizedBox.shrink(); // Return empty widget if cce is null
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: pad8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                          text: AppLocalizations.of(context)!.refferal1,
                          style: fh14boldBlue,
                          children: [
                        TextSpan(text: 'CCE ', style: fh14boldGreen, children: [
                          TextSpan(
                              text: AppLocalizations.of(context)!.refferal2,
                              style: fh14boldBlue,
                              children: [
                                TextSpan(
                                    text:
                                        AppLocalizations.of(context)!.refferal3,
                                    style: fh14boldGreen,
                                    children: [
                                      TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .refferal4,
                                          style: fh14boldBlue)
                                    ])
                              ])
                        ])
                      ]))
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding: pad8,
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: br10,
                ),
                child: SelectableText(cce.referralCode, style: fh16boldWhite),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.share,
                color: blue,
              ),
              onPressed: () {
                SharePlus.instance.share(ShareParams(
                    text: 'Use this refferal code: ${cce.referralCode}'));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReusableRow extends StatelessWidget {
  ReusableRow(
      {super.key,
      this.title1 = '',
      this.title2 = '',
      this.preTitle1 = '',
      this.preTitle2 = ''});
  String title1;
  String title2;
  String? preTitle1;
  String? preTitle2;

  @override
  Widget build(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$preTitle1 $title1',
              style: fh12mediumWhite,
            ),
          ),
          Text(
            '$preTitle2 $title2',
            style: fh12mediumWhite,
          ),
        ],
      ),
    );
  }
}
