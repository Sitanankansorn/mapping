import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Material 3 theme supporting both Dark Mode and Light Mode.
class AppTheme {
  AppTheme._();

  // ── Brand colours ───────────────────────────────────────────────────
  static const Color _seed = Color(0xFF6750A4);
  static const Color _surfaceDark = Color(0xFF131118);
  static const Color _cardDark = Color(0xFF1E1B24);
  static const Color _surfaceLight = Color(0xFFF8F9FD);
  static const Color _cardLight = Color(0xFFFFFFFF);

  // ── Dark colour scheme ──────────────────────────────────────────────
  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
    surface: _surfaceDark,
    surfaceContainerLowest: const Color(0xFF0F0D13),
    surfaceContainerLow: const Color(0xFF1D1B20),
    surfaceContainer: const Color(0xFF211F26),
    surfaceContainerHigh: const Color(0xFF2B2930),
    surfaceContainerHighest: const Color(0xFF36343B),
  );

  // ── Light colour scheme ─────────────────────────────────────────────
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
    surface: _surfaceLight,
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF2F4F8),
    surfaceContainer: const Color(0xFFEBEEF5),
    surfaceContainerHigh: const Color(0xFFE2E6EF),
    surfaceContainerHighest: const Color(0xFFD6DBE6),
  );

  // ── Typography ──────────────────────────────────────────────────────
  static TextTheme get _textTheme => GoogleFonts.interTextTheme();

  // ── Dark theme data ─────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        textTheme: _textTheme.apply(
          bodyColor: darkScheme.onSurface,
          displayColor: darkScheme.onSurface,
        ),
        scaffoldBackgroundColor: _surfaceDark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkScheme.onSurface,
          ),
          iconTheme: IconThemeData(color: darkScheme.onSurface),
        ),
        cardTheme: CardThemeData(
          color: _cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkScheme.surfaceContainerHigh,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: darkScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: darkScheme.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: darkScheme.error, width: 2),
          ),
          errorStyle: TextStyle(color: darkScheme.error),
          labelStyle: TextStyle(color: darkScheme.onSurfaceVariant),
          hintStyle: TextStyle(
              color: darkScheme.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIconColor: darkScheme.onSurfaceVariant,
          suffixIconColor: darkScheme.onSurfaceVariant,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkScheme.primary,
            foregroundColor: darkScheme.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkScheme.primary,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _cardDark,
          indicatorColor: darkScheme.primaryContainer,
          elevation: 0,
          height: 72,
        ),
        dividerTheme: DividerThemeData(
          color: darkScheme.outlineVariant.withValues(alpha: 0.3),
          thickness: 1,
        ),
      );

  // ── Light theme data ────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        textTheme: _textTheme.apply(
          bodyColor: lightScheme.onSurface,
          displayColor: lightScheme.onSurface,
        ),
        scaffoldBackgroundColor: _surfaceLight,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: lightScheme.onSurface,
          ),
          iconTheme: IconThemeData(color: lightScheme.onSurface),
        ),
        cardTheme: CardThemeData(
          color: _cardLight,
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightScheme.surfaceContainerLow,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: lightScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: lightScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: lightScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: lightScheme.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: lightScheme.error, width: 2),
          ),
          errorStyle: TextStyle(color: lightScheme.error),
          labelStyle: TextStyle(color: lightScheme.onSurfaceVariant),
          hintStyle: TextStyle(
              color: lightScheme.onSurfaceVariant.withValues(alpha: 0.7)),
          prefixIconColor: lightScheme.onSurfaceVariant,
          suffixIconColor: lightScheme.onSurfaceVariant,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightScheme.primary,
            foregroundColor: lightScheme.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: lightScheme.primary,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _cardLight,
          indicatorColor: lightScheme.primaryContainer,
          elevation: 2,
          height: 72,
        ),
        dividerTheme: DividerThemeData(
          color: lightScheme.outlineVariant.withValues(alpha: 0.3),
          thickness: 1,
        ),
      );
}
