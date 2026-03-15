import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2563EB); // Blue-600
  static const secondaryColor = Color(0xFF10B981); // Emerald-500
  static const dangerColor = Color(0xFFEF4444);
  static const warningColor = Color(0xFFF59E0B);
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceDark = Color(0xFF1E293B);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surfaceLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.white,
          elevation: 8,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEFF6FF),
          labelStyle: const TextStyle(color: primaryColor, fontSize: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Color(0xFF1E293B),
          elevation: 8,
        ),
      );
}

/// Document type color mapping
extension DocumentTypeColor on String {
  Color get typeColor {
    switch (toLowerCase()) {
      case 'passport':
        return const Color(0xFF7C3AED);
      case 'license':
        return const Color(0xFF2563EB);
      case 'insurance':
        return const Color(0xFF059669);
      case 'medical':
        return const Color(0xFFDC2626);
      case 'tax':
        return const Color(0xFFD97706);
      case 'contract':
        return const Color(0xFF0891B2);
      case 'receipt':
        return const Color(0xFF65A30D);
      case 'certificate':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF64748B);
    }
  }

  String get typeIcon {
    switch (toLowerCase()) {
      case 'passport':
        return '🛂';
      case 'license':
        return '🪪';
      case 'insurance':
        return '🛡️';
      case 'medical':
        return '🏥';
      case 'tax':
        return '📊';
      case 'contract':
        return '📝';
      case 'receipt':
        return '🧾';
      case 'certificate':
        return '🎓';
      default:
        return '📄';
    }
  }
}
