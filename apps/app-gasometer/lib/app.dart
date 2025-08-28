import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'core/presentation/widgets/global_error_boundary.dart';
import 'core/router/app_router.dart';
import 'core/sync/presentation/providers/sync_status_provider.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as local;
import 'features/fuel/presentation/providers/fuel_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/odometer/presentation/providers/odometer_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/vehicles/presentation/providers/vehicles_provider.dart';

class GasOMeterApp extends StatelessWidget {
  const GasOMeterApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // LEVEL 1: Base providers (no dependencies)
        // Auth Provider - deve ser o primeiro (base dependency)
        ChangeNotifierProvider(
          create: (_) => sl<local.AuthProvider>(),
          lazy: true, // Changed to lazy to prevent startup deadlock
        ),
        
        // Theme Provider - independent
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        
        // Sync Status Provider - independent
        ChangeNotifierProvider(
          create: (_) => sl<SyncStatusProvider>(),
        ),
        
        // Premium Provider - independent 
        ChangeNotifierProvider(
          create: (_) => sl<PremiumProvider>(),
        ),
        
        // LEVEL 2: Domain providers (depend on Auth)
        // Vehicles Provider - depends on Auth for user context
        ChangeNotifierProvider(
          create: (_) {
            final vehiclesProvider = sl<VehiclesProvider>();
            // Initialize after the provider is fully created
            Future.microtask(() => vehiclesProvider.initialize());
            return vehiclesProvider;
          },
          lazy: true,
        ),
        
        // LEVEL 3: Feature providers (depend on domain providers)
        // Fuel Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => sl<FuelProvider>(),
          lazy: true,
        ),
        
        // Maintenance Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => sl<MaintenanceProvider>(),
          lazy: true,
        ),
        
        // Odometer Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => sl<OdometerProvider>(),
          lazy: true,
        ),
        
        // LEVEL 4: Analytics providers (depend on multiple feature providers)
        // Reports Provider - depends on multiple providers for comprehensive reporting
        ChangeNotifierProvider(
          create: (_) => sl<ReportsProvider>(),
          lazy: true,
        ),
      ],
        builder: (context, child) {
          final router = AppRouter.router(context);
          
          return GlobalErrorBoundary(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return MaterialApp.router(
                  title: 'GasOMeter - Controle de Veículos',
                  theme: GasometerTheme.lightTheme,
                  darkTheme: GasometerTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  routerConfig: router,
                  debugShowCheckedModeBanner: false,
                );
              },
            ),
          );
        },
      );
  }
}