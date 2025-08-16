import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahanserv/Constants/constants.dart'; // For opening URLs

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  // Function to open URLs
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error, e.g., show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        title: const Text('About App'),
        titleSpacing: 0,
        titleTextStyle: fh16regularBlue,
        backgroundColor: white,
        foregroundColor: blue,
      ),
      body: ListView(
        padding: pad8,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: br10,
              child: Image(
                  image: AssetImage('assets/logo/vahan serve full logo.png')),
            ),
            title: Text(
              appName.toString(),
              style: fh16SemiboldBlack,
            ),
          ),
          ListTile(
            title: Text(
              'Version',
              style: fh12mediumBlack,
            ),
            trailing: Text(
              version.toString(),
              style: fh12mediumBlack,
            ),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: fh12mediumBlack,
            ),
            onTap: () {
              _launchURL(
                  'https://doc-hosting.flycricket.io/vahan-serv-privacy-policy/f802be83-7f1c-4be9-8366-23cb78187843/privacy');
            },
          ),
          ListTile(
            title: Text(
              'Contact Us',
              style: fh12mediumBlack,
            ),
            onTap: () {
              _launchURL('mailto:vahanserv2023@gmail.com?subject=App Support');
            },
          ),
        ],
      ),
    );
  }
}
