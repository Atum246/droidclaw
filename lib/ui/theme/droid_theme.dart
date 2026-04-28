import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DroidTheme {
  static const Color bg = Color(0xFF06060A);
  static const Color surface = Color(0xFF0E0E18);
  static const Color surfaceLight = Color(0xFF141425);
  static const Color card = Color(0xFF1A1A30);
  static const Color cardLight = Color(0xFF222245);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentDark = Color(0xFF6D28D9);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color green = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color pink = Color(0xFFEC4899);
  static const Color txt = Color(0xFFF1F5F9);
  static const Color txt2 = Color(0xFF94A3B8);
  static const Color txt3 = Color(0xFF64748B);
  static const Color border = Color(0xFF1E293B);

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: accent, secondary: cyan, surface: surface, error: red),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: txt),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: txt),
      titleLarge: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: txt),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: txt, height: 1.6),
      bodyMedium: GoogleFonts.inter(fontSize: 13, color: txt2, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: txt),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: txt),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white,
        elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    ),
  );

  static const LinearGradient grad1 = LinearGradient(colors: [accent, Color(0xFFA78BFA)]);
  static const LinearGradient grad2 = LinearGradient(colors: [cyan, Color(0xFF0EA5E9)]);
  static const LinearGradient grad3 = LinearGradient(colors: [green, Color(0xFF34D399)]);
  static const LinearGradient grad4 = LinearGradient(colors: [pink, amber]);
}
