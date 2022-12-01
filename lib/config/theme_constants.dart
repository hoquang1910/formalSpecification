import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:fomal_specification/config/code_color/code_colors.dart';

const kPrimaryColor = Color(0xFF00BF6D);
const kSecondaryColorLightTheme = Color.fromARGB(255, 4, 191, 69);
const kSecondaryColorDarkTheme = Color.fromARGB(255, 251, 251, 251);
const kContentColorLightTheme = Color.fromRGBO(29, 29, 53, 1);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarninngColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);
const kDefaultPadding = 20.0;
const kScaffoldBackgroundColorDarkTheme = Color.fromARGB(115, 41, 41, 41);
const kScaffoldBackgroundColorLightTheme = Color.fromARGB(255, 246, 245, 245);
const kBackgroundColorLightTheme = Colors.black;
const kBackgroundColorDarkTheme = Color.fromARGB(255, 15, 199, 223);
const kBackgroundCodeAreaColorLightTheme = Color.fromARGB(255, 255, 255, 255);
const kBackgroundCodeAreaColorDarkTheme = ui.Color.fromARGB(255, 46, 46, 45);

//LightTheme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  iconTheme: const IconThemeData(color: kContentColorLightTheme),
  textTheme: lightTextTheme,
  scaffoldBackgroundColor: kScaffoldBackgroundColorLightTheme,
  backgroundColor: kBackgroundColorLightTheme,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kBackgroundColorLightTheme,
  ),
  colorScheme: const ColorScheme.light(
    background: kBackgroundCodeAreaColorLightTheme,
    primary: kPrimaryColor,
    secondary: kSecondaryColorLightTheme,
    error: kErrorColor,
  ),
  extensions: const <ThemeExtension<dynamic>>[
    CodeColor(
      functionNameColor: Color.fromARGB(255, 113, 95, 28),
      dataTypeColor: Color.fromARGB(255, 5, 108, 108),
      argumentColor: Color.fromARGB(255, 11, 90, 179),
      operatorColor: Colors.black,
      conditionColor: Color.fromARGB(255, 209, 4, 209),
      argumentOfConditionExpressionColor: Color.fromARGB(255, 11, 90, 179),
      parenthesisOfConditionExpressionColor: Color.fromARGB(255, 13, 109, 39),
      trueFalseExpressionColor: Color.fromARGB(255, 26, 55, 246),
      parenthesisOfFunctionColor: Color.fromARGB(255, 26, 55, 246),
    ),
  ],
);

TextStyle lightTextStyle = const TextStyle(
  fontSize: 17,
  color: Colors.black,
  fontWeight: FontWeight.w500,
  height: 1.6,
);

TextTheme lightTextTheme = TextTheme(
  bodyText1: lightTextStyle,
);

//DarkTheme
ThemeData darkTheme = ThemeData(
  textTheme: darkTextTheme,
  backgroundColor: kBackgroundColorDarkTheme,
  scaffoldBackgroundColor: kScaffoldBackgroundColorDarkTheme,
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(color: kContentColorDarkTheme),
  primaryColor: Colors.white,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kBackgroundColorDarkTheme,
  ),
  colorScheme: const ColorScheme.dark(
    background: kBackgroundCodeAreaColorDarkTheme,
    primary: kPrimaryColor,
    secondary: kSecondaryColorDarkTheme,
    error: kErrorColor,
  ),
  extensions: const <ThemeExtension<dynamic>>[
    CodeColor(
      functionNameColor: Color.fromARGB(255, 242, 227, 174),
      dataTypeColor: Color.fromARGB(255, 64, 211, 189),
      argumentColor: Color.fromARGB(255, 136, 202, 242),
      operatorColor: Colors.white,
      conditionColor: Color.fromARGB(255, 237, 101, 231),
      argumentOfConditionExpressionColor: Color.fromARGB(255, 242, 227, 174),
      parenthesisOfConditionExpressionColor: Color.fromARGB(255, 58, 138, 209),
      trueFalseExpressionColor: Color.fromARGB(255, 58, 138, 209),
      parenthesisOfFunctionColor: Color.fromARGB(255, 240, 240, 62),
    ),
  ],
);

TextStyle darkTextStyle = const TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w500,
  color: Colors.white,
  height: 1.6,
);

TextTheme darkTextTheme = TextTheme(bodyText1: darkTextStyle);
