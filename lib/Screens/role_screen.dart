import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/Widgets/button.dart';
import 'package:vahanserv/Widgets/role_card.dart';
import 'package:vahanserv/l10n/app_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final List<String> imgPaths = [
    'assets/cce/CCE illustration Blue.png',
    'assets/cce/CCE illustration.png',
    'assets/cce/Customer blue.png',
    'assets/cce/Customer white.png'
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/lang');
        }
      },
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.role,
          isleadingNeeded: true,
          onTapLeading: () => context.go('/lang'),
          index: 0,
          space: 0,
        ),
        body: Padding(
          padding: pad12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //CCE Card
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex == 1
                                ? selectedIndex = 0
                                : selectedIndex = 1;
                          });
                        },
                        child: RoleCard(
                          selected: selectedIndex == 1,
                          imgPath:
                              selectedIndex == 1 ? imgPaths[1] : imgPaths[0],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.cce,
                        style: fh12SemiboldBlue,
                      )
                    ],
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  //Car owner Card
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex == 2
                                ? selectedIndex = 0
                                : selectedIndex = 2;
                          });
                        },
                        child: RoleCard(
                          selected: selectedIndex == 2,
                          imgPath:
                              selectedIndex == 2 ? imgPaths[3] : imgPaths[2],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.carOwner,
                          style: fh12SemiboldBlue)
                    ],
                  )
                ],
              ),
              Button(
                  title: AppLocalizations.of(context)!.proceed,
                  onTapped: selectedIndex == 0
                      ? () {
                          Fluttertoast.showToast(
                              msg: 'Please select your role!');
                          null;
                        }
                      : () => selectedIndex == 1
                          ? context.go('/cce')
                          : context.go('/customer'))
            ],
          ),
        ),
      ),
    );
  }
}
