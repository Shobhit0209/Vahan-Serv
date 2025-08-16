// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahanserv/Constants/constants.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTapLeading;
  final int index;
  bool isleadingNeeded;
  double space;
  AppBarWidget(
      {super.key,
      required this.title,
      this.onTapLeading,
      required this.index,
      this.space = 1,
      this.isleadingNeeded = true});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default height

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionIcons = [
      Icon(
        Icons.help_outline_rounded,
        size: 20,
        color: white,
      ),
    ];

    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 4,
      shadowColor: shadow,
      backgroundColor: blue,
      foregroundColor: white,
      leading: isleadingNeeded
          ? Padding(
              padding: pad12,
              child: InkWell(
                onTap: onTapLeading,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: white,
                ),
              ),
            )
          : null,
      actionsPadding: pad12,
      actions: [
        InkWell(
            onTap: () async {
              String cleanNumber =
                  '9528202134'.toString().replaceAll(RegExp(r'[^0-9]'), '');
              if (cleanNumber.length >= 10) {
                String last10Digits =
                    cleanNumber.substring(cleanNumber.length - 10);
                await _makePhoneCall('+91$last10Digits');
              }
            },
            child: actionIcons[index])
      ],
      title: Text(
        title,
        style: fh16regularWhite,
      ),
      titleSpacing: space,
    );
  }
}
