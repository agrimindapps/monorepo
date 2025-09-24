import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as app_auth;
import 'features/device_management/presentation/providers/device_management_provider.dart';
import 'features/plants/presentation/providers/plant_task_provider.dart';
import 'features/plants/presentation/providers/plants_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/tasks/presentation/providers/tasks_provider.dart';
import 'features/license/providers/license_provider.dart';
import 'shared/widgets/desktop_keyboard_shortcuts.dart';

class PlantisApp extends StatelessWidget {
  const PlantisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<app_auth.AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<DeviceManagementProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PlantsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PlantTaskProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TasksProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PremiumProvider>()),
        ChangeNotifierProvider(
          create: (_) {
            final licenseService = LicenseService(LicenseLocalStorage());
            return LicenseProvider(licenseService)..initialize();
          },
        ),
        ChangeNotifierProvider<ChangeNotifier>(
          create: (_) => di.sl<ChangeNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<ThemeProvider>(),
        ),
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return DesktopKeyboardShortcuts(
              child: MaterialApp.router(
                title: 'Plantis - Cuidado de Plantas',
                theme: PlantisTheme.lightTheme,
                darkTheme: PlantisTheme.darkTheme,
                themeMode: themeProvider.themeMode,
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
