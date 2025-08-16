import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/checkout_screen.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  const SubscriptionDetailScreen({super.key, required this.planType});
  final String planType;
  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: pad8,
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/customer/car washing.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              "You're getting:",
              style: fh14mediumGrey,
            ),
            BulletPoint(text: '${widget.planType} Exterior car wash.'),
            BulletPoint(
                text:
                    'Shampoo wash and interior cleaning (manual) once in a week.'),
            BulletPoint(text: 'Car Wash at your convinient time and Place.'),
            Spacer(),
            InkWell(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CheckOutScreen(
                      planType: widget.planType,
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
                  'Subscribe Now',
                  style: fh16SemiboldWhite,
                )),
              ),
            )
          ],
        ),
      )),
    );
  }

  Row _buildAppBar(BuildContext context) {
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
        Text(
          'Subscription Details',
          style: fh16SemiboldBlue,
        )
      ],
    );
  }
}

class BulletPoint extends StatelessWidget {
  const BulletPoint({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Icon(
          Icons.circle,
          size: 6,
          color: grey,
        ),
        Expanded(
            child: Text(
          text,
          style: fh14regularGrey,
        )),
      ],
    );
  }
}
