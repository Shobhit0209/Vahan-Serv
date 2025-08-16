// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/cce_model.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class FindMeScreen extends StatefulWidget {
  const FindMeScreen({super.key});

  @override
  State<FindMeScreen> createState() => _FindMeScreenState();
}

class _FindMeScreenState extends State<FindMeScreen> {
  final TextEditingController _idController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _focusNode = FocusNode();

  bool _loading = false;
  CCE? _cce;

  Future<void> _searchCCE() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    setState(() => _loading = true);
    try {
      final doc = await _firestore.collection('cce').doc(id).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _cce = CCE.fromFirestore(doc);
        });
      } else {
        _resetForm();
        Fluttertoast.showToast(
          msg: 'CCE not found!',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _cce = null;
      _idController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/role');
        }
      },
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.findme,
          index: 0,
          onTapLeading: () => context.go('/role'),
        ),
        body: Padding(
          padding: pad8,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.cceid,
                          style: fh14mediumBlack),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _focusNode,
                              onTapOutside: (event) {
                                _focusNode.unfocus();
                              },
                              style: fh14SemiboldBlue,
                              controller: _idController,
                              cursorColor: blue,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintText: "Example: CCEABCD1234",
                                hintStyle: fh14mediumGrey,
                                border: OutlineInputBorder(
                                  borderRadius: br10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: br10,
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: br10,
                                    borderSide: BorderSide(
                                      color: blue,
                                      width: 2,
                                    )),
                                suffix: InkWell(
                                    onTap: _searchCCE,
                                    child: Text(
                                      AppLocalizations.of(context)!.search,
                                      style: fh14regularBlack,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_loading)
                        Center(
                            child: LottieBuilder.asset(
                          'assets/cce/second animation.json',
                          height: 60,
                          width: 60,
                        )),
                      if (_cce != null) ...[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            color: white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: br10,
                                side: BorderSide(color: blue, width: 2)),
                            child: Padding(
                              padding: pad12,
                              child: _buildCceInfoBox(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Button(
                  title: AppLocalizations.of(context)!.proceed,
                  onTapped: _cce != null
                      ? () {
                          context.go('/verifyPhone');
                        }
                      : () {})
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCceInfoBox(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/cce/Profile img.png')),
        const SizedBox(height: 10),
        Text(
          "${AppLocalizations.of(context)!.name}: ${_cce!.name}",
          style: fh14boldBlue,
        ),
        Text("${AppLocalizations.of(context)!.age}: ${_cce!.age} yrs",
            style: fh14mediumBlue),
        Text("${AppLocalizations.of(context)!.id}: ${_cce!.cceId}",
            style: fh14mediumBlue),
        Text("${AppLocalizations.of(context)!.doj}: ${_cce!.doj}",
            style: fh14mediumBlue),
        Text("${AppLocalizations.of(context)!.address}:\n${_cce!.address}",
            textAlign: TextAlign.center, style: fh14mediumBlue),
        const SizedBox(height: 10),
        TextButton(
            onPressed: _resetForm,
            child: Text(AppLocalizations.of(context)!.notyou,
                style: fh14SemiboldBlue)),
      ],
    );
  }

  String hindiname =
      TextTranslator().translateNameToHindi('english').toString();
}

class TextTranslator {
  Future<String> translateNameToHindi(String englishName) async {
    final translator = GoogleTranslator();

    try {
      var translation =
          await translator.translate(englishName, from: 'en', to: 'hi');
      return translation.text;
    } catch (e) {
      return englishName; // Return original if translation fails
    }
  }
}
