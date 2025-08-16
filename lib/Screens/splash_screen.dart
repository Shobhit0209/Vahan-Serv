// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for a short duration to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    final authProvider = Provider.of<AuthProvidar>(context, listen: false);
    await authProvider.checkLoginStatus; // Ensure login status is checked

    if (authProvider.isLoggedIn) {
      // Navigate to your main app screen using persisted cceId and cceName
      if (authProvider.cceId != null && authProvider.cceName != null) {
        context.go(
            '/navbar-screen/${authProvider.cceId}/${authProvider.cceName}',
            extra: true);
      } else {
        // Handle the case where cceId or cceName is missing (e.g., show an error or navigate to a default screen)
        context.go('/lang'); // Or another appropriate route
        log('Error: cceId or cceName is null after login.');
      }
    } else {
      // Navigate to your authentication screen
      context.go('/lang');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
          child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: blue,
        ),
        child: Image.asset('assets/logo/VAHAN SERV wo bg.png'),
      )),
    );
  }
}
