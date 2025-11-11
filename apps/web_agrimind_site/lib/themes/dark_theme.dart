import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  primaryColor: const Color.fromRGBO(23, 25, 27, 1),
  primarySwatch: Colors.green,
  highlightColor: Colors.green,
  fontFamily: 'poppins',
  scaffoldBackgroundColor: const Color.fromRGBO(23, 25, 27, 1),
  cardColor: const Color.fromRGBO(38, 41, 46, 1),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color.fromRGBO(63, 66, 71, 1),
      ),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(
        const Color.fromRGBO(63, 66, 71, 1),
      ),
      shadowColor: WidgetStateProperty.all(Colors.grey.shade900),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
    fillColor: Colors.black45,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.transparent, width: 0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.transparent, width: 0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.transparent, width: 0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.green),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color.fromRGBO(63, 66, 71, 1),
      ),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(
        const Color.fromRGBO(63, 66, 71, 0.5),
      ),
      shadowColor: WidgetStateProperty.all(Colors.grey.shade900),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color.fromRGBO(38, 41, 46, 1),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey.shade700,
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
    tileColor: Color.fromRGBO(38, 41, 46, 1),
    selectedTileColor: Colors.white,
    iconColor: Colors.white,
    textColor: Color.fromRGBO(232, 232, 232, 1),
    selectedColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Color.fromRGBO(232, 232, 232, 1),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
  dividerTheme: const DividerThemeData(color: Color.fromRGBO(45, 48, 53, 1)),
  cardTheme: CardThemeData(
    color: const Color.fromRGBO(38, 41, 46, 1),
    // shadowColor: Colors.grey.shade900,
    // surfaceTintColor: Colors.grey.shade800,
    elevation: 4,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromRGBO(
      23,
      25,
      27,
      1,
    ), // Fundo escuro consistente
    foregroundColor: Colors.white, // Texto claro para legibilidade
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white, // Ícones claros para contraste
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: const Color.fromRGBO(
        29,
        29,
        37,
        1,
      ), // Barra de status escura consistente
      statusBarIconBrightness: GetPlatform.isWeb
          ? Brightness.light
          : GetPlatform.isAndroid
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: GetPlatform.isWeb
          ? Brightness.light
          : GetPlatform.isAndroid
          ? Brightness.light
          : Brightness.dark,
      // Aplique uma systemNavigationBarColor transparente para suporte ao modo escuro
      systemNavigationBarColor: const Color.fromRGBO(38, 41, 46, 1),
      systemNavigationBarDividerColor:
          Colors.transparent, // Divisor transparente para consistência
      systemNavigationBarIconBrightness:
          Brightness.light, // Ícones claros para melhor visibilidade
    ),
  ),
  drawerTheme: const DrawerThemeData(
    elevation: 0,
    backgroundColor: Color.fromRGBO(44, 44, 56, 1),
  ),
  dialogBackgroundColor: const Color.fromRGBO(38, 41, 46, 1),
  dialogTheme: const DialogThemeData(
    surfaceTintColor: Color.fromRGBO(38, 41, 46, 1),
    elevation: 4,
  ),
  tabBarTheme: TabBarThemeData(
    overlayColor: WidgetStateProperty.all(const Color.fromRGBO(63, 66, 71, 1)),
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.green,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.green.withOpacity(0.4),
    ),
    dividerColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color.fromRGBO(23, 25, 27, 1),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Color.fromRGBO(23, 25, 27, 1),
  ),
  primaryTextTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w400,
    ),
  ),
);
