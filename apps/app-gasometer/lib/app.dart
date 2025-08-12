import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
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
          create: (_) => AuthProvider(),
        ),
        
        // Premium Provider
        ChangeNotifierProvider(
          create: (_) => PremiumProvider(),
        ),
        
        // Vehicles Provider
        ChangeNotifierProvider(
          create: (_) => VehiclesProvider(),
        ),
        
        // TODO: Adicionar outros providers quando criados
        // - FuelProvider
        // - MaintenanceProvider  
        // - ReportsProvider
        // - ThemeProvider
        // - AnalyticsProvider
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);
        
        return MaterialApp.router(
          title: 'GasOMeter - Controle de Veículos',
          theme: GasOMeterTheme.lightTheme,
          darkTheme: GasOMeterTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}