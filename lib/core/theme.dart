import 'package:flutter/material.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
// Use these exactly like Tailwind: AppColors.teal, AppColors.gray200, etc.

class AppColors {
  AppColors._();

  // Teal (primary / brand)
  static const teal900 = Color(0xFF04342C);
  static const teal800 = Color(0xFF085041);
  static const teal600 = Color(0xFF0F6E56);  // ← primary brand color
  static const teal400 = Color(0xFF1D9E75);
  static const teal200 = Color(0xFF5DCAA5);
  static const teal100 = Color(0xFF9FE1CB);
  static const teal50  = Color(0xFFE1F5EE);

  // Purple (accents)
  static const purple900 = Color(0xFF26215C);
  static const purple800 = Color(0xFF3C3489);
  static const purple600 = Color(0xFF534AB7);
  static const purple400 = Color(0xFF7F77DD);
  static const purple200 = Color(0xFFAFA9EC);
  static const purple100 = Color(0xFFCECBF6);
  static const purple50  = Color(0xFFEEEDFE);

  // Amber (warnings / subscription)
  static const amber900 = Color(0xFF412402);
  static const amber800 = Color(0xFF633806);
  static const amber600 = Color(0xFF854F0B);
  static const amber400 = Color(0xFFBA7517);
  static const amber200 = Color(0xFFEF9F27);
  static const amber100 = Color(0xFFFAC775);
  static const amber50  = Color(0xFFFAEEDA);

  // Coral (errors / danger)
  static const coral900 = Color(0xFF4A1B0C);
  static const coral800 = Color(0xFF712B13);
  static const coral600 = Color(0xFF993C1D);
  static const coral400 = Color(0xFFD85A30);
  static const coral200 = Color(0xFFF0997B);
  static const coral100 = Color(0xFFF5C4B3);
  static const coral50  = Color(0xFFFAECE7);

  // Blue (info)
  static const blue900 = Color(0xFF042C53);
  static const blue800 = Color(0xFF0C447C);
  static const blue600 = Color(0xFF185FA5);
  static const blue400 = Color(0xFF378ADD);
  static const blue200 = Color(0xFF85B7EB);
  static const blue100 = Color(0xFFB5D4F4);
  static const blue50  = Color(0xFFE6F1FB);

  // Gray (neutral / text)
  static const gray900 = Color(0xFF2C2C2A);
  static const gray800 = Color(0xFF444441);
  static const gray600 = Color(0xFF5F5E5A);
  static const gray400 = Color(0xFF888780);
  static const gray200 = Color(0xFFB4B2A9);
  static const gray100 = Color(0xFFD3D1C7);
  static const gray50  = Color(0xFFF1EFE8);

  // Semantic shortcuts
  static const background = Color(0xFFF8F7F4);
  static const surface    = Colors.white;
  static const border     = Color(0xFFE0DED8);
  static const borderMid  = Color(0xFFD3D1C7);

  static const textPrimary   = gray900;
  static const textSecondary = gray600;
  static const textMuted     = gray400;
  static const textHint      = gray200;

  static const success = teal600;
  static const warning = amber400;
  static const error   = coral600;
  static const info    = blue600;
}

// ── Text Styles ───────────────────────────────────────────────────────────────
// Use like Tailwind text sizes: AppText.h1, AppText.body, AppText.small, etc.

class AppText {
  AppText._();

  static const h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, height: 1.2);
  static const h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, height: 1.3);
  static const h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, height: 1.3);
  static const h4 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, height: 1.4);

  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, height: 1.6);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, height: 1.6);
  static const bodySm = TextStyle(fontSize: 13, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, height: 1.5);

  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static const labelSm = TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMuted, letterSpacing: 0.4);

  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textMuted, height: 1.4);

  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
      color: Colors.white);
  static const buttonSm = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
}

// ── Spacing ───────────────────────────────────────────────────────────────────
// Use like Tailwind spacing: AppSpacing.s4 = 16px (like p-4), etc.

class AppSpacing {
  AppSpacing._();

  static const double s1  = 4;
  static const double s2  = 8;
  static const double s3  = 12;
  static const double s4  = 16;
  static const double s5  = 20;
  static const double s6  = 24;
  static const double s8  = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;

  // Common paddings
  static const screenH = EdgeInsets.symmetric(horizontal: 24);
  static const screenV = EdgeInsets.symmetric(vertical: 24);
  static const screen  = EdgeInsets.symmetric(horizontal: 24, vertical: 24);
  static const card    = EdgeInsets.all(16);
  static const cardLg  = EdgeInsets.all(20);
}

// ── Radius ────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double sm  = 6;
  static const double md  = 10;
  static const double lg  = 14;
  static const double xl  = 20;
  static const double full = 999;

  static const sm_  = BorderRadius.all(Radius.circular(sm));
  static const md_  = BorderRadius.all(Radius.circular(md));
  static const lg_  = BorderRadius.all(Radius.circular(lg));
  static const xl_  = BorderRadius.all(Radius.circular(xl));
  static const full_= BorderRadius.all(Radius.circular(full));
}

// ── Shadows ───────────────────────────────────────────────────────────────────

class AppShadow {
  AppShadow._();

  static const sm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const md = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const lg = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 4,  offset: Offset(0, 2)),
  ];
}

// ── ThemeData ─────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal600,
      brightness: Brightness.light,
      background: AppColors.background,
      surface: AppColors.surface,
      primary: AppColors.teal600,
      error: AppColors.error,
    ),
    fontFamily: 'Inter',
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal600,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md_),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: AppText.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md_),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: AppColors.teal600, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF111110),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal400,
      brightness: Brightness.dark,
      background: const Color(0xFF111110),
      surface: const Color(0xFF1C1C1A),
      primary: AppColors.teal400,
      error: AppColors.coral400,
    ),
    fontFamily: 'Inter',
    dividerColor: const Color(0xFF2C2C2A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111110),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal400,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md_),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C1A),
      hintStyle: const TextStyle(color: Color(0xFF5F5E5A), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: Color(0xFF2C2C2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: Color(0xFF2C2C2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.md_,
        borderSide: const BorderSide(color: AppColors.teal400, width: 1.5),
      ),
    ),
  );
}
