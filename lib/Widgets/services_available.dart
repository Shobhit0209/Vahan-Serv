import 'package:flutter/material.dart';
import 'package:vahanserv/Constants/constants.dart';

class ServicesAvailable extends StatefulWidget {
  const ServicesAvailable(
      {super.key, required this.imgPath, required this.servicename});
  final String imgPath;
  final String servicename;

  @override
  State<ServicesAvailable> createState() => _ServicesAvailableState();
}

class _ServicesAvailableState extends State<ServicesAvailable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          widget.imgPath,
          height: 40,
          width: 40,
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 100,
          child: Text(
            widget.servicename,
            style: fh12mediumBlack,
            textAlign: TextAlign.justify,
          ),
        )
      ],
    );
  }
}
