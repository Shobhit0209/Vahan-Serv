import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Firestore collection and document name
const String uploadedImagesCollection = 'UploadedImages';
const String uploadedImagesDocument = 'imageURLs';
const String collectionName = 'flags';

//COLORS
const Color blue = Color(0xff09288A);
const Color white = Color(0xffffffff);
const Color tColor = Color(0xffF1EDED);
Color shadow = Colors.black45;
Color grey = Colors.black45;
Color bordercolor = Colors.black26;
Color green = Color(0xff4DFF00);
Color red = Color(0xffFF0909);
Color cardColorLightBlue = Color(0xFFE2E9FF);

//BOXSHADOW
List<BoxShadow> boxShadow = [
  const BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0,
      color: Colors.black45)
];

//PADDING
const EdgeInsets pad12 = EdgeInsets.all(12);
const EdgeInsets pad8 = EdgeInsets.all(8);

//BORDERRADIUS
BorderRadius br10 = BorderRadius.circular(10);

//HEIGHTS

//FONT SIZES
const double h24 = 24;
const double h20 = 20;
const double h16 = 16;
const double h14 = 14;
const double h12 = 12;
const double h10 = 10;
const double h8 = 8;

//textstyle for height 24
TextStyle fh24boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h24, fontWeight: FontWeight.w700);
TextStyle fh24boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h24, fontWeight: FontWeight.w700);
TextStyle fh24SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h24, fontWeight: FontWeight.w600);
TextStyle fh24SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h24, fontWeight: FontWeight.w600);
TextStyle fh24mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h24, fontWeight: FontWeight.w500);
TextStyle fh24mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h24, fontWeight: FontWeight.w500);
TextStyle fh24regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h24, fontWeight: FontWeight.w400);
TextStyle fh24regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h24, fontWeight: FontWeight.w400);

//textstyle for height 20
TextStyle fh20boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h20, fontWeight: FontWeight.w700);
TextStyle fh20boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h20, fontWeight: FontWeight.w700);
TextStyle fh20boldGreen = GoogleFonts.montserrat(
    color: green, fontSize: h20, fontWeight: FontWeight.w700);
TextStyle fh20SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h20, fontWeight: FontWeight.w600);
TextStyle fh20SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h20, fontWeight: FontWeight.w600);
TextStyle fh20mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h20, fontWeight: FontWeight.w500);
TextStyle fh20mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h20, fontWeight: FontWeight.w500);
TextStyle fh20mediumBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h20, fontWeight: FontWeight.w500);
TextStyle fh20regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h20, fontWeight: FontWeight.w400);
TextStyle fh20regularBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h20, fontWeight: FontWeight.w400);
TextStyle fh20regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h20, fontWeight: FontWeight.w400);

//textstyle for height 16
TextStyle fh16boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h16, fontWeight: FontWeight.w700);
TextStyle fh16boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h16, fontWeight: FontWeight.w700);
TextStyle fh16boldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h16, fontWeight: FontWeight.w700);
TextStyle fh16SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h16, fontWeight: FontWeight.w600);
TextStyle fh16SemiboldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h16, fontWeight: FontWeight.w600);
TextStyle fh16SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h16, fontWeight: FontWeight.w600);
TextStyle fh16mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h16, fontWeight: FontWeight.w500);
TextStyle fh16mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h16, fontWeight: FontWeight.w500);
TextStyle fh16mediumBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h16, fontWeight: FontWeight.w500);
TextStyle fh16regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h16, fontWeight: FontWeight.w400);
TextStyle fh16regularBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h16, fontWeight: FontWeight.w400);
TextStyle fh16regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h16, fontWeight: FontWeight.w400);
TextStyle fh16regularGrey = GoogleFonts.montserrat(
    color: Colors.black38, fontSize: h16, fontWeight: FontWeight.w400);

//textstyle for height 14
TextStyle fh14boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h14, fontWeight: FontWeight.w700);
TextStyle fh14boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h14, fontWeight: FontWeight.w700);
TextStyle fh14boldGrey = GoogleFonts.montserrat(
    color: Color(0xff797676), fontSize: h14, fontWeight: FontWeight.w700);
TextStyle fh14boldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h14, fontWeight: FontWeight.w700);
TextStyle fh14boldGreen = GoogleFonts.montserrat(
    color: green, fontSize: h14, fontWeight: FontWeight.w700);
TextStyle fh14SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h14, fontWeight: FontWeight.w600);
TextStyle fh14SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h14, fontWeight: FontWeight.w600);
TextStyle fh14SemiboldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h14, fontWeight: FontWeight.w600);
TextStyle fh14SemiboldGreen = GoogleFonts.montserrat(
    color: green, fontSize: h14, fontWeight: FontWeight.w600);
TextStyle fh14mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h14, fontWeight: FontWeight.w500);
TextStyle fh14mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h14, fontWeight: FontWeight.w500);
TextStyle fh14mediumBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h14, fontWeight: FontWeight.w500);
TextStyle fh14mediumGrey = GoogleFonts.montserrat(
    color: Color(0xff797676), fontSize: h14, fontWeight: FontWeight.w500);
TextStyle fh14mediumRed = GoogleFonts.montserrat(
    color: red, fontSize: h14, fontWeight: FontWeight.w500);
TextStyle fh14regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h14, fontWeight: FontWeight.w400);
TextStyle fh14regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h14, fontWeight: FontWeight.w400);
TextStyle fh14regularBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h14, fontWeight: FontWeight.w400);
TextStyle fh14regularGrey = GoogleFonts.montserrat(
    color: grey, fontSize: h14, fontWeight: FontWeight.w400);

//textstyle for height 12
TextStyle fh12boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h12, fontWeight: FontWeight.w700);
TextStyle fh12boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h12, fontWeight: FontWeight.w700);
TextStyle fh12boldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h12, fontWeight: FontWeight.w700);
TextStyle fh12SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h12, fontWeight: FontWeight.w600);
TextStyle fh12SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h12, fontWeight: FontWeight.w600);
TextStyle fh12SemiboldGreen = GoogleFonts.montserrat(
    color: green, fontSize: h12, fontWeight: FontWeight.w600);
TextStyle fh12SemiboldRed = GoogleFonts.montserrat(
    color: red, fontSize: h12, fontWeight: FontWeight.w600);
TextStyle fh12mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h12, fontWeight: FontWeight.w500);
TextStyle fh12mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h12, fontWeight: FontWeight.w500);
TextStyle fh12mediumRed = GoogleFonts.montserrat(
    color: red, fontSize: h12, fontWeight: FontWeight.w500);
TextStyle fh12mediumBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h12, fontWeight: FontWeight.w500);
TextStyle fh12regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h12, fontWeight: FontWeight.w400);
TextStyle fh12regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h12, fontWeight: FontWeight.w400);
TextStyle fh12regularBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h12, fontWeight: FontWeight.w400);
TextStyle fh12regularGrey = GoogleFonts.montserrat(
    color: grey, fontSize: h12, fontWeight: FontWeight.w400);
TextStyle fh12Grey = GoogleFonts.montserrat(
    color: grey, fontSize: h12, fontWeight: FontWeight.w400);

//textstyle for height 10
TextStyle fh10boldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h10, fontWeight: FontWeight.w700);
TextStyle fh10boldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h10, fontWeight: FontWeight.w700);
TextStyle fh10boldBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h10, fontWeight: FontWeight.w700);
TextStyle fh10SemiboldWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h10, fontWeight: FontWeight.w600);
TextStyle fh10SemiboldGrey = GoogleFonts.montserrat(
    color: grey, fontSize: h10, fontWeight: FontWeight.w600);
TextStyle fh10SemiboldBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h10, fontWeight: FontWeight.w600);
TextStyle fh10SemiboldGreen = GoogleFonts.montserrat(
    color: green, fontSize: h10, fontWeight: FontWeight.w600);
TextStyle fh10mediumWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h10, fontWeight: FontWeight.w500);
TextStyle fh10mediumBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h10, fontWeight: FontWeight.w500);
TextStyle fh10regularWhite = GoogleFonts.montserrat(
    color: Colors.white, fontSize: h10, fontWeight: FontWeight.w400);
TextStyle fh10regularBlue = GoogleFonts.montserrat(
    color: blue, fontSize: h10, fontWeight: FontWeight.w400);
TextStyle fh10regularBlack = GoogleFonts.montserrat(
    color: Colors.black, fontSize: h10, fontWeight: FontWeight.w400);
TextStyle fh10regularGreen = GoogleFonts.montserrat(
    color: green, fontSize: h10, fontWeight: FontWeight.w400);
