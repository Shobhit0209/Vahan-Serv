import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';
import 'package:vahanserv/Screens/CUSTOMER%20Section/subscription_detail_screen.dart';
import 'package:vahanserv/Widgets/services_available.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

final List<Widget> cars = [];
bool isFrequencyDaily = false;
TextEditingController searchController = TextEditingController();
final FocusNode _focusNode = FocusNode();
void addCar() {
  // cars.add(
  //   Column(
  //     children: [
  //       Container(
  //         width: 60,
  //         decoration: BoxDecoration(
  //             color: white, boxShadow: boxShadow, borderRadius: br10),
  //         child: Image.asset(
  //           'assets/customer/car.png',
  //           scale: 10,
  //         ),
  //       ),
  //       Text('Kia Sonet', style: fh14mediumBlue)
  //     ],
  //   ),
  // );
  // cars.removeAt(0);
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> microServices = [
      ServicesAvailable(
        imgPath: 'assets/customer/jump starter.png',
        servicename: 'Battery Jump Start',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/puncture repair.png',
        servicename: 'Puncture Repair',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/wiper.png',
        servicename: 'Wiper\nReplace',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/coolant top up.png',
        servicename: 'Coolant/Oil Top Up',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/battery health.png',
        servicename: 'Battery Checkup',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/car accessories.png',
        servicename: 'Car Accessories',
      ),
    ];

    final List<Widget> subscriptionPlans = [
      ServicesAvailable(
        imgPath: 'assets/customer/calendar daily.png',
        servicename: 'Daily\nWash',
      ),
      ServicesAvailable(
        imgPath: 'assets/customer/calendar alternate.png',
        servicename: 'Alternate Wash',
      ),
    ];
    return Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              _buildAppBar(),
              _buildSearchField(),
              _buildBanner(),
              _buildMyCars(),
              _buildMicroServices(microServices),
              _buildSubscriptionPlans(subscriptionPlans),
            ],
          ),
        ));
  }

  Widget _buildSubscriptionPlans(List<Widget> subscriptionPlans) {
    return Padding(
      padding: pad12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscription Plans', style: fh14SemiboldBlack),
          SizedBox(
            height: 195,
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              itemCount: subscriptionPlans.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100, // Width
                mainAxisExtent: 100, // Height
                crossAxisSpacing: 10,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final subscriptionPlan = subscriptionPlans[index];
                return InkWell(
                    onTap: () {
                      final selectedPlan = index == 0
                          ? "Daily"
                          : "Alternate"; // or use any string key
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen:
                            SubscriptionDetailScreen(planType: selectedPlan),
                        withNavBar: false,
                      );
                    },
                    child: subscriptionPlan);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroServices(List<Widget> microServices) {
    return Padding(
      padding: pad12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Micro Services', style: fh14SemiboldBlack),
          SizedBox(
            height: 195,
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              itemCount: microServices.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100, // Width
                mainAxisExtent: 100, // Height
                crossAxisSpacing: 10,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final microservice = microServices[index];
                return microservice;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCars() {
    return Padding(
      padding: pad12,
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Cars',
            style: fh14SemiboldBlack,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    addCar();
                  });
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: white, boxShadow: boxShadow, borderRadius: br10),
                  child: Image.asset(
                    'assets/customer/Add Car.png',
                    scale: 12,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    itemCount: cars.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: cars[index],
                      );
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              offset: Offset(0, 3),
              color: Colors.grey.shade400,
              blurRadius: 3,
              spreadRadius: 0)
        ], borderRadius: BorderRadius.circular(25)),
        child: TextField(
          controller: searchController,
          cursorColor: blue,
          focusNode: _focusNode,
          onTapOutside: (event) {
            _focusNode.unfocus();
          },
          style: fh14mediumBlack,
          decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: fh14mediumGrey,
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              fillColor: white,
              prefixIcon: Icon(
                Icons.search,
                color: blue,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: grey)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: grey)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: grey, width: 2))),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),
        shrinkWrap: true,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: MediaQuery.of(context).size.width / 1.04,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: blue),
            child: Center(
              child: Text(
                'Banner $index',
                style: fh12mediumWhite,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      child: Padding(
        padding: pad12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              Icons.menu_rounded,
              color: white,
              size: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Row(
                  spacing: 2,
                  children: [
                    Icon(
                      Icons.location_on_sharp,
                      color: white,
                      size: 20,
                    ),
                    Text(
                      'Avas Vikas, Kichha',
                      style: fh12mediumWhite,
                    )
                  ],
                ),
                Text(
                  'Hello, Shobhit',
                  style: fh20SemiboldWhite,
                )
              ],
            ),
            Icon(
              Icons.logout,
              color: white,
              size: 30,
            )
          ],
        ),
      ),
    );
  }
}
