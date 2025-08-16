import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/payment_screen.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key, required this.planType});
  final String planType;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late int displayMonths;
  @override
  void initState() {
    super.initState();
    displayMonths = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: pad8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  _buildAppBar(context),
                  Text(
                    'Select Your Vehicle',
                    style: fh14SemiboldBlack,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: white,
                          boxShadow: boxShadow,
                          borderRadius: br10),
                      child: Image.asset(
                        'assets/customer/Add Car.png',
                        scale: 12,
                      ),
                    ),
                  ),
                  _buildMonthSelection(),
                  Text(
                    'Select Your Address',
                    style: fh14SemiboldBlack,
                  ),
                  _buildAddressBox(),
                ],
              ),
            ),
          )),
          _buyNowButton(context),
        ],
      )),
    );
  }

  Padding _buyNowButton(BuildContext context) {
    return Padding(
      padding: pad8,
      child: InkWell(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(context,
              screen: PaymentScreen(
                planType: widget.planType,
                numberOfMonths: displayMonths.toString(),
              ),
              withNavBar: false);
        },
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: blue,
            borderRadius: br10,
          ),
          child: Center(
              child: Text(
            'Buy Now',
            style: fh16SemiboldWhite,
          )),
        ),
      ),
    );
  }

  Widget _buildMonthSelection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Months You Want Service For',
          style: fh14SemiboldBlack,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (displayMonths != 0) displayMonths--;
                });
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5))),
                child: Center(
                    child: Text(
                  '-',
                  style: fh20regularBlack,
                )),
              ),
            ),
            SizedBox(
              height: 30,
              width: 30,
              child: Center(
                  child: Text(
                displayMonths.toString(),
                style: fh12regularBlack,
              )),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  displayMonths++;
                });
              },
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: Icon(
                    Icons.add,
                    size: 16,
                  )),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAddressBox() {
    return Container(
        padding: pad8,
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: br10,
            border: Border.all(color: grey)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'A-101, Avas Vikas,\nKichha, Udham Singh Nagar,\nPincode-263148,\nUttarakhand.',
                    style: fh12regularBlack,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Add New Address',
                    style: fh12mediumBlue,
                  ),
                )
              ],
            ),
            Text(
              'Edit Address',
              style: fh12mediumBlue,
            )
          ],
        ));
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.black,
            size: 30,
          ),
        ),
        Expanded(
          child: Text(
            '${widget.planType} Car Wash Subscription Plan',
            style: fh16SemiboldBlue,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
