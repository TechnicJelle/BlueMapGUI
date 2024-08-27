import "package:flutter/material.dart";

class TechApp extends MaterialApp {
  final Color primary;
  final Color secondary;
  final String? fontFamily;
  final double? fontSizeFactor;
  TechApp({
    required super.title,
    super.debugShowCheckedModeBanner = false,
    required this.primary,
    required this.secondary,
    required super.themeMode,
    this.fontFamily,
    this.fontSizeFactor,
    super.routes,
    required super.home,
    super.key,
  }) : super(
          theme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.light(
              primary: primary,
              secondary: secondary,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.dark(
              primary: primary,
              secondary: secondary,
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                appBarTheme: AppBarTheme(color: primary),
                textTheme: Theme.of(context).textTheme.apply(
                      fontSizeFactor: fontSizeFactor ?? 1.0,
                      fontFamily: fontFamily,
                    ),
              ),
              child: child!,
            );
          },
        );
}
