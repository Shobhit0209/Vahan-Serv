// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/customer_profile_screen.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class ManageCustomerScreen extends StatefulWidget {
  const ManageCustomerScreen({
    super.key,
    required this.cceId,
  });
  final String cceId;

  @override
  State<ManageCustomerScreen> createState() => _ManageCustomerScreenState();
}

class _ManageCustomerScreenState extends State<ManageCustomerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false)
          .getAllCustomersUnderCCE(widget.cceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.mngcust,
        index: 0,
        isleadingNeeded: true,
        onTapLeading: () {
          PersistentNavBarNavigator.pop(context);
        },
        space: 0,
      ),
      body: Consumer<CCEProvider>(
        builder: (context, provider, child) {
          final customerRef = provider.allCustomers;
          if (kDebugMode) {
            print('currentCCE: ${provider.currentCCE?.name}');
          }
          if (provider.isLoading) {
            return Center(
                child: Lottie.asset(
              'assets/cce/second animation.json',
              height: 60,
              width: 60,
            ));
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.initCCE(widget.cceId);
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (kDebugMode) {
            print(customerRef.length.toString());
          }
          return customerRef.isNotEmpty
              ? Padding(
                  padding: pad8,
                  child: RefreshIndicator(
                    displacement: 10,
                    color: blue,
                    backgroundColor: cardColorLightBlue,
                    onRefresh: () async {
                      await Provider.of<CCEProvider>(context, listen: false)
                          .refreshData();
                    },
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: customerRef.length,
                      itemBuilder: (context, index) {
                        final customer = customerRef[index];

                        return InkWell(
                          borderRadius: br10,
                          onTap: () async {
                            PersistentNavBarNavigator.pushNewScreen(context,
                                screen: CustomerProfileScreen(
                                  cceId: widget.cceId,
                                  custId: customer.custId,
                                ),
                                withNavBar: false);
                          },
                          child: Card(
                            color: white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    customer.custName!,
                                    style: fh12mediumBlack,
                                  ),
                                  Row(
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: blue,
                                        size: 20,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ))
              : Center(
                  heightFactor: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_sharp,
                        size: 40,
                        color: blue,
                      ),
                      SizedBox(height: 10),
                      Text('No Customers Assigned', style: fh14regularGrey),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
