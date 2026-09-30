import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palette: one warm accent on top of soft neutrals. Keeping it small
// is what makes the whole app feel consistent.
const kAccent = Color(0xFFFF5A36);
const kInk = Color(0xFF16161A);
const kBg = Color(0xFFF7F5F2);
const kSoft = Color(0xFFF1EEEA);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kAccent),
    scaffoldBackgroundColor: kBg,
  );

  OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: w == 0 ? BorderSide.none : BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(Colors.transparent),
      focusedBorder: border(kAccent, 1.5),
      errorBorder: border(Colors.redAccent, 1.2),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
    ),
  );
}
