import 'package:flutter/material.dart';

// New color scheme: Black background, White text, Green accent
const Color kGreenAccent = Color.fromRGBO(76, 175, 80, 1.0); //#4CAF50 - Green accent
const Color kGreenDark = Color.fromRGBO(56, 142, 60, 1.0); //#388E3C - Darker green
const Color kGreenLight = Color.fromRGBO(129, 199, 132, 1.0); //#81C784 - Lighter green
const Color kBlackBackground = Color.fromRGBO(0, 0, 0, 1.0); //#000000 - Black background
const Color kBlackDark = Color.fromRGBO(18, 18, 18, 1.0); //#121212 - Dark black
const Color kWhiteText = Color.fromRGBO(255, 255, 255, 1.0); //#FFFFFF - White text
const Color kGrey = Color.fromRGBO(135, 137, 163, 1.0); //#8789A3 - Grey (unchanged for secondary text)
const Color kGrey92 = Color.fromRGBO(235, 235, 235, 1.0); //#ebebeb - Light grey
const Color kGreyLight = Color.fromRGBO(171, 175, 215, 1.0); //#abafd7 - Light grey
const Color kMikadoYellow = Color.fromRGBO(249, 176, 145, 1.0); //#F9B091 - Yellow (for warnings/missing words)
const Color kDarkTheme = Color.fromRGBO(0, 0, 0, 1.0); //#000000 - Black for dark theme

// Legacy purple colors kept for backward compatibility but replaced with green/black
const Color kPurplePrimary = kGreenAccent; // Replaced with green
const Color kPurpleSecondary = kGreenDark; // Replaced with darker green
const Color kDarkPurple = kBlackDark; // Replaced with dark black
const Color kBlackPurple = kBlackBackground; // Replaced with black background
const Color kLinearPurple1 = kGreenLight; // Replaced with light green
const Color kLinearPurple2 = kGreenAccent; // Replaced with green

const kColorScheme = ColorScheme(
  primary: kGreenAccent,
  primaryContainer: kGreenAccent,
  secondary: kGreenDark,
  secondaryContainer: kGreenDark,
  surface: kBlackBackground,
  background: kBlackBackground,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onSurface: kWhiteText,
  onBackground: kWhiteText,
  onError: Colors.white,
  brightness: Brightness.dark,
);
