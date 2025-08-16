// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Providers/auth_provider.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Services/firestore_services.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FocusNode _focusNode = FocusNode();
  Future<void> _verifyOtp() async {
    final auth = Provider.of<AuthProvidar>(context, listen: false);
    final authCCE = Provider.of<CCEProvider>(context, listen: false);
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      Fluttertoast.showToast(
        msg: "Enter 6-digit OTP.",
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      final cceId = await _firestoreService.getCCEIdByPhoneNumber(widget.phone);
      log(widget.phone);

      if (cceId == null) {
        Fluttertoast.showToast(
          msg: 'CCE not found for this mobile number',
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      final cce = await _firestoreService.getCCE(cceId);

      if (cce == null) {
        Fluttertoast.showToast(
          msg: 'Falied to retreive CCE data',
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      //  ✅ OTP verified successfully
      // 2. Fetch CCE data from Firestore AFTER successful authentication
      if (kDebugMode) {
        print(widget.phone);
      }
      if (kDebugMode) {
        print(cceId);
      }

      authCCE.initCCE(cceId);

      // Pass cceId and cceName to auth.verifyOtp
      await auth.verifyOtp(otp, () {
        context.go('/navbar-screen/${cce.cceId}/${cce.name}');
        Fluttertoast.showToast(
          msg: 'Logged in as ${cce.name}',
          toastLength: Toast.LENGTH_SHORT,
        );
      }, (error) {
        // ❌ OTP verification failed
        Fluttertoast.showToast(
          msg: 'OTP verification failed :$error ',
          toastLength: Toast.LENGTH_SHORT,
        );
      }, cce.cceId, cce.name); // Pass cceId and cceName here
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occured',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvidar>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/verifyPhone');
        }
      },
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.loginusingotp,
          index: 0,
          onTapLeading: () => context.go('/verifyPhone'),
        ),
        body: Padding(
          padding: pad8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.enterotp} +91${widget.phone}',
                      style: fh16mediumBlack,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildOtpTextField(),
                    if (auth.isLoading)
                      Center(
                        heightFactor: 4,
                        child: Column(
                          children: [
                            LottieBuilder.asset(
                              'assets/cce/second animation.json',
                              height: 60,
                              width: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Logging In',
                              style: fh14mediumBlue,
                            )
                          ],
                        ),
                      ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.60,
                    ),
                  ],
                ),
              )),
              otpController.text.length != 6
                  ? SizedBox.shrink()
                  : auth.isLoading
                      ? SizedBox.shrink()
                      : Button(
                          title: AppLocalizations.of(context)!.login,
                          onTapped: () {
                            _verifyOtp();
                          })
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildOtpTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      focusNode: _focusNode,
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
      style: fh14SemiboldBlue,
      controller: otpController,
      cursorColor: blue,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: "6-digit OTP",
        counterText: '',
        hintStyle: fh14mediumGrey,
        border: OutlineInputBorder(
          borderRadius: br10,
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: br10, borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: br10,
            borderSide: BorderSide(
              color: blue,
              width: 2,
            )),
      ),
    );
  }
}
