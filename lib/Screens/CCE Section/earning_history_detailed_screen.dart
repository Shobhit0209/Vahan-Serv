// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vahanserv/Constants/constants.dart';

class EarningHistoryDetailedScreen extends StatefulWidget {
  const EarningHistoryDetailedScreen({
    super.key,
    required this.custname,
    required this.numberplate,
    required this.subplan,
    required this.servicenumber,
    required this.address,
    required this.amount,
    required this.time,
  });
  final String custname;
  final String numberplate;

  final String subplan;
  final int servicenumber;
  final String address;
  final double amount;
  final String time;

  @override
  State<EarningHistoryDetailedScreen> createState() =>
      _EarningHistoryDetailedScreenState();
}

class _EarningHistoryDetailedScreenState
    extends State<EarningHistoryDetailedScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  Future<void> captureAndShareScreenshot(double pixRatio) async {
    final image = await screenshotController.capture(
        pixelRatio: pixRatio, delay: const Duration(milliseconds: 10));
    if (image != null) {
      shareScreenshot(image);
    }
  }

  Future<void> shareScreenshot(Uint8List image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = await File('${directory.path}/image.png').create();
    await imagePath.writeAsBytes(image);

    /// Share Plugin
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(imagePath.path)]);
    await imagePath.delete();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return SafeArea(
        child: Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('Received Successfuly'),
        titleTextStyle: fh20regularBlue,
        titleSpacing: 0,
        foregroundColor: blue,
        actions: [
          InkWell(
            onTap: () => captureAndShareScreenshot(pixelRatio),
            child: Icon(
              Icons.share_outlined,
              color: blue,
              size: 24,
            ),
          ),
          SizedBox(
            width: 10,
          ),
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
            child: Icon(
              Icons.help_outline_rounded,
              color: blue,
              size: 24,
            ),
          ),
        ],
        actionsPadding: pad12,
        backgroundColor: white,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: pad12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppBar().preferredSize.height),
            Screenshot(
              controller: screenshotController,
              child: _buildScreenshot(),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildScreenshot() {
    return Container(
      decoration: BoxDecoration(color: white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              child: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.custname,
                    style: fh16SemiboldBlue,
                  ),
                  Text(
                    'Car Number - ${widget.numberplate}',
                    style: fh14regularBlack,
                  ),
                  Text(
                    'Subscription Plan - ${widget.subplan}',
                    style: fh14regularBlack,
                  ),
                  Text(
                    'Service Number - ${widget.servicenumber}',
                    style: fh14regularBlack,
                  ),
                  Text(
                    'Address-${widget.address}',
                    style: fh14regularBlack,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 2,
                      children: [
                        Text(
                          'Received',
                          style: fh16regularGrey,
                        ),
                        Text(
                          '₹${widget.amount.toStringAsFixed(0)}',
                          style: fh24boldBlue,
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            widget.time,
                            style: fh16regularGrey,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
