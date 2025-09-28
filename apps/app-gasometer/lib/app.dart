import 'package:core/core.dart' hide AuthProvider;
import 'package:flutter/material.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/data_export/presentation/providers/data_export_provider.dart';
import 'features/device_management/presentation/providers/vehicle_device_provider.dart';
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/fuel/presentation/providers/fuel_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/odometer/presentation/providers/odometer_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/vehicles/presentation/providers/vehicles_provider.dart';

class GasOMeterApp extends ConsumerWidget {
  const GasOMeterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    // Bridge Providers: fornece providers do GetIt para widgets que usam Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => di.getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<VehiclesProvider>(
          create: (_) => di.getIt<VehiclesProvider>(),
        ),
        ChangeNotifierProvider<FuelProvider>(
          create: (_) => di.getIt<FuelProvider>(),
        ),
        ChangeNotifierProvider<MaintenanceProvider>(
          create: (_) => di.getIt<MaintenanceProvider>(),
        ),
        ChangeNotifierProvider<PremiumProvider>(
          create: (_) => di.getIt<PremiumProvider>(),
        ),
        ChangeNotifierProvider<ReportsProvider>(
          create: (_) => di.getIt<ReportsProvider>(),
        ),
        ChangeNotifierProvider<ExpensesProvider>(
          create: (_) => di.getIt<ExpensesProvider>(),
        ),
        ChangeNotifierProvider<VehicleDeviceProvider>(
          create: (_) => VehicleDeviceProvider(
            connectivityService: di.getIt<ConnectivityService>(),
          ),
        ),
        ChangeNotifierProvider<OdometerProvider>(
          create: (_) => di.getIt<OdometerProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) {
            final themeProvider = ThemeProvider();
            themeProvider.initialize();
            return themeProvider;
          },
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            preferences: di.getIt<SharedPreferences>(),
            appRatingRepository: di.getIt<IAppRatingRepository>(),
          ),
        ),
        ChangeNotifierProvider<DataExportProvider>(
          create: (_) => di.getIt<DataExportProvider>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'GasOMeter - Controle de Veículos',
        theme: GasometerTheme.lightTheme,
        darkTheme: GasometerTheme.darkTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}