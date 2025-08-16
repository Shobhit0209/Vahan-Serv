import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vahanserv/Constants/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen(
      {super.key, required this.planType, required this.numberOfMonths});
  final String planType;
  final String numberOfMonths;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final List<ListTile> upiOptions = [
      /*GooglePay*/ ListTile(
        //GOOGLE PAY
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          height: 40,
          child: Image.asset(
            'assets/customer/googlePay.png',
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          'Google Pay',
          style: fh12mediumBlack,
        ),
        trailing: CircleAvatar(
          radius: 5,
          backgroundColor: blue,
        ),
      ),
      /*Paytm*/ ListTile(
        //PAYTM
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          height: 40,
          child: Image.asset(
            'assets/customer/paytm.png',
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          'Paytm',
          style: fh12mediumBlack,
        ),
        trailing: CircleAvatar(
          radius: 5,
          backgroundColor: blue,
        ),
      ),
      /*PhonePe*/ ListTile(
        //PHONEPE
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          height: 40,
          child: Image.asset(
            'assets/customer/phonePe.png',
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          'PhonePe',
          style: fh12mediumBlack,
        ),
        trailing: CircleAvatar(
          radius: 5,
          backgroundColor: blue,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: PageScrollPhysics(),
            child: Padding(
              padding: pad8,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  _buildOrderDetails(),
                  Text('Price Details', style: fh14SemiboldBlack),
                  _buildPriceDetails(),
                  Text(
                    'Pay Using UPI',
                    style: fh14SemiboldBlack,
                  ),
                  _buildUpiOptions(upiOptions),
                  Text(
                    'Credit/Debit/ATM Card',
                    style: fh14SemiboldBlack,
                  ),
                  _buildCardOptions(),
                ],
              ),
            ),
          )),
          _payNowButton(context)
        ],
      )),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: pad8,
      width: double.infinity,
      decoration:
          BoxDecoration(borderRadius: br10, border: Border.all(color: grey)),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PriceDetail(
              detail1: 'Price(X${widget.numberOfMonths})', detail2: '₹1398'),
          PriceDetail(detail1: 'Discount', detail2: '₹0'),
          PriceDetail(
            detail1: 'Total Amount',
            detail2: '₹1398',
            boldRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCardOptions() {
    return InkWell(
      borderRadius: br10,
      onTap: () {},
      child: Container(
        padding: pad8,
        decoration:
            BoxDecoration(color: cardColorLightBlue, borderRadius: br10),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset(
                'assets/customer/dotted add.png',
                height: 30,
                width: 30,
              ),
              Text(
                'Add Credit/Debit/ATM Card',
                style: fh12mediumBlue,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiOptions(List<ListTile> upiOptions) {
    return Container(
      height: 180,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: grey),
        borderRadius: br10,
      ),
      child: ListView.builder(
        itemCount: upiOptions.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final upiOption = upiOptions[index];
          return upiOption;
        },
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: pad8,
      width: double.infinity,
      decoration:
          BoxDecoration(borderRadius: br10, border: Border.all(color: grey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Text('#Order_Id - 12345', style: fh14regularGrey),
          OrderDetail(
              detail1: '${widget.planType} Car Wash Plan',
              detail2: 'X ${widget.numberOfMonths} months'),
          OrderDetail(detail1: 'Car Name', detail2: 'Kia Seltos'),
          OrderDetail(detail1: 'Registration Number', detail2: 'UK 06 AB 1125'),
          OrderDetail(
              detail1:
                  'A-101, Avas Vikas,\nKichha, Udham Singh Nagar,\nPincode-263148,\nUttarakhand.',
              detail2: ''),
        ],
      ),
    );
  }

  Widget _payNowButton(BuildContext context) {
    return Padding(
      padding: pad8,
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: blue,
            borderRadius: br10,
          ),
          child: Center(
              child: Text(
            'Pay Now ₹1398',
            style: fh16SemiboldWhite,
          )),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            PersistentNavBarNavigator.pop(context);
          },
          child: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.black,
            size: 30,
          ),
        ),
        Text(
          'Payment',
          style: fh16SemiboldBlue,
        ),
        Container(
          decoration: BoxDecoration(
              color: blue, borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.all(4),
          child: Row(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 12,
                color: green,
              ),
              Text(
                '100% Secure',
                style: fh10SemiboldGreen,
              )
            ],
          ),
        )
      ],
    );
  }
}

class OrderDetail extends StatelessWidget {
  const OrderDetail({super.key, required this.detail1, required this.detail2});
  final String detail1;
  final String detail2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail1,
          style: fh12regularBlack,
        ),
        Text(
          detail2,
          style: fh12regularBlack,
        )
      ],
    );
  }
}

class PriceDetail extends StatelessWidget {
  const PriceDetail(
      {super.key,
      required this.detail1,
      required this.detail2,
      this.boldRequired = false});
  final String detail1;
  final String detail2;
  final bool boldRequired;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail1,
          style: boldRequired ? fh12boldBlack : fh12regularBlack,
        ),
        Text(
          detail2,
          style: boldRequired ? fh12boldBlack : fh12regularBlack,
        )
      ],
    );
  }
}
