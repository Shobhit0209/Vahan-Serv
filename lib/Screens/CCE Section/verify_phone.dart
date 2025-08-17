import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Providers/auth_provider.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({super.key});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final TextEditingController phoneController = TextEditingController();
  final _focusNode = FocusNode();

  void getOtp() {
    final phone = phoneController.text.trim();
    if (phone.length != 10) {
      Fluttertoast.showToast(msg: 'Enter the 10-digit mobile number');
      return;
    }

    final auth = Provider.of<AuthProvidar>(context, listen: false);
    auth.startPhoneAuth(
      phone: phone,
      onVerified: () {},
      onCodeSent: () {
        // Code sent successfully
        final verificationId = auth.verificationId;
        context.go('/otpscreen/$verificationId/$phone');
      },
      onError: (error) {
        Fluttertoast.showToast(msg: 'Error: $error');
      },
    );
  }

  @override
  void initState() {
    phoneController.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvidar>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/cce');
        }
      },
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.mobilenoverify,
          index: 0,
          onTapLeading: () => context.go('/cce'),
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
                      AppLocalizations.of(context)!.entermobile,
                      style: fh16mediumBlack,
                    ),
                    SizedBox(height: 20),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: phoneController,
                      builder: (context, value, child) {
                        return _buildMobileTextField();
                      },
                    ),
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
                              'Wait..',
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
              phoneController.text.length != 10
                  ? SizedBox.shrink()
                  : auth.isLoading
                      ? SizedBox.shrink()
                      : Button(
                          title: AppLocalizations.of(context)!.getotp,
                          onTapped: getOtp),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildMobileTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      focusNode: _focusNode,
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
      style: fh14SemiboldBlue,
      controller: phoneController,
      cursorColor: blue,
      maxLength: 10,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
        hintText: "10-digit phone number",
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
        prefix: Row(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/customer/india.png',
              height: 20,
            ),
            Text(
              '+91',
              style: fh14mediumBlack,
            ),
            SizedBox(
              width: 5,
            )
          ],
        ),
      ),
    );
  }
}
