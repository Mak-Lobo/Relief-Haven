import 'package:flutter/material.dart';

final customElevatedBtnTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    minimumSize: WidgetStateProperty.all(Size(200, 50)),
    maximumSize: WidgetStateProperty.all(Size(double.infinity * 0.75, 100)),
    elevation: WidgetStateProperty.all(5),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    // backgroundColor: WidgetStateProperty.all(value)
  ),
);
