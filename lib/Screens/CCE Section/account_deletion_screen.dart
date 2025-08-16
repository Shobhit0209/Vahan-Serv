import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/role_screen.dart';

class AccountDeletionScreen extends StatelessWidget {
  const AccountDeletionScreen({super.key, required this.cceId});
  final String cceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        foregroundColor: blue,
        title: Text('Delete Account'),
        titleTextStyle: fh16mediumBlue,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
      ),
      body: Padding(
        padding: pad8,
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: [
              Text(
                'By proceeding, you understand that your VahanServ CCE account will be permanently deleted. This includes, your account profile and personal information, your complete service and other history, any saved car details or photos.',
                style: fh12mediumBlack,
                textAlign: TextAlign.justify,
              ),
              InkWell(
                borderRadius: br10,
                onTap: () async {
                  _deleteAccount();
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: RoleScreen(), withNavBar: false);
                },
                child: ClipRRect(
                  borderRadius: br10,
                  child: Card(
                    elevation: 0,
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Row(
                        spacing: 4,
                        children: [
                          Icon(Icons.delete_outline_outlined,
                              color: red, size: 20),
                          Text(
                            'Delete Account Permanently',
                            style: fh12mediumRed,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Get the currently logged in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        await deleteFirestoreData(cceId);
        if (kDebugMode) {
          print('User account deleted successfully.');
        }
      } else {
        if (kDebugMode) {
          print('No user is currently signed in.');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (kDebugMode) {
          print(
              'The user must re-authenticate before this operation can be executed.');
        }
        // You can prompt the user to re-authenticate here.
      } else {
        if (kDebugMode) {
          print('Failed to delete user account: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An unexpected error occurred: $e');
      }
    }
  }

  Future<void> deleteFirestoreData(String cceId) async {
    try {
      // Delete the user's main document
      await FirebaseFirestore.instance.collection('cce').doc(cceId).delete();

      if (kDebugMode) {
        print('Firestore data for user $cceId deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting Firestore data: $e');
      }
    }
  }
}
