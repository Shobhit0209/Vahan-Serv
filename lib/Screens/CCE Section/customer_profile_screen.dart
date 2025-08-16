// ignore_for_file: public_member_api_docs, sort_constructors_first, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Models/customer_model.dart';
import 'package:vahanserv/Providers/cce_provider.dart';
import 'package:vahanserv/Screens/CCE%20Section/flag_screen.dart';
import 'package:vahanserv/l10n/app_localizations.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen(
      {super.key, required this.custId, required this.cceId});

  final String custId;
  final String cceId;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CCEProvider>(context, listen: false)
          .initCustomer(widget.custId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CCEProvider cceProvider =
        Provider.of<CCEProvider>(context, listen: false);

    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              PersistentNavBarNavigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.mngcustomerprofile,
            style: fh16regularBlue,
          ), // Use your text style
          titleSpacing: 0,
          backgroundColor: white,
          foregroundColor: blue,
          // Use your constant color
        ),
        floatingActionButton: _buildFab(cceProvider),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Consumer<CCEProvider>(
          builder: (BuildContext context, CCEProvider provider, Widget? child) {
            if (provider.customer == null) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/cce/second animation.json',
                    height: 60,
                    width: 60,
                  ),
                  Text(
                    'Loading Customer..',
                    style: fh14mediumBlue,
                  )
                ],
              ));
            }
            final customer = provider.customer!;
            final cars = customer.cars ?? [];

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(blue)),
                      onPressed: () {
                        provider.clearError();
                        provider.initCustomer(widget.custId);
                      },
                      child: Text(
                        'Retry',
                        style: fh14mediumWhite,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (provider.isLoading) {
              return Center(
                  child: Lottie.asset(
                'assets/cce/second animation.json',
                height: 60,
                width: 60,
              ));
            }

            return Padding(
              padding: pad8,
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: br10,
                    child: _buildProfileCard(customer, cars),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: br10,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: blue,
                      indicatorWeight: 3,
                      labelStyle: fh14mediumBlue,
                      unselectedLabelStyle: fh14regularGrey,
                      dividerColor: white,
                      tabs: [
                        Tab(text: 'Service Images'),
                        Tab(text: 'Flagged Days'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(controller: _tabController, children: [
                      SingleChildScrollView(
                          child: _buildImages(
                              context, provider.customer!.serviceImages)),
                      _buildFlaggedDays(context, provider),
                    ]),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildFab(CCEProvider provider) {
    return Container(
      height: 60,
      width: 150,
      decoration: BoxDecoration(
          borderRadius: br10,
          color: white,
          border: Border.all(color: blue, width: 2)),
      child: Padding(
        padding: pad8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.flag_rounded),
              iconSize: 24,
              color: blue,
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: FlagScreen(
                      customerId: widget.custId,
                      cceId: widget.cceId,
                    ),
                    withNavBar: false);
              },
              splashRadius: 20,
            ),
            VerticalDivider(
              thickness: 2,
              color: blue,
            ),
            IconButton(
              icon: Icon(Icons.call),
              iconSize: 24,
              color: blue,
              onPressed: () async {
                String cleanNumber = provider.customer!.custMobile
                    .toString()
                    .replaceAll(RegExp(r'[^0-9]'), '');
                if (cleanNumber.length >= 10) {
                  String last10Digits =
                      cleanNumber.substring(cleanNumber.length - 10);
                  await _makePhoneCall('+91$last10Digits');
                }
              },
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  Widget _buildProfileCard(Customer customer, List<Car> cars) {
    return Card(
      color: white,
      elevation: 4,
      shape: OutlineInputBorder(
          borderRadius: br10, borderSide: BorderSide(color: blue, width: 1)),
      child: Padding(
        padding: pad8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/customer/832.jpg',
              ),
            ),
            SizedBox(
              width: 40,
            ),
            Expanded(
              // ✅ Keep this Expanded since it's inside a Row
              child: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.custName!,
                    style: fh14boldBlue,
                  ),
                  Text(
                      '${AppLocalizations.of(context)!.address} - ${customer.custAddress!}',
                      style: fh12regularGrey,
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                      softWrap: true),
                  // Container(
                  //   height: 70,
                  //   padding: EdgeInsets.symmetric(vertical: 2),
                  //   child: Expanded(
                  //     child: ListView.builder(
                  //       scrollDirection: Axis.vertical,
                  //       itemCount: cars.length,
                  //       itemBuilder: (context, index) {
                  //         final car = cars[index];
                  //         return Text(
                  //           '${car.carName} ${car.carId}',
                  //           style: fh12regularGrey,
                  //           softWrap: true,
                  //           maxLines: 2,
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  Text(
                    'Flagged - ${customer.flagged.toString()}',
                    style: fh12regularGrey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImages(
      BuildContext context, List<Map<String, dynamic>>? serviceImages) {
    if (serviceImages == null || serviceImages.isEmpty) {
      if (kDebugMode) {
        print(
            'DEBUG: serviceImages is null or empty. Reason: ${serviceImages == null ? "null" : "empty list"}');
      }
      return Center(
        heightFactor: 25,
        child: Text(
          'No images found for this customer.',
          style: fh14boldBlue,
        ),
      );
    }

    if (kDebugMode) {
      print('DEBUG: serviceImages has ${serviceImages.length} items.');
    }

    // Group images by date
    final Map<String, List<Map<String, dynamic>>> groupedImages = {};
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');

    for (var imageData in serviceImages) {
      // Handle the uploadedDate from Firestore
      DateTime uploadDate;
      if (imageData['uploadedDate'] is Timestamp) {
        uploadDate = (imageData['uploadedDate'] as Timestamp).toDate();
      } else if (imageData['uploadedDate'] is DateTime) {
        uploadDate = imageData['uploadedDate'] as DateTime;
      } else {
        // Fallback to current date if no date is available
        uploadDate = DateTime.now();
      }

      final String dateKey = formatter.format(uploadDate);
      if (!groupedImages.containsKey(dateKey)) {
        groupedImages[dateKey] = [];
      }
      groupedImages[dateKey]!.add(imageData);
    }

    // Sort dates in descending order (most recent first)
    final List<String> sortedDates = groupedImages.keys.toList()
      ..sort((a, b) {
        final dateA = formatter.parse(a);
        final dateB = formatter.parse(b);
        return dateB.compareTo(dateA); // Descending order
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDates.expand((date) {
        final List<Map<String, dynamic>> imagesForDate = groupedImages[date]!;
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: fh14mediumBlack,
                ),
                Text(
                  '${imagesForDate.length} image${imagesForDate.length > 1 ? 's' : ''}',
                  style: fh12regularGrey,
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 15,
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemCount: imagesForDate.length,
            itemBuilder: (context, index) {
              final imageData = imagesForDate[index];
              final imageUrl = imageData['imageUrl'] as String? ?? '';
              final uploadedBy =
                  imageData['uploadedBy'] as String? ?? 'Unknown';

              return GestureDetector(
                onTap: () {
                  // Show full screen image with details
                  _showImageDialog(context, imageData);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: br10,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: br10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            enabled: true,
                            child: Container(
                              color: white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: br10,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    color: Colors.grey, size: 30),
                                Text('Error',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                        // Small overlay showing who uploaded
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              uploadedBy,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ];
      }).toList(),
    );
  }

  Widget _buildFlaggedDays(BuildContext context, CCEProvider provider) {
    // This is a placeholder implementation for the Flagged Days tab
    // You can replace this with your actual flagged days logic
    return provider.customerFlags.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LineIcons.flag,
                  size: 50,
                  color: blue,
                ),
                SizedBox(height: 16),
                Text('No Flagged Days Found', style: fh14regularGrey),
              ],
            ),
          )
        : Padding(
            padding: pad8,
            child: ListView.builder(
              itemCount: provider.customerFlags.length,
              itemBuilder: (context, index) {
                final flag = provider.customerFlags[index];
                return Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: pad8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'FlagId: ${flag.flagId}',
                          style: fh12SemiboldBlue,
                        ),
                        Text(
                          'Reason: ${flag.flagReason}',
                          style: fh12mediumBlack,
                        ),
                        Text(
                          flag.note,
                          style: fh12regularGrey,
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy hh:mm a')
                              .format(flag.flaggedAt),
                          style: fh10SemiboldGrey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _showImageDialog(BuildContext context, Map imageData) {
    final imageUrl = imageData['imageUrl'] as String? ?? '';
    final uploadedBy = imageData['uploadedBy'] as String? ?? 'Unknown';
    final uploadedDate = imageData['uploadedDate'];
    final latitude = imageData['latitude'];
    final longitude = imageData['longitude'];

    String formattedDate = 'Unknown Date';
    if (uploadedDate is Timestamp) {
      formattedDate =
          DateFormat('dd-MM-yyyy hh:mm a').format(uploadedDate.toDate());
    } else if (uploadedDate is DateTime) {
      formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(uploadedDate);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image details header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uploaded by: $uploadedBy',
                                style: fh16mediumBlue),
                            SizedBox(height: 4),
                            Text('Date: $formattedDate',
                                style: fh12regularGrey),
                            Text(
                              'Lat: $latitude\nLong: $longitude',
                              style: fh12regularGrey,
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close),
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                // Image container
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No image available',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
