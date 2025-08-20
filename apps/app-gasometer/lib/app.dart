import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';

import 'core/theme/gasometer_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as local;
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/vehicles/presentation/providers/vehicles_provider.dart';

class GasOMeterApp extends StatelessWidget {
  const GasOMeterApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - deve ser o primeiro
        ChangeNotifierProvider(
          create: (_) => sl<local.AuthProvider>(),
        ),
        
        // Premium Provider
        ChangeNotifierProvider(
          create: (_) => sl<PremiumProvider>(),
        ),
        
        // Vehicles Provider
        ChangeNotifierProvider(
          create: (_) => sl<VehiclesProvider>(),
        ),
        
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        
        // TODO: Adicionar outros providers quando criados
        // - FuelProvider
        // - MaintenanceProvider  
        // - ReportsProvider
        // - AnalyticsProvider
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);
        
        return Consumer<ThemeProvider>(
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
        );
      },
    );
  }
}