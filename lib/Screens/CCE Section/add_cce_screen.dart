import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:vahanserv/Models/cce_model.dart';

class AddCCEScreen extends StatefulWidget {
  const AddCCEScreen({super.key});

  @override
  State<AddCCEScreen> createState() => _AddCCEScreenState();
}

class _AddCCEScreenState extends State<AddCCEScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final dojController = TextEditingController();
  final photoUrlController = TextEditingController();

  bool isActive = true;

  // Dummy earnings and task counts (can be updated via admin)
  double monthlyEarning = 0;
  double todayEarning = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  int missedTasks = 0;
  int totalCustomers = 0;

  String generateCCEId(String name, String mobile) {
    String prefix = name.trim().split(" ").join().substring(0, 4).toUpperCase();
    String suffix = mobile.trim().substring(mobile.length - 4);
    return "CCE$prefix$suffix";
  }

  String generateRefrralCode(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void _submitCCE() async {
    if (_formKey.currentState!.validate()) {
      String cceId = generateCCEId(nameController.text, mobileController.text);
      String refCode = generateRefrralCode(8);

      final newCCE = CCE(
        cceId: cceId,
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 0,
        address: addressController.text.trim(),
        doj: dojController.text.trim(),
        photoUrl: '',
        referralCode: refCode,
        monthlyEarning: monthlyEarning,
        todayEarning: todayEarning,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        missedTasks: missedTasks,
        totalCustomers: totalCustomers,
        nextPayoutDate: 'Not Set',
        isActive: isActive,
      );

      // 🔥 Call your Firestore save function here using newCCE.toFirestore()
      await FirebaseFirestore.instance
          .collection('cce')
          .doc(newCCE.cceId)
          .set(newCCE.toFirestore());

      Fluttertoast.showToast(msg: 'CCE added successfully');
      if (mounted) {
        Navigator.pop(context);
      }

      // Reset form
      _formKey.currentState!.reset();
      nameController.clear();
      mobileController.clear();
      emailController.clear();
      ageController.clear();
      addressController.clear();
      dojController.clear();
      photoUrlController.clear();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    ageController.dispose();
    addressController.dispose();
    dojController.dispose();
    photoUrlController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New CCE")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, 'Name', TextCapitalization.words),
              _buildTextField(mobileController, 'Mobile',
                  TextCapitalization.none, TextInputType.phone),
              // _buildTextField(emailController, 'Email'),
              _buildTextField(ageController, 'Age', TextCapitalization.none,
                  TextInputType.number),
              _buildTextField(
                  addressController, 'Address', TextCapitalization.words),
              _buildDatePickerField(dojController, 'Date of Joining'),
              // _buildTextField(referralCodeController, 'Referral Code'),
              SwitchListTile(
                title: const Text("Is Active?"),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCCE,
                child: const Text("Add CCE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextCapitalization cap = TextCapitalization.none,
      TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        textCapitalization: cap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => label == 'Referral Code'
            ? (value == null || value.trim().isEmpty)
                ? null
                : null
            : (value == null || value.trim().isEmpty)
                ? 'Enter $label'
                : null,
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2032),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(controller, label),
      ),
    );
  }
}
