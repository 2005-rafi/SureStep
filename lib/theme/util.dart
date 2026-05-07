import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns a [TextTheme] using Roboto for body text and display text.
/// This is the single source of typography for the entire application.
TextTheme createTextTheme() {
  const base = TextTheme();
  final body = GoogleFonts.robotoTextTheme(base);
  final display = GoogleFonts.robotoTextTheme(base);
  return display.copyWith(
    bodyLarge: body.bodyLarge,
    bodyMedium: body.bodyMedium,
    bodySmall: body.bodySmall,
    labelLarge: body.labelLarge,
    labelMedium: body.labelMedium,
    labelSmall: body.labelSmall,
  );
}
