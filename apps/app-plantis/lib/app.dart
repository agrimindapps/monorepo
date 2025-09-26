import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart' as provider;
import 'package:core/core.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'core/riverpod_providers/theme_providers.dart';
// Auth provider migrated to Riverpod - auth_providers.dart
import 'features/device_management/presentation/providers/device_management_provider.dart';
import 'features/plants/presentation/providers/plant_task_provider.dart';
import 'features/plants/presentation/providers/plants_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/tasks/presentation/providers/tasks_provider.dart';
import 'features/license/providers/license_provider.dart';
import 'shared/widgets/desktop_keyboard_shortcuts.dart';

class PlantisApp extends ConsumerWidget {
  const PlantisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, we'll keep the Provider infrastructure temporarily
    // This will be migrated in subsequent phases
    return provider.MultiProvider(
      providers: [
        // Auth migrated to Riverpod - using authProvider directly
        provider.ChangeNotifierProvider(create: (_) => di.sl<DeviceManagementProvider>()),
        provider.ChangeNotifierProvider(create: (_) => di.sl<PlantsProvider>()),
        provider.ChangeNotifierProvider(create: (_) => di.sl<PlantTaskProvider>()),
        provider.ChangeNotifierProvider(create: (_) => di.sl<TasksProvider>()),
        provider.ChangeNotifierProvider(create: (_) => di.sl<PremiumProvider>()),
        provider.ChangeNotifierProvider(
          create: (_) {
            final licenseService = LicenseService(LicenseLocalStorage());
            return LicenseProvider(licenseService)..initialize();
          },
        ),
        provider.ChangeNotifierProvider<ChangeNotifier>(
          create: (_) => di.sl<ChangeNotifier>(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => di.sl<ThemeProvider>(),
        ),
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);

        // Using both Provider (legacy) and Riverpod (new) for theme during migration
        // This demonstrates both approaches working side by side
        return provider.Consumer<ThemeProvider>(
          builder: (context, legacyThemeProvider, _) {
            // Also consume the new Riverpod theme provider
            final riverpodThemeMode = ref.watch(themeProvider);

            // During migration, we can use either provider
            // For now, keeping legacy for stability, but Riverpod is ready
            final currentThemeMode = legacyThemeProvider.isInitialized
                ? legacyThemeProvider.themeMode
                : riverpodThemeMode;

            return DesktopKeyboardShortcuts(
              child: MaterialApp.router(
                title: 'Plantis - Cuidado de Plantas',
                theme: PlantisTheme.lightTheme,
                darkTheme: PlantisTheme.darkTheme,
                themeMode: currentThemeMode,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('pt', 'BR'),
                  Locale('en', 'US'),
                ],
                locale: const Locale('pt', 'BR'),
              ),
            );
          },
        );
      },
    );
  }
}
