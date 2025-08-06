import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Font Families
  static const String sen = 'Sen';
  static const String barlow = 'Barlow';
  static const String jua = 'Jua';
  
  // Text Styles
  static TextStyle get heading1 => GoogleFonts.barlow(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  static TextStyle get heading2 => GoogleFonts.barlow(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  
  static TextStyle get heading3 => GoogleFonts.barlow(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.barlow(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.barlow(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  
  static TextStyle get bodySmall => GoogleFonts.barlow(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  
  static TextStyle get caption => GoogleFonts.barlow(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  
  // Button Text Styles
  static TextStyle get buttonPrimary => GoogleFonts.sen(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  static TextStyle get buttonSecondary => GoogleFonts.sen(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF464E57),
  );
  
  static TextStyle get buttonSmall => GoogleFonts.sen(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF464E57),
  );
  
  // Navigation Text Styles
  static TextStyle get navSelected => GoogleFonts.sen(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFF7621),
  );
  
  static TextStyle get navUnselected => GoogleFonts.sen(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  
  // Special Font Styles
  static TextStyle get juaHeading => GoogleFonts.jua(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  
  static TextStyle get juaBody => GoogleFonts.jua(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
}

// Theme Data for different font preferences
class AppThemes {
  static ThemeData get barlowTheme => ThemeData(
    textTheme: GoogleFonts.barlowTextTheme(),
    primaryTextTheme: GoogleFonts.barlowTextTheme(),
  );
  
  static ThemeData get juaTheme => ThemeData(
    textTheme: GoogleFonts.juaTextTheme(),
    primaryTextTheme: GoogleFonts.juaTextTheme(),
  );
  
  static ThemeData get senTheme => ThemeData(
    textTheme: GoogleFonts.senTextTheme(),
    primaryTextTheme: GoogleFonts.senTextTheme(),
  );
}