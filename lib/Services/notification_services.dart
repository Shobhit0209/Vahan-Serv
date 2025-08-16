// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Models/notification_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/notification_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/earning_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isInitialized = false;
  NotificationProvider? _notificationProvider;
  Future<void> setNotificationProvider(NotificationProvider provider) async {
    _notificationProvider = provider;
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        provisional: true,
        criticalAlert: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Notification Permisioin granted');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('Provisional Notification Permisioin granted');
      }
    } else {
      AppSettings.openAppSettings;
      if (kDebugMode) {
        print('Permission denied');
      }
    }
  }

  void initLocalNotification(BuildContext context,
      [RemoteMessage? message]) async {
    if (_isInitialized) return;
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings);
    var provider = Provider.of<NotificationProvider>(context, listen: false);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleNotificationTap(context, response);
    });
    await setNotificationProvider(provider);
    _isInitialized = true;
  }

  void _handleNotificationTap(
      BuildContext context, NotificationResponse response) {
    final cceProvider = Provider.of<CCEProvider>(context, listen: false);
    if (kDebugMode) {
      print('Notification tapped with payload: ${response.payload}');
    }

    // Parse payload to determine action
    if (response.payload != null) {
      try {
        // You can parse JSON payload or use simple string format
        if (_notificationProvider != null) {
          _notificationProvider!
              .markAsRead(response.payload!, cceProvider.currentCCE!.cceId);
        }
        if (response.payload!.contains('payment')) {
          _navigateToEarningScreen(context);
        }
        // Add more navigation logic based on payload
      } catch (e) {
        if (kDebugMode) {
          print('Error handling notification tap: $e');
        }
      }
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      final cceProvider = Provider.of<CCEProvider>(context, listen: false);
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
      }
      if (_notificationProvider != null) {
        if (kDebugMode) {
          print('Inside Firebase Init');
        }
        final notification = NotificationModel.fromFirebaseMessage(message);
        _notificationProvider!
            .addNotification(notification, cceProvider.currentCCE!.cceId);
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Channel Description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      playSound: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        notificationDetails,
        payload: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
      );
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Local notifications not initialized');
      }
      return;
    }
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        'local_notifications', 'Local Notifications',
        description: 'Channel for local app notifications',
        importance: Importance.high);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isRefreshToken() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  Future<void> setUpInteractMessage(BuildContext context) async {
    final cceProvider = Provider.of<CCEProvider>(context, listen: false);
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (_notificationProvider != null) {
        final notification =
            NotificationModel.fromFirebaseMessage(initialMessage);
        _notificationProvider!
            .addNotification(notification, cceProvider.currentCCE!.cceId);
      }
      _handleMessageBackground(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Add to notification provider
      if (_notificationProvider != null) {
        final notification = NotificationModel.fromFirebaseMessage(message);
        _notificationProvider!
            .addNotification(notification, cceProvider.currentCCE!.cceId);
      }
      _handleMessageBackground(message);
    });
  }

  void _handleMessageBackground(RemoteMessage message) {
    if (message.data['type'] == 'payment') {
      BuildContext? context = navigatorKey.currentContext;
      if (context != null) {
        handleMessage(context, message);
      }
    }
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (kDebugMode) {
      print('Handling message with data: ${message.data}');
    }

    if (message.data['type'] == 'payment') {
      _navigateToEarningScreen(context);
    }
  }

  void _navigateToEarningScreen(BuildContext context) {
    try {
      CCEProvider provider = Provider.of<CCEProvider>(context, listen: false);

      if (provider.currentCCE != null) {
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: EarningScreen(cceId: provider.currentCCE!.cceId));
      } else {
        if (kDebugMode) {
          print('currentCCE is null - cannot navigate to earning screen');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to earning screen: $e');
      }
    }
  }
}
