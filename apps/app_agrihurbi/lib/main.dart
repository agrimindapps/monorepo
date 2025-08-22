import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Core
import 'package:app_agrihurbi/core/di/injection_container.dart' as di;
import 'package:app_agrihurbi/core/router/app_router.dart';
import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/constants/app_constants.dart';

// Controllers
import 'package:app_agrihurbi/features/auth/presentation/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependencies (includes Hive from core package)
  await di.initDependencies();
  
  // Initialize Controllers
  _initControllers();
  
  runApp(const AgriHurbiApp());
}

/// Initialize GetX controllers
void _initControllers() {
  Get.put<AuthController>(di.sl<AuthController>());
}

class AgriHurbiApp extends StatelessWidget {
  const AgriHurbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Navigation
      initialRoute: AppRouter.initialRoute,
      getPages: AppRouter.routes,
      
      // Default transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      
      // Localization (can be added later)
      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('en', 'US'),
      
      // Builder for global widgets
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Disable font scaling
          ),
          child: child!,
        );
      },
      
      // Error handling
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const UnknownRoutePage(),
      ),
    );
  }
}

/// Page shown when navigating to unknown route
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.offAllNamed('/home'),
        icon: const Icon(Icons.home),
        label: const Text('Ir para Home'),
      ),
    );
  }
}
