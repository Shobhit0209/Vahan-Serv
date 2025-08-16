// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CCE%20Section/cce_dashboard_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/cce_profile_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/earning_screen.dart';
import 'package:vahanserv/Screens/CCE%20Section/notification_screen.dart';

final GlobalKey<NavBarScreenState> navBarKey = GlobalKey<NavBarScreenState>();

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({
    super.key,
    required this.cceId,
    required this.cceName,
  });
  final String cceId;
  final String cceName;

  @override
  State<NavBarScreen> createState() => NavBarScreenState();
}

class NavBarScreenState extends State<NavBarScreen> {
  final pageController = PersistentTabController(initialIndex: 0);
  List<Widget> screenList() {
    return [
      CCEDashboardScreen(cceId: widget.cceId, cceName: widget.cceName),
      // EarningScreen(
      //   cceId: widget.cceId,
      // ),
      NotificationScreen(
        cceId: widget.cceId,
      ),
      CCEProfileScreen(
        cceId: widget.cceId,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> navBarItem() {
    return [
      PersistentBottomNavBarItem(
          icon: Image(
            image: AssetImage('assets/cce/dashboard.png'),
            height: 20,
            width: 20,
            color: white,
          ),
          inactiveIcon: Image(
            image: AssetImage('assets/cce/dashboard outline.png'),
            height: 20,
            width: 20,
            color: white,
          ),
          //title: AppLocalizations.of(context)!.home,
          textStyle: fh12mediumWhite,
          activeColorPrimary: white),
      // PersistentBottomNavBarItem(
      //     icon: Image(
      //       image: AssetImage('assets/cce/Earnings.png'),
      //       height: 20,
      //       width: 20,
      //       color: white,
      //     ),
      //     inactiveIcon: Image(
      //       image: AssetImage('assets/cce/Earnings outline.png'),
      //       height: 20,
      //       width: 20,
      //       color: white,
      //     ),
      //     title: AppLocalizations.of(context)!.earnings,
      //     textStyle: fh12mediumWhite,
      //     activeColorPrimary: white),
      PersistentBottomNavBarItem(
          icon: Image(
            image: AssetImage('assets/cce/notificaton bell filled.png'),
            height: 20,
            width: 20,
            color: blue,
          ),
          inactiveIcon: Image(
            image: AssetImage('assets/cce/notification outline.png'),
            height: 20,
            width: 20,
            color: blue,
          ),
          // title: AppLocalizations.of(context)!.notification,
          textStyle: fh12mediumWhite,
          activeColorPrimary: white),
      PersistentBottomNavBarItem(
          icon: Image(
            image: AssetImage('assets/cce/Profile.png'),
            height: 20,
            width: 20,
            color: white,
          ),
          inactiveIcon: Image(
            image: AssetImage('assets/cce/profile outline.png'),
            height: 20,
            width: 20,
            color: white,
          ),
          // title: AppLocalizations.of(context)!.profile,
          textStyle: fh12mediumWhite,
          activeColorPrimary: white),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      key: navBarKey,
      screens: screenList(),
      items: navBarItem(),
      controller: pageController,
      navBarStyle: NavBarStyle.style17,
      backgroundColor: blue,
      padding: EdgeInsets.only(top: 5, bottom: 5),
    );
  }
}
