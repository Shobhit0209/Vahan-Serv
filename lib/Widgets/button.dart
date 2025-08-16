import 'package:flutter/material.dart';
import 'package:vahanserv/Constants/constants.dart';

class Button extends StatelessWidget {
  final String title;
  final VoidCallback onTapped;
  const Button({super.key, required this.title, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapped,
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: blue, borderRadius: br10, boxShadow: boxShadow),
        child: Center(
            child: Text(
          title,
          style: fh14SemiboldWhite,
        )),
      ),
    );
  }
}
