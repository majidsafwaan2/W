import 'package:flutter/material.dart';
import 'package:resources/styles/color.dart';
import 'package:resources/styles/text_styles.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  colorScheme: kColorScheme,
  appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: kBlackBackground),
  scaffoldBackgroundColor: kBlackBackground,
  textTheme: kTextTheme.apply(
    bodyColor: kWhiteText,
    decorationColor: kWhiteText,
    displayColor: kWhiteText,
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: kColorScheme.copyWith(
    primary: kGreenAccent,
    onPrimary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: kBlackBackground),
  scaffoldBackgroundColor: kBlackBackground,
  textTheme: kTextTheme.apply(
    bodyColor: kWhiteText,
    decorationColor: kWhiteText,
    displayColor: kWhiteText,
  ),
);
