import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vahanserv/Screens/CCE%20Section/cce_dashboard_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/display_images.dart';
import 'package:vahanserv/Screens/CCE%20Section/earning_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/find_me_screen.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/customer_login_screen.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/customer_otp_screen.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/customer_home_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/language_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/otp_screen.dart';
import 'package:vahanserv/Screens/nav_bar.dart';
import 'package:vahanserv/Screens/role_screen.dart';
import 'package:vahanserv/Screens/splash_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/verify_phone.dart';

GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/', // initial route
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
        path: '/lang', // <— Language Screen
        builder: (context, state) => const LanguageScreen()),
    GoRoute(
      path: '/home', // <— Home route
      builder: (context, state) => const CustomerHomeScreen(),
    ),
    GoRoute(
      path: '/role', // <— RoleSelection route
      builder: (context, state) => const RoleScreen(),
    ),
    GoRoute(
      path: '/cce', // <— CCE Login route
      builder: (context, state) => const FindMeScreen(),
    ),
    GoRoute(
      path: '/customer', // <— Customer Login route
      builder: (context, state) => const CustomerLoginScreen(),
    ),
    GoRoute(
      path: '/verifyPhone', // <— Verify Phone Numer Screen
      builder: (context, state) => const VerifyPhone(),
    ),
    GoRoute(
        path: '/otpscreen/:verificationId/:phone',
        builder: (context, state) {
          final id = state.pathParameters['verificationId']!;
          final phone = state.pathParameters['phone']!;
          return OtpScreen(
            verificationId: id,
            phone: phone,
          );
        }),
    GoRoute(
      path: '/customerOtp', // <— Verify Phone Numer Screen
      builder: (context, state) => const CustomerOtpScreen(),
    ),
    GoRoute(
        path: '/cce-dashboard/:cceId/:cceName', // <— CCE Dashboard
        builder: (context, state) {
          final cceId = state.pathParameters['cceId']!;
          final cceName = state.pathParameters['cceName']!;

          return CCEDashboardScreen(
            cceId: cceId,
            cceName: cceName,
          );
        }),
    GoRoute(
        path: '/navbar-screen/:cceId/:cceName', // <— CCE Dashboard
        builder: (context, state) {
          final cceId = state.pathParameters['cceId']!;
          final cceName = state.pathParameters['cceName']!;
          return NavBarScreen(
            cceId: cceId,
            cceName: cceName,
          );
        }),
    GoRoute(
      path: '/display_images',
      builder: (BuildContext context, GoRouterState state) {
        final XFile? images = state.extra as XFile?;
        final String custId = state.extra as String;
        final int serviceNo = state.extra as int;
        // final String carId = state.extra as String;
        return DisplayImages(
            images: images, custId: custId, serviceNo: serviceNo);
      },
    ),
    GoRoute(
      path: '/earnings',
      builder: (BuildContext context, GoRouterState state) {
        final String cceId = state.extra as String;
        return EarningScreen(
          cceId: cceId,
        );
      },
    ),
  ],
);
