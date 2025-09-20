import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // 권장 기본 폰트
  static const String primary = 'NotoSansKR';

  // 한국어 안전 폴백
  static const List<String> koreanFallback = [
    'Noto Sans KR', // 메인
    'Apple SD Gothic Neo', // iOS
    'Malgun Gothic', // Windows/Android 일부
    'Roboto', // 마지막 안전망
  ];

  static TextStyle _f(TextStyle base) =>
      base.copyWith(fontFamilyFallback: koreanFallback);

  // Headings
  static TextStyle get heading1 => _f(
    GoogleFonts.notoSansKr(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
  );
  static TextStyle get heading2 => _f(
    GoogleFonts.notoSansKr(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );
  static TextStyle get heading3 => _f(
    GoogleFonts.notoSansKr(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  // Body
  static TextStyle get bodyLarge => _f(
    GoogleFonts.notoSansKr(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      height: 1.4,
    ),
  );
  static TextStyle get bodyMedium => _f(
    GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.5,
    ),
  );
  static TextStyle get bodySmall => _f(
    GoogleFonts.notoSansKr(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.5,
    ),
  );
  static TextStyle get caption => _f(
    GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
    ),
  );

  // Buttons
  static TextStyle get buttonPrimary => _f(
    GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );
  static TextStyle get buttonSecondary => _f(
    GoogleFonts.notoSansKr(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF464E57),
    ),
  );
  static TextStyle get buttonSmall => _f(
    GoogleFonts.notoSansKr(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF464E57),
    ),
  );

  // Navigation
  static TextStyle get navSelected => _f(
    GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFF7621),
    ),
  );
  static TextStyle get navUnselected => _f(
    GoogleFonts.notoSansKr(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    ),
  );

  // Logo (영문 위주지만 혹시 대비해 폴백 추가)
  static TextStyle get logotext => _f(
    GoogleFonts.pacifico(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    ),
  );
}

class AppThemes {
  static ThemeData get primaryTheme => ThemeData(
    fontFamily: AppFonts.primary,
    fontFamilyFallback: AppFonts.koreanFallback,
    textTheme: GoogleFonts.notoSansKrTextTheme(),
    primaryTextTheme: GoogleFonts.notoSansKrTextTheme(),
  );

  static ThemeData get pacificoTheme => ThemeData(
    fontFamilyFallback: AppFonts.koreanFallback,
    textTheme: GoogleFonts.pacificoTextTheme(),
    primaryTextTheme: GoogleFonts.pacificoTextTheme(),
  );
}
