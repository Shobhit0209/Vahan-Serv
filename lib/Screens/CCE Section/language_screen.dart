import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Providers/language_provider.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

enum Language { english, hindi }

class _LanguageScreenState extends State<LanguageScreen> {
  Language? selectedLanguage; // Track selected language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.chooselanguage,
        index: 0,
        isleadingNeeded: false,
        space: 14,
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: pad12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Language>(
                          dropdownColor: white,
                          borderRadius: br10,
                          alignment: AlignmentDirectional.topCenter,
                          value: selectedLanguage,
                          hint: Center(
                            child: Text(
                              'Select Language',
                              style: fh14regularGrey,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: blue,
                          ),
                          iconSize: 20,
                          items: <DropdownMenuItem<Language>>[
                            DropdownMenuItem(
                              value: Language.english,
                              child: Text('English', style: fh14mediumBlue),
                            ),
                            DropdownMenuItem(
                              value: Language.hindi,
                              child: Text('हिन्दी', style: fh14mediumBlue),
                            ),
                          ],
                          onChanged: (Language? item) async {
                            if (item != null) {
                              setState(() {
                                selectedLanguage = item;
                              });

                              if (item == Language.english) {
                                Future.delayed(Duration(milliseconds: 1000),
                                    () async {
                                  provider.changeLang(Locale('en'));
                                  await Fluttertoast.showToast(
                                      msg:
                                          'Language Changed To: ${selectedLanguage.toString().split('.').last.toUpperCase()}');
                                });
                              } else {
                                Future.delayed(Duration(milliseconds: 1000),
                                    () async {
                                  provider.changeLang(Locale('hi'));
                                  await Fluttertoast.showToast(
                                      msg:
                                          'Language Changed To: ${selectedLanguage.toString().split('.').last.toUpperCase()}');
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Spacer(), // Add some spacing
                selectedLanguage == null
                    ? const SizedBox.shrink()
                    : Button(
                        title: AppLocalizations.of(context)!.proceed,
                        onTapped: () => context.go('/role'))
              ],
            ),
          );
        },
      ),
    );
  }
}

class GridViewCards extends StatelessWidget {
  final Function(int, String) oncardTap;
  final int selectedIndex;
  const GridViewCards(
      {super.key, required this.selectedIndex, required this.oncardTap});

  @override
  Widget build(BuildContext context) {
    List<String> langs = [
      'English',
      'हिन्दी',
      'मराठी',
      'తెలుగు',
      'മലയാളം',
      'ಕನ್ನಡ',
      'தமிழ்',
      'বাংলা',
      'ગુજરાતી',
      'ਪੰਜਾਬੀ',
      'ଓଡିଆ'
    ];
    List<String> langEnTrans = [
      '',
      'Hindi',
      'Marathi',
      'Telugu',
      'Malayalam',
      'Kannada',
      'Tamil',
      'Bangla',
      'Gujrati',
      'Punjabi',
      'Odia'
    ];

    return GridView.builder(
      itemCount: langs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        childAspectRatio: 2,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        final lang = langs[index];
        final langEN = langEnTrans[index];
        final isSelected = selectedIndex == index;
        return InkWell(
          onTap: () {
            oncardTap(index, langEN);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: br10,
              boxShadow: boxShadow,
              color: isSelected ? blue : tColor,
            ),
            child: Center(
              child: Text(
                '$lang\n$langEN',
                style: isSelected ? fh16regularWhite : fh16regularBlack,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
