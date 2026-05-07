import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  // ── Light ──────────────────────────────────────────────────────────────────

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff7b5363),
      surfaceTint: Color(0xff7b5363),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xfff2bed1),
      onPrimaryContainer: Color(0xff724a5b),
      secondary: Color(0xff785462),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfffdcedf),
      onSecondaryContainer: Color(0xff795563),
      tertiary: Color(0xff675b60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff8e8ee),
      onTertiaryContainer: Color(0xff73676c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff47464a),
      outline: Color(0xff78767b),
      outlineVariant: Color(0xffc8c5ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffecb9cb),
      primaryFixed: Color(0xffffd8e5),
      onPrimaryFixed: Color(0xff30111f),
      primaryFixedDim: Color(0xffecb9cb),
      onPrimaryFixedVariant: Color(0xff613b4b),
      secondaryFixed: Color(0xffffd8e6),
      onSecondaryFixed: Color(0xff2e131f),
      secondaryFixedDim: Color(0xffe8bacb),
      onSecondaryFixedVariant: Color(0xff5e3d4b),
      tertiaryFixed: Color(0xffeedee4),
      onTertiaryFixed: Color(0xff21191e),
      tertiaryFixedDim: Color(0xffd1c3c8),
      onTertiaryFixedVariant: Color(0xff4e4449),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() => _theme(lightScheme());

  // ── Dark ───────────────────────────────────────────────────────────────────

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffecb9cb),
      surfaceTint: Color(0xffecb9cb),
      onPrimary: Color(0xff482534),
      primaryContainer: Color(0xff613b4b),
      onPrimaryContainer: Color(0xffffd8e5),
      secondary: Color(0xffe8bacb),
      onSecondary: Color(0xff452733),
      secondaryContainer: Color(0xff5e3d4b),
      onSecondaryContainer: Color(0xffffd8e6),
      tertiary: Color(0xffd1c3c8),
      onTertiary: Color(0xff382e32),
      tertiaryContainer: Color(0xff4e4449),
      onTertiaryContainer: Color(0xffeedee4),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc8c5ca),
      outline: Color(0xff928f94),
      outlineVariant: Color(0xff47464a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff7b5363),
      primaryFixed: Color(0xffffd8e5),
      onPrimaryFixed: Color(0xff30111f),
      primaryFixedDim: Color(0xffecb9cb),
      onPrimaryFixedVariant: Color(0xff613b4b),
      secondaryFixed: Color(0xffffd8e6),
      onSecondaryFixed: Color(0xff2e131f),
      secondaryFixedDim: Color(0xffe8bacb),
      onSecondaryFixedVariant: Color(0xff5e3d4b),
      tertiaryFixed: Color(0xffeedee4),
      onTertiaryFixed: Color(0xff21191e),
      tertiaryFixedDim: Color(0xffd1c3c8),
      onTertiaryFixedVariant: Color(0xff4e4449),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff363434),
    );
  }

  ThemeData dark() => _theme(darkScheme());

  // ── Dark High Contrast ─────────────────────────────────────────────────────

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffebf0),
      surfaceTint: Color(0xffecb9cb),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfff2bed1),
      onPrimaryContainer: Color(0xff2b0d1b),
      secondary: Color(0xfffff4f6),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xfffdcedf),
      onSecondaryContainer: Color(0xff381b28),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeedee4),
      onTertiaryContainer: Color(0xff30282c),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff2eff4),
      outlineVariant: Color(0xffc4c2c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff623d4c),
      primaryFixed: Color(0xffffd8e5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffecb9cb),
      onPrimaryFixedVariant: Color(0xff230715),
      secondaryFixed: Color(0xffffd8e6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe8bacb),
      onSecondaryFixedVariant: Color(0xff210815),
      tertiaryFixed: Color(0xffeedee4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd1c3c8),
      onTertiaryFixedVariant: Color(0xff160f13),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() => _theme(darkHighContrastScheme());

  // ── Theme builder ──────────────────────────────────────────────────────────

  ThemeData _theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

// ── Supporting types ──────────────────────────────────────────────────────────

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
