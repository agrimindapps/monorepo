import 'package:app_agrihurbi/features/auth/presentation/pages/login_page.dart';
import 'package:app_agrihurbi/features/auth/presentation/pages/register_page.dart';
import 'package:app_agrihurbi/features/calculators/presentation/pages/calculator_detail_page.dart';
import 'package:app_agrihurbi/features/calculators/presentation/pages/calculators_list_page.dart';
import 'package:app_agrihurbi/features/home/presentation/pages/home_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/bovine_detail_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/bovine_form_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/bovines_list_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/equine_detail_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/equine_form_page.dart';
import 'package:app_agrihurbi/features/livestock/presentation/pages/livestock_search_page.dart';
import 'package:app_agrihurbi/features/markets/presentation/pages/market_detail_page.dart';
import 'package:app_agrihurbi/features/markets/presentation/pages/markets_list_page.dart';
import 'package:app_agrihurbi/features/news/presentation/pages/news_list_page.dart';
import 'package:app_agrihurbi/features/settings/presentation/pages/settings_page.dart';
import 'package:app_agrihurbi/features/weather/presentation/pages/weather_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Application router configuration using GoRouter
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          // Livestock routes - Migrated to Provider + Clean Architecture
          GoRoute(
            path: 'livestock',
            name: 'livestock',
            builder: (context, state) => const BovinesListPage(),
            routes: [
              // Bovines routes
              GoRoute(
                path: 'bovines',
                name: 'bovines-list',
                builder: (context, state) => const BovinesListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'bovines-add',
                    builder: (context, state) => const BovineFormPage(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'bovines-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BovineFormPage(bovineId: id);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    name: 'bovines-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BovineDetailPage(bovineId: id);
                    },
                  ),
                ],
              ),
              
              // Equines routes
              GoRoute(
                path: 'equines',
                name: 'equines-list',
                builder: (context, state) => const EquinesListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'equines-add',
                    builder: (context, state) => const EquineFormPage(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'equines-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EquineFormPage(equineId: id);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    name: 'equines-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EquineDetailPage(equineId: id);
                    },
                  ),
                ],
              ),
              
              // Search page
              GoRoute(
                path: 'search',
                name: 'livestock-search',
                builder: (context, state) => const LivestockSearchPage(),
              ),
              
              // Legacy routes for backward compatibility
              GoRoute(
                path: 'add',
                name: 'add-livestock',
                builder: (context, state) => const BovineFormPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-livestock',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BovineFormPage(bovineId: id);
                },
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'livestock-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BovineDetailPage(bovineId: id);
                },
              ),
            ],
          ),
          
          // Calculator Routes - Migrated to Provider + Clean Architecture
          GoRoute(
            path: 'calculators',
            name: 'calculators',
            builder: (context, state) => const CalculatorsListPage(),
            routes: [
              // General calculator detail route
              GoRoute(
                path: 'detail/:id',
                name: 'calculator-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CalculatorDetailPage(calculatorId: id);
                },
              ),
              
              // Irrigation Calculator Routes
              GoRoute(
                path: 'irrigation/:id',
                name: 'irrigation-calculator',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CalculatorDetailPage(calculatorId: id);
                },
              ),
              
              // Nutrition Calculator Routes
              GoRoute(
                path: 'nutrition',
                name: 'nutrition-calculators',
                builder: (context, state) => const CalculatorsListPage(category: 'nutrition'),
                routes: [
                  GoRoute(
                    path: 'npk',
                    name: 'npk-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'npk_calculator'),
                  ),
                  GoRoute(
                    path: 'soil-ph',
                    name: 'soil-ph-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'soil_ph_calculator'),
                  ),
                  GoRoute(
                    path: 'fertilizer-dosing',
                    name: 'fertilizer-dosing-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'fertilizer_dosing_calculator'),
                  ),
                  GoRoute(
                    path: 'compost',
                    name: 'compost-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'compost_calculator'),
                  ),
                  GoRoute(
                    path: 'organic-fertilizer',
                    name: 'organic-fertilizer-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'organic_fertilizer_calculator'),
                  ),
                ],
              ),
              
              // Livestock Calculator Routes
              GoRoute(
                path: 'livestock',
                name: 'livestock-calculators',
                builder: (context, state) => const CalculatorsListPage(category: 'livestock'),
                routes: [
                  GoRoute(
                    path: 'feed',
                    name: 'feed-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'feed_calculator'),
                  ),
                  GoRoute(
                    path: 'breeding-cycle',
                    name: 'breeding-cycle-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'breeding_cycle_calculator'),
                  ),
                  GoRoute(
                    path: 'grazing',
                    name: 'grazing-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'grazing_calculator'),
                  ),
                  GoRoute(
                    path: 'weight-gain',
                    name: 'weight-gain-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'weight_gain_calculator'),
                  ),
                ],
              ),
              
              // Crop Calculator Routes  
              GoRoute(
                path: 'crops',
                name: 'crop-calculators',
                builder: (context, state) => const CalculatorsListPage(category: 'crops'),
                routes: [
                  GoRoute(
                    path: 'planting-density',
                    name: 'planting-density-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'planting_density_calculator'),
                  ),
                  GoRoute(
                    path: 'harvest-timing',
                    name: 'harvest-timing-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'harvest_timing_calculator'),
                  ),
                  GoRoute(
                    path: 'seed-rate',
                    name: 'seed-rate-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'seed_rate_calculator'),
                  ),
                  GoRoute(
                    path: 'yield-prediction',
                    name: 'yield-prediction-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'yield_prediction_calculator'),
                  ),
                ],
              ),
              
              // Soil Calculator Routes
              GoRoute(
                path: 'soil',
                name: 'soil-calculators',
                builder: (context, state) => const CalculatorsListPage(category: 'soil'),
                routes: [
                  GoRoute(
                    path: 'composition',
                    name: 'soil-composition-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'soil_composition_calculator'),
                  ),
                  GoRoute(
                    path: 'drainage',
                    name: 'drainage-calculator',
                    builder: (context, state) => const CalculatorDetailPage(calculatorId: 'drainage_calculator'),
                  ),
                ],
              ),
              
              // Search and favorites
              GoRoute(
                path: 'search',
                name: 'calculators-search',
                builder: (context, state) => const CalculatorsSearchPage(),
              ),
              GoRoute(
                path: 'favorites',
                name: 'calculators-favorites',
                builder: (context, state) => const CalculatorsFavoritesPage(),
              ),
            ],
          ),
          
          // Weather Routes - Migrated to Provider + Clean Architecture
          GoRoute(
            path: 'weather',
            name: 'weather',
            builder: (context, state) => const WeatherDashboardPage(),
            routes: [
              GoRoute(
                path: 'dashboard',
                name: 'weather-dashboard',
                builder: (context, state) => const WeatherDashboardPage(),
              ),
              GoRoute(
                path: 'measurements',
                name: 'weather-measurements',
                builder: (context, state) => const WeatherMeasurementsPage(),
              ),
              GoRoute(
                path: 'rain-gauges',
                name: 'weather-rain-gauges',
                builder: (context, state) => const RainGaugesPage(),
              ),
              GoRoute(
                path: 'statistics',
                name: 'weather-statistics',
                builder: (context, state) => const WeatherStatisticsPage(),
              ),
            ],
          ),
          
          // News Routes - Migrated to Provider + Clean Architecture
          GoRoute(
            path: 'news',
            name: 'news',
            builder: (context, state) => const NewsListPage(),
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'news-article',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return NewsDetailPage(id: id);
                },
              ),
              GoRoute(
                path: 'search',
                name: 'news-search',
                builder: (context, state) => const NewsSearchPage(),
              ),
              GoRoute(
                path: 'favorites',
                name: 'news-favorites',
                builder: (context, state) => const NewsFavoritesPage(),
              ),
              GoRoute(
                path: 'feeds',
                name: 'news-feeds',
                builder: (context, state) => const RSSFeedsPage(),
              ),
            ],
          ),
          
          // Market Routes
          GoRoute(
            path: 'markets',
            name: 'markets',
            builder: (context, state) => const MarketsListPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'market-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MarketDetailPage(marketId: id);
                },
              ),
            ],
          ),
          
          // Settings Routes - Migrated to Provider + Clean Architecture  
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'backup',
                name: 'settings-backup',
                builder: (context, state) => const BackupPage(),
              ),
              GoRoute(
                path: 'about',
                name: 'settings-about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
          
          // Subscription Routes  
          GoRoute(
            path: 'subscription',
            name: 'subscription',
            builder: (context, state) => const SubscriptionPage(),
            routes: [
              GoRoute(
                path: 'plans',
                name: 'subscription-plans',
                builder: (context, state) => const SubscriptionPlansPage(),
              ),
              GoRoute(
                path: 'payment',
                name: 'subscription-payment',
                builder: (context, state) => const PaymentMethodsPage(),
              ),
            ],
          ),
          
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
  
  static GoRouter get router => _router;
}

/// Navigation helper methods using GoRouter
class AppNavigation {
  // Private constructor to prevent instantiation
  AppNavigation._();
  /// Navigate to login page
  static void toLogin(BuildContext context) => context.go('/login');
  
  /// Navigate to home page
  static void toHome(BuildContext context) => context.go('/home');
  
  /// Navigate to register page
  static void toRegister(BuildContext context) => context.push('/register');
  
  /// Navigate to livestock list
  static void toLivestock(BuildContext context) => context.push('/home/livestock');
  
  /// Navigate to livestock detail
  static void toLivestockDetail(BuildContext context, String id) => 
      context.push('/home/livestock/detail/$id');
  
  /// Navigate to add livestock
  static void toAddLivestock(BuildContext context) => context.push('/home/livestock/add');
  
  /// Navigate to edit livestock
  static void toEditLivestock(BuildContext context, String id) => 
      context.push('/home/livestock/edit/$id');
  
  /// Navigate to calculators
  static void toCalculators(BuildContext context) => context.push('/home/calculators');
  
  /// Navigate to calculator detail
  static void toCalculatorDetail(BuildContext context, String id) => 
      context.push('/home/calculators/detail/$id');
  
  /// Navigate to calculators by category
  static void toCalculatorsByCategory(BuildContext context, String category) => 
      context.push('/home/calculators/$category');
  
  /// Navigate to specific calculators
  static void toNPKCalculator(BuildContext context) => 
      context.push('/home/calculators/nutrition/npk');
  
  static void toSoilPHCalculator(BuildContext context) => 
      context.push('/home/calculators/nutrition/soil-ph');
  
  static void toFertilizerDosingCalculator(BuildContext context) => 
      context.push('/home/calculators/nutrition/fertilizer-dosing');
  
  static void toCompostCalculator(BuildContext context) => 
      context.push('/home/calculators/nutrition/compost');
  
  static void toOrganicFertilizerCalculator(BuildContext context) => 
      context.push('/home/calculators/nutrition/organic-fertilizer');
  
  static void toFeedCalculator(BuildContext context) => 
      context.push('/home/calculators/livestock/feed');
  
  static void toBreedingCycleCalculator(BuildContext context) => 
      context.push('/home/calculators/livestock/breeding-cycle');
  
  static void toGrazingCalculator(BuildContext context) => 
      context.push('/home/calculators/livestock/grazing');
  
  static void toWeightGainCalculator(BuildContext context) => 
      context.push('/home/calculators/livestock/weight-gain');
  
  static void toPlantingDensityCalculator(BuildContext context) => 
      context.push('/home/calculators/crops/planting-density');
  
  static void toHarvestTimingCalculator(BuildContext context) => 
      context.push('/home/calculators/crops/harvest-timing');
  
  static void toSeedRateCalculator(BuildContext context) => 
      context.push('/home/calculators/crops/seed-rate');
  
  static void toYieldPredictionCalculator(BuildContext context) => 
      context.push('/home/calculators/crops/yield-prediction');
  
  static void toSoilCompositionCalculator(BuildContext context) => 
      context.push('/home/calculators/soil/composition');
  
  static void toDrainageCalculator(BuildContext context) => 
      context.push('/home/calculators/soil/drainage');
  
  /// Navigate to calculator utilities
  static void toCalculatorsSearch(BuildContext context) => 
      context.push('/home/calculators/search');
  
  static void toCalculatorsFavorites(BuildContext context) => 
      context.push('/home/calculators/favorites');
  
  /// Navigate to weather
  static void toWeather(BuildContext context) => context.push('/home/weather');
  
  /// Navigate to weather detail
  static void toWeatherDetail(BuildContext context) => context.push('/home/weather/detail');
  
  /// Navigate to news
  static void toNews(BuildContext context) => context.push('/home/news');
  
  /// Navigate to news detail
  static void toNewsDetail(BuildContext context, String id) => 
      context.push('/home/news/detail/$id');
  
  /// Navigate to markets
  static void toMarkets(BuildContext context) => context.push('/home/markets');
  
  /// Navigate to market detail
  static void toMarketDetail(BuildContext context, String id) => 
      context.push('/home/markets/detail/$id');
  
  /// Navigate to settings
  static void toSettings(BuildContext context) => context.push('/home/settings');
  
  /// Navigate to profile
  static void toProfile(BuildContext context) => context.push('/home/profile');
  
  /// Go back
  static void back(BuildContext context) => context.pop();
  
  /// Show snackbar
  static void showSnackbar(BuildContext context, String title, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Placeholder for EquinesListPage - TODO: Implementar
class EquinesListPage extends StatelessWidget {
  const EquinesListPage({super.key});
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Equinos'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 64),
          SizedBox(height: 16),
          Text('Lista de Equinos'),
          SizedBox(height: 8),
          Text('Em desenvolvimento...'),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.push('/home/livestock/equines/add'),
      child: const Icon(Icons.add),
    ),
  );
}


// Weather Pages Placeholders
class WeatherMeasurementsPage extends StatelessWidget {
  const WeatherMeasurementsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Medições Meteorológicas')),
    body: const Center(child: Text('Weather Measurements Page - Em desenvolvimento')),
  );
}

class RainGaugesPage extends StatelessWidget {
  const RainGaugesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pluviômetros')),
    body: const Center(child: Text('Rain Gauges Page - Em desenvolvimento')),
  );
}

class WeatherStatisticsPage extends StatelessWidget {
  const WeatherStatisticsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Estatísticas Meteorológicas')),
    body: const Center(child: Text('Weather Statistics Page - Em desenvolvimento')),
  );
}

class NewsDetailPage extends StatelessWidget {
  final String id;
  const NewsDetailPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes da Notícia')),
    body: Center(child: Text('News Detail Page - ID: $id')),
  );
}


// Settings and News pages are now imported from their respective feature modules

// News Pages Placeholders
class NewsSearchPage extends StatelessWidget {
  const NewsSearchPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Buscar Notícias')),
    body: const Center(child: Text('News Search Page - Em desenvolvimento')),
  );
}

class NewsFavoritesPage extends StatelessWidget {
  const NewsFavoritesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notícias Favoritas')),
    body: const Center(child: Text('News Favorites Page - Em desenvolvimento')),
  );
}

class RSSFeedsPage extends StatelessWidget {
  const RSSFeedsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gerenciar RSS Feeds')),
    body: const Center(child: Text('RSS Feeds Page - Em desenvolvimento')),
  );
}

// Settings Pages Placeholders
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Backup e Recuperação')),
    body: const Center(child: Text('Backup Page - Em desenvolvimento')),
  );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sobre')),
    body: const Center(child: Text('About Page - Em desenvolvimento')),
  );
}

// Subscription Pages Placeholders
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Assinatura Premium')),
    body: const Center(child: Text('Subscription Page - Em desenvolvimento')),
  );
}

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Planos de Assinatura')),
    body: const Center(child: Text('Subscription Plans Page - Em desenvolvimento')),
  );
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Métodos de Pagamento')),
    body: const Center(child: Text('Payment Methods Page - Em desenvolvimento')),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Profile Page')),
  );
}

/// Placeholder for Calculator Search Page
class CalculatorsSearchPage extends StatelessWidget {
  const CalculatorsSearchPage({super.key});
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Buscar Calculadoras'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64),
          SizedBox(height: 16),
          Text('Busca de Calculadoras'),
          SizedBox(height: 8),
          Text('Implementação em desenvolvimento...'),
        ],
      ),
    ),
  );
}

/// Placeholder for Calculator Favorites Page
class CalculatorsFavoritesPage extends StatelessWidget {
  const CalculatorsFavoritesPage({super.key});
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calculadoras Favoritas'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64),
          SizedBox(height: 16),
          Text('Calculadoras Favoritas'),
          SizedBox(height: 8),
          Text('Implementação em desenvolvimento...'),
        ],
      ),
    ),
  );
}