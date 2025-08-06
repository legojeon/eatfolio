import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Primary Font Family
  static const String primary = 'NanumGothic';
  
  // Text Styles with NanumGothic Font
  static TextStyle get heading1 => GoogleFonts.nanumGothic(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static TextStyle get heading2 => GoogleFonts.nanumGothic(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static TextStyle get heading3 => GoogleFonts.nanumGothic(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.nanumGothic(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.nanumGothic(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  
  static TextStyle get bodySmall => GoogleFonts.nanumGothic(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  
  static TextStyle get caption => GoogleFonts.nanumGothic(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.grey,
  );
  
  // Button Text Styles
  static TextStyle get buttonPrimary => GoogleFonts.nanumGothic(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get buttonSecondary => GoogleFonts.nanumGothic(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF464E57),
  );
  
  static TextStyle get buttonSmall => GoogleFonts.nanumGothic(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF464E57),
  );
  
  // Navigation Text Styles
  static TextStyle get navSelected => GoogleFonts.nanumGothic(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: const Color(0xFFFF7621),
  );
  
  static TextStyle get navUnselected => GoogleFonts.nanumGothic(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
}

// Primary Theme with Jua Font
class AppThemes {
  static ThemeData get primaryTheme => ThemeData(
    textTheme: GoogleFonts.nanumGothicTextTheme(),
    primaryTextTheme: GoogleFonts.nanumGothicTextTheme(),
  );
}