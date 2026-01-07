
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Color constants
const _backgroundColor = Color(0xFF09090B);
const _surfaceColor = Color(0xFF18181B);
const _borderColor = Color(0xFF27272A);
const _textColor = Color(0xFFFAFAFA);
const _mutedTextColor = Color(0xFF71717A);
const _primaryColor = Color(0xFF94A3B8); // Changed to a violet shade
// const _primaryHoverColor = Color(0xFF6D28D9); // Added hover state
const _focusedBorderColor = Color(0xFF71717A); // Changed to match primary
// const _accentColor = Color(0xFF8B5CF6); // Added for accents
// Border Radius
final _borderRadius = BorderRadius.circular(6);
final _dialogBorderRadius = BorderRadius.circular(8);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'poppins',
  primaryColor: _primaryColor,
  scaffoldBackgroundColor: _backgroundColor,
  cardColor: _surfaceColor,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: _primaryColor,
    selectionColor: Color(0x4094A3B8), // _primaryColor com opacidade
    selectionHandleColor: _primaryColor,
  ),

  // Icon
  iconTheme: const IconThemeData(color: _textColor),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    filled: true,
    fillColor: Colors.grey[900],
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

  // Card theme
  cardTheme: CardThemeData(
    color: _surfaceColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: _borderRadius,
      side: const BorderSide(color: _borderColor),
    ),
    margin: EdgeInsets.zero,
  ),

  // ListTile theme
  listTileTheme: const ListTileThemeData(
    tileColor: _surfaceColor,
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

  // AppBar theme
  appBarTheme: AppBarTheme(
    backgroundColor: _surfaceColor,
    foregroundColor: _textColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _textColor,
    ),
    iconTheme: const IconThemeData(color: _textColor),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: kIsWeb
          ? Brightness.light
          : (defaultTargetPlatform == TargetPlatform.android)
              ? Brightness.light
              : Brightness.dark,
      systemNavigationBarColor: _backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  ),

  // Button themes
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      backgroundColor: WidgetStateProperty.all(_surfaceColor),
      foregroundColor: WidgetStateProperty.all(_textColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _borderColor),
        ),
      ),
    ),
  ),

  // Dropdown Menu Themes
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      fillColor: _surfaceColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: _borderColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: _borderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: _focusedBorderColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(
        color: _mutedTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(_surfaceColor),
      surfaceTintColor: WidgetStateProperty.all(_surfaceColor),
      shadowColor: WidgetStateProperty.all(Colors.black12),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _borderColor),
        ),
      ),
    ),
    textStyle: const TextStyle(
      color: _textColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Bottom Navigation Bar theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _surfaceColor,
    selectedItemColor: _primaryColor,
    unselectedItemColor: _mutedTextColor,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),

  // Dialog theme
  dialogTheme: DialogThemeData(
    backgroundColor: _surfaceColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: _dialogBorderRadius,
      side: const BorderSide(color: _borderColor),
    ),
  ),

  // Floating Action Button theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _surfaceColor,
    foregroundColor: _primaryColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: _borderRadius,
      side: const BorderSide(color: _borderColor),
    ),
  ),

  // Divider theme
  dividerTheme: const DividerThemeData(
    color: _borderColor,
    thickness: 1,
  ),

  datePickerTheme: DatePickerThemeData(
    headerHeadlineStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: _textColor,
    ),
    dayStyle: const TextStyle(fontSize: 14),
    yearStyle: const TextStyle(
      fontSize: 14,
      color: _textColor,
    ),
    weekdayStyle: const TextStyle(fontSize: 12),
    todayForegroundColor: WidgetStateProperty.all(_textColor),
    backgroundColor: _surfaceColor,
    dayForegroundColor: WidgetStateProperty.all(_textColor),
    dayOverlayColor: WidgetStateProperty.all(_primaryColor.withValues(alpha: 0.2)),
    dayShape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: _borderRadius),
    ),
    surfaceTintColor: Colors.transparent,
    dayBackgroundColor: WidgetStateProperty.all(_surfaceColor),
    headerForegroundColor: _textColor,
    headerBackgroundColor: _surfaceColor,
    headerHelpStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: _textColor,
    ),
    todayBackgroundColor: WidgetStateProperty.all(
      _primaryColor.withValues(alpha: 0.4),
    ),

    elevation: 0,
    // iconColor: _textColor,
    // weekdayForegroundColor: WidgetStateProperty.all(_textColor),
  ),

  // Add TimePicker theme
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: _surfaceColor,
    hourMinuteColor: _backgroundColor,
    hourMinuteTextColor: _textColor,
    dialBackgroundColor: _primaryColor,
    elevation: 0,
  ),

  // Add Progress Indicator theme
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: _primaryColor),

  // Add Outlined Button theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(100, 44)),
      backgroundColor: WidgetStateProperty.all(_surfaceColor),
      foregroundColor: WidgetStateProperty.all(_textColor),
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _textColor,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: _borderRadius,
          side: const BorderSide(color: _borderColor),
        ),
      ),
    ),
  ),

  // Add Drawer theme
  drawerTheme: const DrawerThemeData(
    elevation: 0,
    backgroundColor: _surfaceColor,
    scrimColor: Colors.black45,
  ),

  // Add Tab Bar theme
  tabBarTheme: TabBarThemeData(
    labelColor: _textColor,
    unselectedLabelColor: _mutedTextColor,
    indicatorColor: _primaryColor,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    indicator: BoxDecoration(
      borderRadius: _borderRadius,
      color: _primaryColor.withValues(alpha: 0.4),
    ),
    dividerColor: Colors.transparent,
  ),

  // Add Slider theme
  sliderTheme: SliderThemeData(
    activeTrackColor: _primaryColor,
    inactiveTrackColor: _borderColor,
    thumbColor: _primaryColor,
    overlayColor: _primaryColor.withValues(alpha: 0.4),
    valueIndicatorColor: _primaryColor,
    valueIndicatorTextStyle: const TextStyle(
      color: _backgroundColor,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
  ),

  // Add Switch theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(_textColor),
    trackColor: WidgetStateProperty.all(_borderColor),
    overlayColor: WidgetStateProperty.all(_primaryColor.withValues(alpha: 0.4)),
    splashRadius: 24,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  // Update Text theme with all variants
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: _textColor,
    ),
    displayMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: _textColor,
    ),
    displaySmall: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: _textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: _textColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: _textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: _textColor,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: _textColor,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: _textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: _textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: _textColor,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: _textColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: _textColor,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      color: _textColor,
    ),
  ),
);
