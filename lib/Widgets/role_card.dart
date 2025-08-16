import 'package:flutter/material.dart';
import 'package:vahanserv/Constants/constants.dart';

class RoleCard extends StatelessWidget {
  final String imgPath;
  const RoleCard({
    super.key,
    required this.imgPath,
    required this.selected,
  });
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width / 2.25,
      decoration: BoxDecoration(
          color: selected ? blue : white,
          borderRadius: br10,
          boxShadow: boxShadow,
          border: Border.all(color: blue, width: 2)),
      child: Padding(
        padding: pad8,
        child: Image.asset(
          imgPath,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
