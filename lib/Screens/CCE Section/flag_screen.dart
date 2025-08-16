// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Models/flag_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Providers/language_provider.dart';
import 'package:vahanserv/Services/firestore_services.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class FlagScreen extends StatefulWidget {
  const FlagScreen({
    super.key,
    required this.customerId,
    required this.cceId,
  });
  final String customerId;
  final String cceId;

  @override
  State<FlagScreen> createState() => _FlagScreenState();
}

class _FlagScreenState extends State<FlagScreen> {
  FlagReasonType? selectedReason;
  HindiFlagReasonType? hindiselectedReason;
  final TextEditingController noteController = TextEditingController();
  bool isSubmitting = false;
  late LanguageProvider langprov = LanguageProvider();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<CCEProvider>(context, listen: false).initCCE(widget.cceId);
    });
    langprov = Provider.of<LanguageProvider>(context, listen: false);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.flagcust,
          style: fh16mediumBlue,
        ),
        backgroundColor: white,
        leading: InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        foregroundColor: blue,
        titleSpacing: 0,
        actionsPadding: pad8,
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: pad12,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: PageScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...langprov.appLocale == Locale('hi')
                        ? HindiFlagReasonType.values
                            .map((reason) => _buildHindiRadioOption(reason))
                        : FlagReasonType.values
                            .map((reason) => _buildRadioOption(reason)),
                    if (selectedReason != null || hindiselectedReason != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (langprov.appLocale == Locale('hi')) {
                              hindiselectedReason = null;
                              if (kDebugMode) {
                                print(
                                    'Cleared hindi ${hindiselectedReason?.title}');
                              }
                            } else {
                              selectedReason = null;
                              if (kDebugMode) {
                                print(
                                    'Cleared english ${selectedReason?.title}');
                              }
                            }
                          });
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            child: Text(
                              'Clear Selection',
                              style: fh12mediumBlue,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: br10,
                      ),
                      child: TextField(
                        controller: noteController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        style: fh12regularBlack,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.shortnote,
                          hintStyle: fh12regularGrey,
                          border: InputBorder.none,
                          contentPadding: pad8,
                        ),
                      ),
                    ),
                    SizedBox(height: 10)
                  ],
                ),
              ),
            ),
            isSubmitting
                ? Center(
                    child: Lottie.asset('assets/cce/second animation.json',
                        height: 60, width: 60),
                  )
                : Button(
                    title: AppLocalizations.of(context)!.submitforreview,
                    onTapped: _submitFlag)
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(FlagReasonType reason) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Radio<FlagReasonType>(
              value: reason,
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
              activeColor: blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Text(reason.title, style: fh14regularBlack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHindiRadioOption(HindiFlagReasonType reason) {
    return InkWell(
      onTap: () {
        setState(() {
          hindiselectedReason = reason;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Radio<HindiFlagReasonType>(
              value: reason,
              groupValue: hindiselectedReason,
              onChanged: (value) {
                setState(() {
                  hindiselectedReason = value;
                });
              },
              activeColor: blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Text(reason.title, style: fh14regularBlack),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFlag() async {
    final ccepProvider = Provider.of<CCEProvider>(listen: false, context);
    int serviceNo = ccepProvider.getCustomerServiceNumber(widget.customerId);
    if (langprov.appLocale == Locale('hi')) {
      if (hindiselectedReason == null) {
        _showErrorDialog('Please select a reason for flagging.');
        return;
      }

      if (noteController.text.trim().isEmpty) {
        //_showErrorDialog('Please write a note about your reason.');
        noteController.text = '';
      }

      setState(() {
        isSubmitting = true;
      });

      try {
        // Create flag document
        final flagId = const Uuid().v4();
        final flag = {
          'flagId': flagId,
          'flagReason': hindiselectedReason!.code,
          'note': noteController.text.trim(),
          'flaggedBy': widget.cceId,
          'customerId': widget.customerId,
          'flaggedAt': Timestamp.fromDate(DateTime.now()),
          'resolvedAt': null,
        };

        // Submit to Firestore
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(flagId)
            .set(flag);

        final customer = await FirebaseFirestore.instance
            .collection('assignedCustomers')
            .doc(widget.customerId)
            .get();
        if (customer.exists) {
          if (hindiselectedReason!.code == 'CUSTOMER_REFUSED_SERVICE' ||
              hindiselectedReason!.code == 'CAR_LOCKED_UNAVAILABLE') {
            await FirestoreService()
                .updateTaskStatus(widget.customerId, serviceNo);
          }
          final flaggedtemp = Customer.fromFirestore(customer);
          int flagged = flaggedtemp.flagged!;
          await FirebaseFirestore.instance
              .collection('assignedCustomers')
              .doc(widget.customerId)
              .update({'flagged': flagged + 1});
        }

        // Show success and navigate back
        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error submitting flag: $e');
        }
        if (mounted) {
          _showErrorDialog('Failed to submit flag. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
    // Validation
    else {
      if (selectedReason == null) {
        _showErrorDialog('Please select a reason for flagging.');
        return;
      }

      if (noteController.text.trim().isEmpty) {
        // _showErrorDialog('Please write a note about your reason.');
        noteController.text = '';
      }

      setState(() {
        isSubmitting = true;
      });

      try {
        // Create flag document
        final flagId = const Uuid().v4();
        final flag = {
          'flagId': flagId,
          'flagReason': selectedReason!.code,
          'note': noteController.text.trim(),
          'flaggedBy': widget.cceId,
          'customerId': widget.customerId,
          'flaggedAt': Timestamp.fromDate(DateTime.now()),
          'resolvedAt': null,
        };

        // Submit to Firestore
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(flagId)
            .set(flag);

        final customer = await FirebaseFirestore.instance
            .collection('assignedCustomers')
            .doc(widget.customerId)
            .get();
        if (customer.exists) {
          if (selectedReason!.code == 'CUSTOMER_REFUSED_SERVICE' ||
              selectedReason!.code == 'CAR_LOCKED_UNAVAILABLE') {
            await FirestoreService()
                .updateTaskStatus(widget.customerId, serviceNo);
          }
          final flaggedtemp = Customer.fromFirestore(customer);
          int flagged = flaggedtemp.flagged!;
          await FirebaseFirestore.instance
              .collection('assignedCustomers')
              .doc(widget.customerId)
              .update({'flagged': flagged + 1});
        }

        // Show success and navigate back
        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error submitting flag: $e');
        }
        if (mounted) {
          _showErrorDialog('Failed to submit flag. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Flag has been submitted for review successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<CCEProvider>(context, listen: false)
                  .initCustomer(widget.customerId); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
