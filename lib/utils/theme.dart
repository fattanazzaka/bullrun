// lib/utils/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette (dark mode dari referensi ungu) ─────────────────────────────────
  //
  // Referensi pakai light theme dengan aksen violet.
  // Dark mode-nya: balik luminance, pertahankan hue ungu yang sama.
  //
  static const Color background     = Color(0xFF0D0A1A); // hampir hitam, hue ungu
  static const Color surface        = Color(0xFF171330); // card — ungu sangat gelap
  static const Color surfaceVariant = Color(0xFF211C3D); // input / chip
  static const Color surfaceHigh    = Color(0xFF2C2650); // elevated / hover

  // Violet utama — diambil langsung dari hue referensi
  static const Color primary        = Color(0xFF8B5CF6); // violet vivid
  static const Color primaryLight   = Color(0xFFA78BFA); // lavender terang
  static const Color primaryDim     = Color(0xFF4C1D95); // ungu gelap (indicator)
  static const Color primarySubtle  = Color(0xFF2D1B69); // ungu sangat gelap (bg pill)

  // Gain / Loss — tetap hijau & merah (standar saham)
  static const Color green          = Color(0xFF22C55E);
  static const Color greenBg        = Color(0xFF14532D);
  static const Color red            = Color(0xFFEF4444);
  static const Color redBg          = Color(0xFF7F1D1D);

  // Text
  static const Color textPrimary    = Color(0xFFF5F3FF); // putih keunguan
  static const Color textSecondary  = Color(0xFFAFA3CC); // lavender pudar
  static const Color textTertiary   = Color(0xFF6B6080); // muted

  // Border & misc
  static const Color border         = Color(0xFF2A2347); // garis tipis ungu
  static const Color gold           = Color(0xFFFBBF24);

  // ── ThemeData ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SF Pro Display', // fallback ke system font
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary:    primary,
        secondary:  primaryLight,
        surface:    surface,
        background: background,
        onPrimary:  Colors.white,
        onSurface:  textPrimary,
        outline:    border,
        tertiary:   green,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: textTertiary,
      ),

      // NavigationBar (Material 3 bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primarySubtle,
        elevation: 0,
        height: 64,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
                color: primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: textTertiary, fontSize: 11);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryLight, size: 22);
          }
          return const IconThemeData(color: textTertiary, size: 22);
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryDim,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 12),
        side: const BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(color: textPrimary,   fontSize: 28, fontWeight: FontWeight.bold,   letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary,   fontSize: 22, fontWeight: FontWeight.bold,   letterSpacing: -0.3),
        headlineSmall:  TextStyle(color: textPrimary,   fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge:     TextStyle(color: textPrimary,   fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium:    TextStyle(color: textPrimary,   fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge:      TextStyle(color: textPrimary,   fontSize: 14, height: 1.5),
        bodyMedium:     TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
        bodySmall:      TextStyle(color: textSecondary, fontSize: 12),
        labelSmall:     TextStyle(color: textTertiary,  fontSize: 11),
      ),
    );
  }
}
