import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/customer_otp_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  TextEditingController mobileController = TextEditingController();
  @override
  void initState() {
    super.initState();
    mobileController.addListener(() {
      setState(() {}); // updates UI when text changes
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            context.go('/role');
          }
        },
        child: Scaffold(
          backgroundColor: white,
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: pad12,
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 150,
                    child: Image(
                      image: AssetImage('assets/logo/VAHAN SERV blue.png'),
                    ),
                  ),
                ),
                Text(
                  "Login to continue",
                  style: fh20mediumBlack,
                ),
                Text(
                  "We'll send you an OTP to verify.",
                  style: fh12regularGrey,
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: _buildMobileTextfield(),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: mobileController.text.length == 10
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: CustomerOtpScreen(), withNavBar: false);
                          }
                        }
                      : null,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: mobileController,
                    builder: (context, value, child) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 15,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: mobileController.text.length == 10
                              ? blue
                              : shadow,
                          borderRadius: br10,
                        ),
                        child: Center(
                            child: Text(
                          'Send OTP',
                          style: fh16SemiboldWhite,
                        )),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By continuing, you agree to our ',
                          style: fh10SemiboldGrey),
                      InkWell(
                        onTap: () {},
                        child:
                            Text('Terms & Conditions', style: fh10SemiboldBlue),
                      )
                    ],
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
        ));
  }

  TextFormField _buildMobileTextfield() {
    return TextFormField(
      controller: mobileController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      cursorColor: blue,
      focusNode: _focusNode,
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
      style: fh16SemiboldBlack,
      decoration: InputDecoration(
        hintText: 'Mobile Number',
        hintStyle: fh16regularGrey,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54), borderRadius: br10),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54), borderRadius: br10),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54, width: 2),
            borderRadius: br10),
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
              style: fh16mediumBlack,
            ),
            SizedBox(
              width: 5,
            )
          ],
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length != 10) {
          return 'Enter a valid 10-digit number';
        }
        return null;
      },
    );
  }
}
