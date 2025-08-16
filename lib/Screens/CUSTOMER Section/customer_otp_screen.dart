import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/create_customer_profile_screen.dart';

class CustomerOtpScreen extends StatefulWidget {
  const CustomerOtpScreen({super.key});

  @override
  State<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<CustomerOtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  TextEditingController otpController = TextEditingController();
  int _secondsRemaining = 20;
  bool _enableResend = false;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    otpController.addListener(() {
      setState(() {}); // updates UI when text changes
    });
    startCountdown();
  }

  void startCountdown() {
    _enableResend = false;
    _secondsRemaining = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _timer.cancel();
        setState(() {
          _enableResend = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: pad12,
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            InkWell(
              onTap: () {
                PersistentNavBarNavigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.black,
                size: 30,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "OTP Verification",
              style: fh20mediumBlack,
            ),
            Text(
              "Please enter the OTP sent to (phone).",
              style: fh12regularGrey,
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: otpController,
                keyboardType: TextInputType.phone,
                maxLength: 6,
                cursorColor: blue,
                focusNode: _focusNode,
                onTapOutside: (event) {
                  _focusNode.unfocus();
                },
                style: fh16SemiboldBlack,
                decoration: InputDecoration(
                  hintText: 'OTP',
                  hintStyle: fh16regularGrey,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                      borderRadius: br10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54),
                      borderRadius: br10),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54, width: 2),
                      borderRadius: br10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 6) {
                    return 'Enter a valid 6-digit OTP';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            _enableResend
                ? InkWell(
                    onTap: () {
                      startCountdown();
                    },
                    child: Text(
                      'Resend OTP',
                      style: fh12mediumBlue,
                    ),
                  )
                : Text('Resend OTP in $_secondsRemaining seconds',
                    style: fh12regularGrey),
            SizedBox(height: 10),
            InkWell(
              onTap: otpController.text.length == 6
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: CreateCustomerProfileScreen(),
                            withNavBar: false);
                      }
                    }
                  : null,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: otpController,
                builder: (context, value, child) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: otpController.text.length == 6 ? blue : shadow,
                      borderRadius: br10,
                    ),
                    child: Center(
                        child: Text(
                      'Proceed',
                      style: fh16SemiboldWhite,
                    )),
                  );
                },
              ),
            ),
            Spacer(),
            Image.asset(
              'assets/customer/login_Illustro.png',
              height: 350,
              width: 400,
            )
          ],
        ),
      ),
    );
  }
}
