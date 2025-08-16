import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/customer_home_screen.dart';

class CreateCustomerProfileScreen extends StatefulWidget {
  const CreateCustomerProfileScreen({super.key});

  @override
  State<CreateCustomerProfileScreen> createState() =>
      _CreateCustomerProfileScreenState();
}

class _CreateCustomerProfileScreenState
    extends State<CreateCustomerProfileScreen> {
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: pad12,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text("Let's get started", style: fh24SemiboldBlue),
              Text("Tell us about yourself", style: fh16regularGrey),
              const SizedBox(height: 30),

              /// Profile Section
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.person, color: Colors.grey, size: 80),
                    ),
                    const SizedBox(height: 10),
                    Text('Add a profile picture', style: fh12regularGrey),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              /// First Name
              TextField(
                focusNode: _firstNameFocusNode,
                controller: firstNameController,
                style: fh14mediumBlack,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  hintStyle: fh14mediumGrey,
                  border: OutlineInputBorder(borderRadius: br10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                      borderRadius: br10),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade500, width: 2),
                      borderRadius: br10),
                ),
              ),
              const SizedBox(height: 10),

              /// Last Name
              TextField(
                focusNode: _lastNameFocusNode,
                controller: lastNameController,
                style: fh14mediumBlack,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  hintStyle: fh14mediumGrey,
                  border: OutlineInputBorder(borderRadius: br10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade500),
                      borderRadius: br10),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade500, width: 2),
                      borderRadius: br10),
                ),
              ),
              const SizedBox(height: 20),

              /// Proceed Button
              InkWell(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: CustomerHomeScreen());
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 15,
                  width: double.infinity,
                  decoration: BoxDecoration(color: blue, borderRadius: br10),
                  child: Center(
                      child: Text(
                    'Proceed',
                    style: fh16SemiboldWhite,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
