import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/notification_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/notification_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/customer_profile_screen.dart';
import 'package:vahanserv/Widgets/notification_tile.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.cceId});
  final String cceId;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false).initCCE(widget.cceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.notification,
            style: fh16regularWhite,
          ),
          backgroundColor: blue,
          foregroundColor: Colors.white,
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return PopupMenuButton<String>(
                  color: white,
                  borderRadius: br10,
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_all_read':
                        provider.markAllAsRead(widget.cceId);
                        break;
                      case 'clear_all':
                        _showClearAllDialog(context, provider, widget.cceId);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_all_read',
                      child: Text(
                        AppLocalizations.of(context)!.markallasread,
                        style: fh14mediumBlue,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear_all',
                      child: Text(AppLocalizations.of(context)!.clearall,
                          style: fh14mediumBlue),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LineIcons.bell,
                      size: 50,
                      color: blue,
                    ),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.nonotiyet,
                        style: fh14regularGrey),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () {
                    provider.markAsRead(notification.id, widget.cceId);

                    _handleNotificationTap(context, notification);
                  },
                  onDismiss: () {
                    provider.removeNotification(notification.id, widget.cceId);
                  },
                );
              },
            );
          },
        ));
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case 'payment':
        // Navigate to payment/earning screen
        break;
      case 'meeting':
        // Show meeting details or navigate to meeting screen
        _showMeetingDetails(context, notification);
      case 'task_completion':
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: CustomerProfileScreen(
                custId: notification.data['custId'], cceId: widget.cceId),
            withNavBar: false);
        break;
      default:
        // Show notification details
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showMeetingDetails(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Meeting Details',
          style: fh20mediumBlue,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: fh16boldBlue,
            ),
            SizedBox(height: 8),
            Text(
              notification.body,
              style: fh14regularBlue,
            ),
            SizedBox(height: 16),
            if (notification.data.containsKey('meeting_time'))
              Text(
                'Time: ${notification.data['meeting_time']}',
                style: fh14regularBlue,
              ),
            if (notification.data.containsKey('meeting_date'))
              Text('Date: ${notification.data['meeting_date']}',
                  style: fh14regularBlue),
            if (notification.data.containsKey('meeting_type'))
              Text('Type: ${notification.data['meeting_type']}',
                  style: fh14regularBlue),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: fh14boldBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(
      BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: Text(
          notification.title,
          style: fh14mediumBlue,
        ),
        content: Text(
          notification.body,
          style: fh12mediumBlack,
        ),
        icon: Icon(
          Icons.check_circle,
          color: green,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

void _showClearAllDialog(
    BuildContext context, NotificationProvider provider, String cceId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: white,
      title: Text(
        AppLocalizations.of(context)!.clearallnoti,
        style: fh20mediumBlack,
      ),
      content: Text(
        AppLocalizations.of(context)!.questionforclearing,
        style: fh14mediumBlack,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: fh14SemiboldBlue,
          ),
        ),
        TextButton(
          onPressed: () {
            provider.clearAllNotifications(cceId);
            Navigator.pop(context);
          },
          child: Text(
            AppLocalizations.of(context)!.clearall,
            style: fh14SemiboldBlue,
          ),
        ),
      ],
    ),
  );
}
