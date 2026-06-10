import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CosmosColors {
  static const background = Color(0xFF050505);
  static const surface = Color(0xFF131313);
  static const surfaceContainerLow = Color(0xFF1C1B1B);
  static const surfaceContainer = Color(0xFF201F1F);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFBAC9CC);
  static const outline = Color(0xFF849396);
  static const outlineVariant = Color(0xFF3B494C);
  static const primary = Color(0xFFC3F5FF);
  static const primaryContainer = Color(0xFF00E5FF);
  static const primaryFixedDim = Color(0xFF00DAF3);
  static const secondary = Color(0xFFDDB7FF);
  static const error = Color(0xFFFFB4AB);

  static const glassFill = Color(0x262A2A2A);
  static const glassBorder = Color(0x1A00E5FF);
  static const hairline = Color(0x1AFFFFFF);
}

class CosmosTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CosmosColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CosmosColors.primaryContainer,
        secondary: CosmosColors.secondary,
        error: CosmosColors.error,
        surface: CosmosColors.surface,
        onSurface: CosmosColors.onSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}

class CosmosTextStyles {
  static TextStyle displayLg({Color? color}) => GoogleFonts.inter(
    fontSize: 48,
    height: 1.1,
    letterSpacing: -0.96,
    fontWeight: FontWeight.w700,
    color: color ?? CosmosColors.onSurface,
  );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.inter(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: color ?? CosmosColors.onSurface,
  );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: color ?? CosmosColors.onSurface,
  );

  static TextStyle bodySm({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: color ?? CosmosColors.onSurface,
  );

  static TextStyle dataMono({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 1.2,
    letterSpacing: 0.7,
    fontWeight: FontWeight.w500,
    color: color ?? CosmosColors.onSurface,
  );

  static TextStyle labelCaps({Color? color, double letterSpacing = 0}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 12,
        height: 1.0,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
        color: color ?? CosmosColors.onSurface,
      );
}
