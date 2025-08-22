import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_agrihurbi/core/constants/app_constants.dart';
import 'package:app_agrihurbi/features/auth/presentation/pages/login_page.dart';
import 'package:app_agrihurbi/features/auth/presentation/pages/register_page.dart';
import 'package:app_agrihurbi/features/home/presentation/pages/home_page.dart';

/// Application router configuration using GetX
class AppRouter {
  /// Initial route for the application
  static const String initialRoute = RouteNames.login;
  
  /// List of all application routes
  static List<GetPage> get routes => [
    // Authentication Routes
    GetPage(
      name: RouteNames.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Main App Routes
    GetPage(
      name: RouteNames.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Livestock Routes
    GetPage(
      name: RouteNames.livestock,
      page: () => const LivestockListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.livestockDetail,
      page: () => const LivestockDetailPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.addLivestock,
      page: () => const AddLivestockPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.editLivestock,
      page: () => const EditLivestockPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Calculator Routes
    GetPage(
      name: RouteNames.calculators,
      page: () => const CalculatorsListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.calculatorDetail,
      page: () => const CalculatorDetailPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Weather Routes
    GetPage(
      name: RouteNames.weather,
      page: () => const WeatherPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.weatherDetail,
      page: () => const WeatherDetailPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // News Routes
    GetPage(
      name: RouteNames.news,
      page: () => const NewsListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.newsDetail,
      page: () => const NewsDetailPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Market Routes
    GetPage(
      name: RouteNames.markets,
      page: () => const MarketsListPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.marketDetail,
      page: () => const MarketDetailPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Settings Routes
    GetPage(
      name: RouteNames.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: RouteNames.profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

/// Navigation helper methods
class AppNavigation {
  /// Navigate to login page
  static void toLogin() => Get.offAllNamed(RouteNames.login);
  
  /// Navigate to home page
  static void toHome() => Get.offAllNamed(RouteNames.home);
  
  /// Navigate to register page
  static void toRegister() => Get.toNamed(RouteNames.register);
  
  /// Navigate to livestock list
  static void toLivestock() => Get.toNamed(RouteNames.livestock);
  
  /// Navigate to livestock detail
  static void toLivestockDetail(String id) => 
      Get.toNamed(RouteNames.livestockDetail, arguments: {'id': id});
  
  /// Navigate to add livestock
  static void toAddLivestock() => Get.toNamed(RouteNames.addLivestock);
  
  /// Navigate to edit livestock
  static void toEditLivestock(String id) => 
      Get.toNamed(RouteNames.editLivestock, arguments: {'id': id});
  
  /// Navigate to calculators
  static void toCalculators() => Get.toNamed(RouteNames.calculators);
  
  /// Navigate to calculator detail
  static void toCalculatorDetail(String type) => 
      Get.toNamed(RouteNames.calculatorDetail, arguments: {'type': type});
  
  /// Navigate to weather
  static void toWeather() => Get.toNamed(RouteNames.weather);
  
  /// Navigate to weather detail
  static void toWeatherDetail() => Get.toNamed(RouteNames.weatherDetail);
  
  /// Navigate to news
  static void toNews() => Get.toNamed(RouteNames.news);
  
  /// Navigate to news detail
  static void toNewsDetail(String id) => 
      Get.toNamed(RouteNames.newsDetail, arguments: {'id': id});
  
  /// Navigate to markets
  static void toMarkets() => Get.toNamed(RouteNames.markets);
  
  /// Navigate to market detail
  static void toMarketDetail(String id) => 
      Get.toNamed(RouteNames.marketDetail, arguments: {'id': id});
  
  /// Navigate to settings
  static void toSettings() => Get.toNamed(RouteNames.settings);
  
  /// Navigate to profile
  static void toProfile() => Get.toNamed(RouteNames.profile);
  
  /// Go back
  static void back() => Get.back();
  
  /// Close dialogs/bottomsheets
  static void closeDialog() => Get.back();
  
  /// Show snackbar
  static void showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 3),
    );
  }
}

// Placeholder pages that will be implemented later
class LivestockListPage extends StatelessWidget {
  const LivestockListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Livestock List Page')),
  );
}

class LivestockDetailPage extends StatelessWidget {
  const LivestockDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Livestock Detail Page')),
  );
}

class AddLivestockPage extends StatelessWidget {
  const AddLivestockPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Add Livestock Page')),
  );
}

class EditLivestockPage extends StatelessWidget {
  const EditLivestockPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Edit Livestock Page')),
  );
}

class CalculatorsListPage extends StatelessWidget {
  const CalculatorsListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Calculators List Page')),
  );
}

class CalculatorDetailPage extends StatelessWidget {
  const CalculatorDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Calculator Detail Page')),
  );
}

class WeatherPage extends StatelessWidget {
  const WeatherPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Weather Page')),
  );
}

class WeatherDetailPage extends StatelessWidget {
  const WeatherDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Weather Detail Page')),
  );
}

class NewsListPage extends StatelessWidget {
  const NewsListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('News List Page')),
  );
}

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('News Detail Page')),
  );
}

class MarketsListPage extends StatelessWidget {
  const MarketsListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Markets List Page')),
  );
}

class MarketDetailPage extends StatelessWidget {
  const MarketDetailPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Market Detail Page')),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Settings Page')),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Profile Page')),
  );
}