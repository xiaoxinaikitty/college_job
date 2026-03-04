import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF2667FF);
  static const _secondary = Color(0xFF0EA5A4);
  static const _surface = Color(0xFFF4F7FE);
  static const _onSurfaceMuted = Color(0xFF64748B);
  static const _outline = Color(0xFFDCE6F4);

  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const [
        'PingFang SC',
        'Noto Sans SC',
        'Microsoft YaHei'
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _surface,
      textTheme: textTheme,
      dividerColor: _outline,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _outline),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        dense: false,
        iconColor: Color(0xFF4B5E7A),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        labelStyle: const TextStyle(color: _onSurfaceMuted),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _primary, width: 1.35),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.15),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.35),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF1FF),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _onSurfaceMuted,
          );
        }),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: _primary,
        unselectedLabelColor: _onSurfaceMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5FD),
        selectedColor: const Color(0xFFE3EDFF),
        disabledColor: const Color(0xFFE2E8F0),
        side: const BorderSide(color: _outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _primary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _primary,
          elevation: 0,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF334155),
          side: const BorderSide(color: _outline),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
