// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vahanserv/Helpers/app_themes.dart';
import 'package:vahanserv/Providers/auth_provider.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/language_provider.dart';
import 'package:vahanserv/Providers/notification_provider.dart';
import 'package:vahanserv/Routes/routes.dart';
import 'package:vahanserv/Services/notification_services.dart';
import 'firebase_options.dart';

NotificationServices notificationServices = NotificationServices();
final FlutterLocalization localization = FlutterLocalization.instance;

// Data class for passing initialization data between isolates
class InitializationData {
  final String langCode;
  final bool isDebugMode;

  InitializationData({
    required this.langCode,
    required this.isDebugMode,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation immediately - this must be on main thread
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Show splash screen or loading indicator early
  runApp(const InitializingApp());

  try {
    // Initialize critical services first (these must be on main thread)
    final criticalResults = await _initializeCriticalServices();
    final sharedPrefs = criticalResults['sharedPrefs'] as SharedPreferences;
    final langCode = sharedPrefs.getString('lang_code') ?? '';

    // Initialize language provider on main thread (UI related)
    final languageProvider = LanguageProvider();
    await languageProvider.initializeLanguage(langCode);

    // Initialize non-critical services in background isolate
    final initData = InitializationData(
      langCode: langCode,
      isDebugMode: kDebugMode,
    );

    // Start background initialization
    _initializeBackgroundServices(initData);

    // Launch the main app immediately with essential services
    runApp(_buildMainApp(languageProvider));
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(_buildErrorApp(e.toString()));
  }
}

// Initialize only the most critical services on main thread
Future<Map<String, dynamic>> _initializeCriticalServices() async {
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  return {
    'sharedPrefs': results[0],
    'firebaseApp': results[1],
  };
}

// Initialize background services using compute or manual isolate
void _initializeBackgroundServices(InitializationData initData) {
  // Use compute for CPU-intensive tasks
  compute(_backgroundInitializationTask, initData).then((result) {
    print('Background initialization completed: $result');
  }).catchError((error) {
    print('Background initialization failed: $error');
  });

  // Initialize notifications asynchronously on main thread (requires main thread for platform channels)
  Future.microtask(() => _initializeNotificationsAsync());

  // Initialize App Check asynchronously
  if (!initData.isDebugMode) {
    Future.microtask(() => _initializeAppCheckAsync());
  }
}

// This runs in a separate isolate
Future<String> _backgroundInitializationTask(InitializationData data) async {
  try {
    // Simulate heavy initialization work that doesn't require main thread
    // For example: cache warming, data preprocessing, etc.

    // Note: Firebase operations generally need main thread, so this is mainly
    // for heavy computation tasks

    await Future.delayed(Duration(milliseconds: 100)); // Simulate work

    return 'Background tasks completed successfully';
  } catch (e) {
    return 'Background tasks failed: $e';
  }
}

// Async initialization for notifications (must be on main thread)
Future<void> _initializeNotificationsAsync() async {
  try {
    notificationServices.requestNotificationPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBgHandler);
    if (kDebugMode) {
      print('Notifications initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing notifications: $e');
    }
  }
}

// Async initialization for App Check
Future<void> _initializeAppCheckAsync() async {
  try {
    await FirebaseAppCheck.instance.activate(
      webProvider:
          ReCaptchaV3Provider('6LcHJ5krAAAAAD7ClW2cnSsMr3s9vhWV9vVCyLzt'),
      androidProvider: AndroidProvider.playIntegrity,
    );
    print('App Check initialized for RELEASE build');
  } catch (e) {
    print('App Check initialization failed: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Message data: ${message.data}');
    print('Message type: ${message.data['type']}');
    print('Message title: ${message.notification!.title.toString()}');
  }
}

// Build the main app widget
Widget _buildMainApp(LanguageProvider languageProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvidar(), lazy: true),
      ChangeNotifierProvider(create: (_) => CCEProvider(), lazy: true),
      ChangeNotifierProxyProvider<CCEProvider, NotificationProvider>(
        create: (_) => NotificationProvider(cceId: ''),
        update: (context, cceProvider, previousNotificationProvider) {
          final cceId = cceProvider.currentCCE?.cceId ?? '';
          return NotificationProvider(cceId: cceId);
        },
      ),
      //ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: languageProvider),
    ],
    child: const VahanServApp(),
  );
}

// Build error app in case of initialization failure
Widget _buildErrorApp(String error) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('App Initialization Failed'),
            SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Restart the app
                main();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Loading app shown during initialization
class InitializingApp extends StatelessWidget {
  const InitializingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your app logo here
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'VahanServ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}

class VahanServApp extends StatelessWidget {
  const VahanServApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          title: 'VahanServ',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme,
          themeMode: ThemeMode.system,
          locale: provider.appLocale ?? Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('hi'),
          ],
        );
      },
    );
  }
}
