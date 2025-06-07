import 'package:flutter/material.dart';

class ChuDe {
  // Màu sắc ứng dụng - Chế độ sáng
  static const Color mauChinh = Color(0xFFD13639);
  static const Color mauPhu = Color(0xFFFFF0ED);
  static const Color mauNen = Colors.white;
  static const Color mauChu = Color(0xFF333333);
  static const Color mauChuPhu = Color(0xFF8A8A8A);
  static const Color mauXanhLa = Color(0xFF4CAF50);
  static const Color mauVang = Color(0xFFFFD600);

  // Màu sắc ứng dụng - Chế độ tối
  static const Color mauChinhToi = Color(0xFFFF5252);
  static const Color mauPhuToi = Color(0xFF3D2C2C);
  static const Color mauNenToi = Color(0xFF121212);
  static const Color mauChuToi = Color(0xFFEEEEEE);
  static const Color mauChuPhuToi = Color(0xFFAAAAAA);
  static const Color mauXanhLaToi = Color(0xFF66BB6A);
  static const Color mauVangToi = Color(0xFFFFD740);

  // Màu sắc cho tin nhắn - Chế độ sáng
  static const Color mauTinNhanGui = Color(0xFF007AFF);
  static const Color mauTinNhanNhan = Color(0xFFF2F2F7);
  static const Color mauNenTinNhan = Color(0xFFFBFBFD);
  static const Color mauViTri = Color(0xFF34C759);
  static const Color mauOnline = Color(0xFF30D158);
  static const Color mauOffline = Color(0xFF8E8E93);

  // Màu sắc cho tin nhắn - Chế độ tối
  static const Color mauTinNhanGuiToi = Color(0xFF0A84FF);
  static const Color mauTinNhanNhanToi = Color(0xFF2C2C2E);
  static const Color mauNenTinNhanToi = Color(0xFF000000);
  static const Color mauViTriToi = Color(0xFF32D74B);
  static const Color mauOnlineToi = Color(0xFF30D158);
  static const Color mauOfflineToi = Color(0xFF636366);

  // Gradient cho tin nhắn
  static const LinearGradient gradientTinNhan = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow cho card
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  // Kiểu chữ
  static const TextStyle kieuChuTieuDe = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: mauChu,
  );

  static const TextStyle kieuChuTieuDePhu = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: mauChu,
  );

  static const TextStyle kieuChuNoiDungPhu = TextStyle(
    fontSize: 14,
    color: mauChuPhu,
  );

  static const TextStyle kieuChuNut = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Dữ liệu chủ đề sáng
  static ThemeData chuDeSang = ThemeData(
    useMaterial3: true,
    primaryColor: mauChinh,
    scaffoldBackgroundColor: mauNen,
    colorScheme: ColorScheme.light(
      primary: mauChinh,
      secondary: mauPhu,
      surface: mauNen,
      onPrimary: Colors.white,
      onSecondary: mauChu,
      onSurface: mauChu,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: mauNen,
      elevation: 0,
      iconTheme: IconThemeData(color: mauChu),
      titleTextStyle: TextStyle(
        color: mauChu,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mauChinh,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mauChinh,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mauChinh),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: mauChinh,
      unselectedItemColor: mauChuPhu,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinh;
        }
        return Colors.white;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinh;
        }
        return mauChuPhu;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinh;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinh.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // Dữ liệu chủ đề tối
  static ThemeData chuDeToi = ThemeData(
    useMaterial3: true,
    primaryColor: mauChinhToi,
    scaffoldBackgroundColor: mauNenToi,
    colorScheme: ColorScheme.dark(
      primary: mauChinhToi,
      secondary: mauPhuToi,
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: mauChuToi,
      onSurface: mauChuToi,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: mauChuToi),
      titleTextStyle: TextStyle(
        color: mauChuToi,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mauChinhToi,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mauChinhToi,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mauChinhToi),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: mauChuPhuToi),
      labelStyle: TextStyle(color: mauChuPhuToi),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: mauChinhToi,
      unselectedItemColor: mauChuPhuToi,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinhToi;
        }
        return Color(0xFF3E3E3E);
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinhToi;
        }
        return mauChuPhuToi;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinhToi;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return mauChinhToi.withOpacity(0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3E3E3E),
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: mauChuToi),
      bodyMedium: TextStyle(color: mauChuToi),
      bodySmall: TextStyle(color: mauChuPhuToi),
      titleLarge: TextStyle(color: mauChuToi),
      titleMedium: TextStyle(color: mauChuToi),
      titleSmall: TextStyle(color: mauChuToi),
      labelLarge: TextStyle(color: mauChuToi),
      labelMedium: TextStyle(color: mauChuToi),
      labelSmall: TextStyle(color: mauChuToi),
    ),
  );
}
