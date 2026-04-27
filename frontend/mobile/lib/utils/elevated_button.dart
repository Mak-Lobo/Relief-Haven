import 'package:flutter/material.dart';

final customElevatedBtnTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    minimumSize: WidgetStateProperty.all(Size(200, 50)),
    maximumSize: WidgetStateProperty.all(Size(350, 80)),
    elevation: WidgetStateProperty.all(10),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    animationDuration: Duration(milliseconds: 300),
    shadowColor: WidgetStateProperty.all(Colors.black.withAlpha(100)),
  ),
);
