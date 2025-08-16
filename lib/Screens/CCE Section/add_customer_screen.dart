import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/customer_model.dart';
// Update path as per your structure

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _assignedCCEController = TextEditingController();
  final TextEditingController _numberOfCarsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _subPlan;
  String? _subPlanFrequency;

  final List<String> _plans = ['Daily Wash', 'Alternate Day Wash'];
  final List<String> _frequencies = ['daily', 'alternate'];

  Future<void> _pickDate({required bool isStart}) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addCustomer() async {
    if (_formKey.currentState!.validate()) {
      String generateCustomerId(String name, String mobile) {
        String first4 =
            name.trim().split(" ").join().substring(0, 4).toUpperCase();
        String last4 = mobile.trim().substring(mobile.length - 4);
        return "$first4$last4";
      }

      final String custId = generateCustomerId(
        _nameController.text,
        _mobileController.text,
      );

      final customer = Customer(
          custId: custId,
          custName: _nameController.text.trim(),
          custAddress: _addressController.text.trim(),
          custMobile: _mobileController.text.trim(),
          custPhotoUrl: '',
          completionDate: '',
          flagged: 0,
          startDate: _startDate,
          endDate: _endDate,
          subPlan: _subPlan,
          subPlanFrequency: _subPlanFrequency,
          serviceNo: 0,
          cars: [],
          serviceImages: [],
          assignedCCE: _assignedCCEController.text
              .trim(), // Add default or current CCE logic if required
          numberOfCars: int.parse(_numberOfCarsController.text));

      await FirebaseFirestore.instance
          .collection('assignedCustomers')
          .doc(customer.custId)
          .set(customer.toFirestore());

      Fluttertoast.showToast(msg: 'Customer added successfully');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Customer"),
        titleTextStyle: fh16mediumWhite,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: pad8,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                    labelText: 'Mobile Number', counterText: ''),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) =>
                    value!.isEmpty ? 'Enter mobile number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numberOfCarsController,
                decoration: const InputDecoration(labelText: 'Number Of Cars'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter Number Of Cars'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _subPlan,
                hint: const Text('Select Plan'),
                items: _plans
                    .map((plan) => DropdownMenuItem(
                          value: plan,
                          child: Text(plan),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _subPlan = value;
                    // Automatically set frequency
                    if (value == 'Daily Wash') {
                      _subPlanFrequency = 'daily';
                    } else if (value == 'Alternate Day Wash') {
                      _subPlanFrequency = 'alternate';
                    } else {
                      _subPlanFrequency = null;
                    }
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _subPlanFrequency,
                hint: const Text('Frequency'),
                items: _frequencies
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        ))
                    .toList(),
                onChanged: null, // disables manual selection
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _assignedCCEController,
                decoration: const InputDecoration(labelText: 'Assigned CCE ID'),
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter CCE ID' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: Text(_startDate == null
                          ? 'Pick Start Date'
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: Text(_endDate == null
                          ? 'Pick End Date'
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCustomer,
                child: const Text('Add Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
