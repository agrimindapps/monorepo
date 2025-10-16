import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  primaryColor: Colors.green,
  primarySwatch: Colors.green,
  primaryColorLight: Colors.green,
  scaffoldBackgroundColor: Colors.grey.shade300,
  cardColor: Colors.white,
  highlightColor: Colors.green,
  textTheme: GoogleFonts.montserratTextTheme(),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor:
          WidgetStateProperty.all(const Color.fromRGBO(63, 66, 71, 1)),
      shadowColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
    fillColor: Colors.grey.shade100,
    filled: true,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0,
      ),
    ),
    hintStyle: const TextStyle(
      color: Colors.black54,
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.green),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      overlayColor:
          WidgetStateProperty.all(const Color.fromRGBO(63, 66, 71, 0.5)),
      shadowColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
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
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.white,
    selectedTileColor: Colors.green,
    iconColor: Colors.green,
    textColor: Colors.black87,
    selectedColor: Colors.green,
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 4,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: kIsWeb
          ? Brightness.light
          : Brightness.light,
      statusBarBrightness: kIsWeb
          ? Brightness.light
          : Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.grey.shade100,
      systemNavigationBarColor: Colors.grey.shade100,
    ),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade200,
  ),
  drawerTheme: const DrawerThemeData(
    elevation: 0,
    backgroundColor: Colors.white,
    scrimColor: Colors.black12,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    shadowColor: Colors.black,
    elevation: 4,
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.green,
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
      borderRadius: BorderRadius.circular(8.0),
      color: Color.fromRGBO(76, 175, 80, 0.4),
    ),
    dividerColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor:
          WidgetStateProperty.all(const Color.fromRGBO(63, 66, 71, 1)),
      shadowColor:
          WidgetStateProperty.all(const Color.fromRGBO(91, 181, 92, 1)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
);
