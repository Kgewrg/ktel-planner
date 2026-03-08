// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

// ThemeData lightTheme = ThemeData(
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: const Color.fromARGB(255, 230, 74, 25),
//     brightness: Brightness.light,
//   ),
//   inputDecorationTheme: InputDecorationTheme(
//     border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
//   ),
// );

class appColors {
  static const Color surfaceColor = Color.fromARGB(255, 34, 28, 21);
  static const Color secondaryColor = Color.fromARGB(255, 249, 180, 158);
}

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 255, 204, 188),
    brightness: Brightness.dark,
    surface: appColors.surfaceColor,
    secondary: appColors.secondaryColor,
    tertiary: const Color.fromARGB(255, 179, 92, 64),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
  ),
  scaffoldBackgroundColor: appColors.surfaceColor,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 17),
      foregroundColor: appColors.surfaceColor,
      backgroundColor: appColors.secondaryColor,
    ),
  ),
);
