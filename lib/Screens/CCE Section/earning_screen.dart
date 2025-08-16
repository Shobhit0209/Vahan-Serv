// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/cce_earnings_model.dart';
import 'package:vahanserv/Models/cce_model.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/earning_history_detailed_screen.dart';
import 'package:vahanserv/Screens/nav_bar.dart';
import 'package:vahanserv/Widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({
    super.key,
    required this.cceId,
  });
  final String cceId;

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final _searchcontroller = TextEditingController();
  final _focusNode = FocusNode();
  Map<String, List<CCEEarnings>> groupEarningsByMonth(
      List<CCEEarnings> earnings) {
    final Map<String, List<CCEEarnings>> grouped = {};
    for (var earning in earnings) {
      final monthYear = DateFormat('MMMM yyyy').format(earning.time!.toDate());
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(earning);
    }
    return grouped;
  }

  String getInitials(String name) {
    if (name.isEmpty) {
      return '';
    }

    List<String> words = name.split(' ');
    String initials = '';

    for (String word in words) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
      }
    }

    return initials;
  }

  List<CCEEarnings> _allEarnings = []; // Store all fetched earnings
  String _searchText = '';

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchcontroller.text.trim().toLowerCase();
    });
  }

  // Function to filter earnings based on the search text
  List<CCEEarnings> _filterEarnings(List<CCEEarnings> earnings) {
    if (_searchText.isEmpty) {
      return earnings;
    }
    return earnings.where((earning) {
      final customerNameLower = earning.customerName?.toLowerCase() ?? '';
      final taskNameLower = earning.taskName?.toLowerCase() ?? '';
      final amountStr = earning.amount?.toString().toLowerCase() ?? '';
      final dateFormatted = DateFormat('dd MMM yyyy')
          .format(earning.time!.toDate())
          .toLowerCase();
      final monthFormatted =
          DateFormat('MMMM').format(earning.time!.toDate()).toLowerCase();
      final yearFormatted =
          DateFormat('yyyy').format(earning.time!.toDate()).toLowerCase();

      return customerNameLower.contains(_searchText) ||
          taskNameLower.contains(_searchText) ||
          amountStr.contains(_searchText) ||
          dateFormatted.contains(_searchText) ||
          monthFormatted.contains(_searchText) ||
          yearFormatted.contains(_searchText);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false).initCCE(widget.cceId);
    });
    Provider.of<CCEProvider>(context, listen: false)
        .getAllCustomersUnderCCE(widget.cceId);
    _searchcontroller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchcontroller.removeListener(_onSearchChanged);
    _searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) return;
          if (navBarKey.currentState != null) {
            navBarKey.currentState!.pageController.jumpToTab(0);
          }
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: AppBarWidget(
            title: AppLocalizations.of(context)!.earninghistory,
            index: 0,
            isleadingNeeded: false,
            space: 12,
          ),
          body: RefreshIndicator(
            backgroundColor: white,
            onRefresh: () async {
              await Provider.of<CCEProvider>(listen: false, context)
                  .initCCE(widget.cceId);
            },
            child: Consumer<CCEProvider>(
              builder: (context, provider, child) {
                if (kDebugMode) {
                  print('currentCCE: ${provider.currentCCE?.name}');
                }
                final cce = provider.currentCCE!;
                final customer = provider.assignedCustomers;
                final earning = provider.earnings;
                _allEarnings = earning; // Store all fetched earnings
                final filteredEarnings = _filterEarnings(_allEarnings);
                final groupedEarnings = groupEarningsByMonth(filteredEarnings);
                final sortedMonths = groupedEarnings.keys.toList()
                  ..sort((a, b) {
                    final dateA = DateFormat('MMMM yyyy').parse(a);
                    final dateB = DateFormat('MMMM yyyy').parse(b);
                    return dateB.compareTo(
                        dateA); // Sort in descending order (latest first)
                  });
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
                            provider.initCCE(cce.cceId);
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: pad12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.earningsum,
                          style: fh14boldBlack,
                        ),
                        SizedBox(height: 10),
                        _buildEarningSummaryCard(cce, customer, provider),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.payouthistory,
                          style: fh14boldBlack,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                child: _searchField(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (filteredEarnings.isEmpty && _searchText.isNotEmpty)
                          Center(
                            heightFactor: 20,
                            child: Text(
                                'No earnings found matching "$_searchText"',
                                style: fh14boldGrey),
                          )
                        else
                          _buildDailyEarningList(
                              sortedMonths, groupedEarnings, customer)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  TextField _searchField() {
    return TextField(
      focusNode: _focusNode,
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
      style: fh14mediumBlack,
      controller: _searchcontroller,
      decoration: InputDecoration(
          contentPadding: pad8,
          enabledBorder: OutlineInputBorder(
              borderRadius: br10,
              borderSide: BorderSide(
                width: 1,
                color: Colors.black,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: br10,
              borderSide: BorderSide(color: blue, width: 2)),
          hintText: 'Search by name, amount, date, year',
          hintStyle: GoogleFonts.montserrat(
              color: shadow, fontWeight: FontWeight.w500, fontSize: 14),
          suffixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: blue,
          )),
    );
  }

  Widget _buildDailyEarningList(List<String> sortedMonths,
      Map<String, List<CCEEarnings>> groupedEarnings, List<Customer> customer) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final monthlyEarnings = groupedEarnings[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              month,
              style: fh14SemiboldBlue,
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthlyEarnings.length,
              itemBuilder: (context, earningIndex) {
                final earningdata = monthlyEarnings[earningIndex];
                return ListTile(
                  onTap: () => PersistentNavBarNavigator.pushNewScreen(context,
                      screen: EarningHistoryDetailedScreen(
                          custname: earningdata.customerName!,
                          numberplate: earningdata.numberPlate!,
                          subplan: earningdata.taskName!,
                          servicenumber: earningdata.serviceNo!,
                          address: earningdata.address!,
                          amount: earningdata.amount!,
                          time: timeConversion(earningdata.time!)),
                      withNavBar: true),
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      backgroundColor: blue,
                      radius: 24,
                      child: Text(
                        getInitials(earningdata.customerName.toString()),
                        style: fh16mediumWhite,
                      )),
                  title: Text(earningdata.customerName!),
                  titleTextStyle: fh14mediumBlack,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Received on',
                          ),
                          MyTimeWidget(
                            timestamp: earningdata.time,
                          )
                        ],
                      ),
                      Text(
                        earningdata.taskName!,
                      )
                    ],
                  ),
                  subtitleTextStyle: fh12regularBlue,
                  trailing: Text(
                    '+₹${earningdata.amount!.toStringAsFixed(0)}',
                    style: fh12SemiboldBlue,
                  ),
                );
              },
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildEarningSummaryCard(
      CCE cce, List<Customer> customer, CCEProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: blue, borderRadius: br10),
      child: Padding(
        padding: pad8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.tetm,
                    style: fh12SemiboldWhite,
                  ),
                  Text(
                    '₹ ${provider.monthlyEarnings.toStringAsFixed(0)}',
                    style: fh12mediumWhite,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.tetd,
                    style: fh12SemiboldWhite,
                  ),
                  Text(
                    '₹ ${provider.todayEarnings.toStringAsFixed(0)}',
                    style: fh12mediumWhite,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.totalcust,
                    style: fh12SemiboldWhite,
                  ),
                  Text(
                    '${provider.totalCustomers}', //correction needed.
                    style: fh12mediumWhite,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String timeConversion(Timestamp time) {
    DateTime dateTime = time.toDate();

    // Format DateTime to show only the time (HH:mm:ss)
    String formattedTime = DateFormat('dd MMM, H:mm a').format(dateTime);
    return formattedTime;
  }
}

class MyTimeWidget extends StatelessWidget {
  final Timestamp? timestamp;

  const MyTimeWidget({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    if (timestamp == null) {
      return Text('No time available');
    }

    // Convert Firebase Timestamp to DateTime
    DateTime dateTime = timestamp!.toDate();

    // Format DateTime to show only the time (HH:mm:ss)
    final String formattedTime = DateFormat('dd MMM, H:mm a').format(dateTime);

    return Text(
      ' $formattedTime',
    );
  }
}
