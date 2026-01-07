
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Add these color constants at the top
const _backgroundColor = Color(0xFFFFFFFF);
const _borderColor = Color(0xFFE2E8F0);
const _textColor = Color(0xFF0F172A);
const _mutedTextColor = Color(0xFF64748B);
const _focusedBorderColor = Color(0xFF94A3B8);
const _primaryColor = Color(0xFF020817);
const _surfaceColor = Color(0xFFF8FAFC);

final _borderRadius = BorderRadius.circular(6);
final _dialogBorderRadius = BorderRadius.circular(8);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'poppins',
  primaryColor: _primaryColor,
  scaffoldBackgroundColor: _surfaceColor,
  cardColor: _backgroundColor,
  highlightColor: Colors.black,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: _borderRadius,
      side: const BorderSide(color: _borderColor),
    ),
    backgroundColor: const Color(0xFFF5F5F5),
    foregroundColor: _textColor,
    elevation: 0,
  ),
  datePickerTheme: DatePickerThemeData(
    todayForegroundColor: WidgetStateProperty.all(Colors.black),
    backgroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    dayStyle: const TextStyle(fontSize: 14),
    yearStyle: const TextStyle(fontSize: 14),
    weekdayStyle: const TextStyle(fontSize: 12),
    dayForegroundColor: WidgetStateProperty.all(Colors.black),
    dayOverlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.7)),
    dayShape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    surfaceTintColor: Colors.white,
    todayBackgroundColor: WidgetStateProperty.all(
      Colors.black.withValues(alpha: 0.4),
    ),
    shadowColor: Colors.black,
    elevation: 4,
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    hourMinuteColor: Colors.grey.shade100,
    hourMinuteTextColor: Colors.black,
    dialBackgroundColor: Colors.black,
    elevation: 4,
  ),

  // Dropdown Menu Themes
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      fillColor: Colors.grey.shade100,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          style: BorderStyle.solid,
          color: Colors.black,
          width: 2,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      hintStyle: const TextStyle(color: Color.fromARGB(137, 205, 171, 171)),
    ),
    menuStyle: MenuStyle(
      shadowColor: WidgetStateProperty.all(Colors.black),
      surfaceTintColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      elevation: const WidgetStatePropertyAll(4),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textStyle: const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _borderColor),
        ),
      ),
      foregroundColor: WidgetStateProperty.all(_textColor),
      backgroundColor: WidgetStateProperty.all(_backgroundColor),
    ),
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    filled: true,
    fillColor: _backgroundColor,
    border: OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: _borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: _borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: _focusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: Colors.red),
    ),
    hintStyle: const TextStyle(
      color: _mutedTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.black),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(100, 44)),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor: WidgetStateProperty.all(
        const Color.fromRGBO(0, 0, 0, 1),
      ),
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade100,
    selectedItemColor: const Color.fromRGBO(91, 181, 92, 1),
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    showUnselectedLabels: true,
    showSelectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // ListTile theme
  listTileTheme: const ListTileThemeData(
    // tileColor: _backgroundColor,
    iconColor: _textColor,
    textColor: _textColor,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _textColor,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: _mutedTextColor,
    ),
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: _backgroundColor,
    surfaceTintColor: _backgroundColor,
    elevation: 0,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(
      borderRadius: _borderRadius,
      side: const BorderSide(color: _borderColor),
    ),
  ),

  // AppBar theme
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFF5F5F5),
    foregroundColor: _textColor,
    surfaceTintColor: _backgroundColor,
    shape: const Border(
      bottom: BorderSide(
        color: _borderColor,
        width: 0,
      ),
    ),
    elevation: 0,
    titleTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _textColor,
    ),
    iconTheme: const IconThemeData(color: _textColor),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: kIsWeb
          ? Brightness.light
          : (defaultTargetPlatform == TargetPlatform.android)
              ? Brightness.light
              : Brightness.dark,
      statusBarBrightness: kIsWeb
          ? Brightness.light
          : (defaultTargetPlatform == TargetPlatform.android)
              ? Brightness.light
              : Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.grey.shade100,
      systemNavigationBarColor: Colors.grey.shade100,
    ),
  ),
  dividerTheme: DividerThemeData(color: Colors.grey.shade200),
  drawerTheme: const DrawerThemeData(
    elevation: 0,
    backgroundColor: Colors.white,
    scrimColor: Colors.black12,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: _backgroundColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: _dialogBorderRadius,
      side: const BorderSide(color: _borderColor),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.black,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.black.withValues(alpha: 0.4),
    ),
    dividerColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(_backgroundColor),
      backgroundColor: WidgetStateProperty.all(_primaryColor),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: _borderRadius),
      ),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colors.black,
    inactiveTrackColor: Colors.grey.shade300,
    thumbColor: Colors.black,
    overlayColor: Colors.black.withValues(alpha: 0.4),
    valueIndicatorColor: Colors.black,
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackColor: WidgetStateProperty.all(Colors.grey.shade500),
    overlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.4)),
    splashRadius: 24,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.black,
    ),
    labelMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.black,
    ),
    displayLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.black,
    ),
    displaySmall: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.black,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.black,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.black,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.black,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      color: Colors.black,
    ),
  ),
);
