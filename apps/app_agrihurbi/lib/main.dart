import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'package:app_agrihurbi/core/di/injection_container.dart';
import 'package:app_agrihurbi/core/router/app_router.dart';
import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/constants/app_constants.dart';

// Providers
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_agrihurbi/features/livestock/presentation/providers/livestock_provider.dart';
import 'package:app_agrihurbi/features/calculators/presentation/providers/calculator_provider_simple.dart';

// Core Utils
import 'package:app_agrihurbi/core/utils/hive_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive with all adapters
    await HiveInitializer.initialize();
    
    // Configure Dependencies
    await configureDependencies();
    
    runApp(const AgriHurbiApp());
  } catch (e, stackTrace) {
    debugPrint('Erro na inicialização da aplicação: $e');
    debugPrint('StackTrace: $stackTrace');
    
    // Em caso de erro, ainda tenta executar a app
    runApp(const AgriHurbiApp());
  }
}

class AgriHurbiApp extends StatelessWidget {
  const AgriHurbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        
        // Livestock Provider
        ChangeNotifierProvider(create: (_) => getIt<LivestockProvider>()),
        
        // Calculator Provider
        ChangeNotifierProvider(create: (_) => getIt<CalculatorProvider>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Navigation
        routerConfig: AppRouter.router,
        
        // Localization (can be added later)
        locale: const Locale('pt', 'BR'),
        
        // Builder for global widgets
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Disable font scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }
}