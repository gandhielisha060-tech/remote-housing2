import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _indigo = Color(0xFF9D8CFF);
  static const _magenta = Color(0xFFFF6B9A);
  static const _aqua = Color(0xFF55D6D2);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4C3BAA),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE6E0FF),
      onPrimaryContainer: Color(0xFF17005D),
      secondary: Color(0xFFD13E70),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFD9E4),
      onSecondaryContainer: Color(0xFF3F0019),
      tertiary: Color(0xFF167C80),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB9F2F0),
      onTertiaryContainer: Color(0xFF002020),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF9F8FD),
      onSurface: Color(0xFF1B1A22),
      surfaceContainerHighest: Color(0xFFE9E6F2),
      onSurfaceVariant: Color(0xFF5A5666),
      outline: Color(0xFF777282),
      outlineVariant: Color(0xFFD0CBD8),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF302E37),
      onInverseSurface: Color(0xFFF3F0F7),
      inversePrimary: Color(0xFFBEB0FF),
    );
    return _baseTheme(
      scheme,
      scaffold: const Color(0xFFF4F2F9),
      inputFill: Colors.white,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _indigo,
      onPrimary: Color(0xFF201064),
      primaryContainer: Color(0xFF3B2A88),
      onPrimaryContainer: Color(0xFFE8E2FF),
      secondary: _magenta,
      onSecondary: Color(0xFF41001D),
      secondaryContainer: Color(0xFF76103B),
      onSecondaryContainer: Color(0xFFFFD9E4),
      tertiary: _aqua,
      onTertiary: Color(0xFF003737),
      tertiaryContainer: Color(0xFF07585A),
      onTertiaryContainer: Color(0xFFB9F2F0),
      error: Color(0xFFFF6B7C),
      onError: Color(0xFF41000A),
      errorContainer: Color(0xFF750019),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF101525),
      onSurface: Color(0xFFF0F0FA),
      surfaceContainerHighest: Color(0xFF1A243A),
      onSurfaceVariant: Color(0xFFB7B5C8),
      outline: Color(0xFF62647B),
      outlineVariant: Color(0xFF2C3651),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFF0F0FA),
      onInverseSurface: Color(0xFF1A243A),
      inversePrimary: Color(0xFF4C3BAA),
    );
    return _baseTheme(
      scheme,
      scaffold: const Color(0xFF070A12),
      inputFill: const Color(0xFF0D1322),
    );
  }

  static ThemeData _baseTheme(
    ColorScheme scheme, {
    required Color scaffold,
    required Color inputFill,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Times New Roman',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Times New Roman'),
        displayMedium: TextStyle(fontFamily: 'Times New Roman'),
        displaySmall: TextStyle(fontFamily: 'Times New Roman'),
        headlineLarge: TextStyle(fontFamily: 'Times New Roman'),
        headlineMedium: TextStyle(fontFamily: 'Times New Roman'),
        headlineSmall: TextStyle(fontFamily: 'Times New Roman'),
        titleLarge: TextStyle(fontFamily: 'Times New Roman'),
        titleMedium: TextStyle(fontFamily: 'Times New Roman'),
        titleSmall: TextStyle(fontFamily: 'Times New Roman'),
        labelLarge: TextStyle(fontFamily: 'Times New Roman'),
        labelMedium: TextStyle(fontFamily: 'Times New Roman'),
        labelSmall: TextStyle(fontFamily: 'Times New Roman'),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: 'Times New Roman',
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(
          alpha: scheme.brightness == Brightness.dark ? 0.9 : 1,
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontFamily: 'Times New Roman',
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.secondary, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}
