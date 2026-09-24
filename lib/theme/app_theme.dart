import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _background = Color(0xff050914);
  static const _surface = Color(0xff091225);
  static const _surfaceHigh = Color(0xff111d38);
  static const _cyan = Color(0xff16dcff);
  static const _blue = Color(0xff2474ff);

  static final dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: _background,
    colorScheme:
        const ColorScheme.dark(
          primary: _cyan,
          onPrimary: Color(0xff00151d),
          primaryContainer: Color(0xff004b70),
          onPrimaryContainer: Color(0xffc6f4ff),
          secondary: _blue,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xff152c63),
          onSecondaryContainer: Color(0xffdce7ff),
          surface: _surface,
          onSurface: Color(0xfff4f7ff),
          error: Color(0xffffb4ab),
          onError: Color(0xff690005),
        ).copyWith(
          surfaceContainerLowest: _background,
          surfaceContainerLow: const Color(0xff080f20),
          surfaceContainer: _surface,
          surfaceContainerHigh: _surfaceHigh,
          surfaceContainerHighest: const Color(0xff182746),
          outline: const Color(0xff52729c),
          outlineVariant: const Color(0xff263b5d),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff070e20),
      foregroundColor: Color(0xfff4f7ff),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: _cyan,
      inactiveTrackColor: Color(0xff29456f),
      thumbColor: Color(0xffe8fbff),
      overlayColor: Color(0x3316dcff),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _cyan),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _surfaceHigh,
      contentTextStyle: TextStyle(color: Color(0xfff4f7ff)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
