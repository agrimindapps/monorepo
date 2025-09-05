import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injectable_config.dart' as local_di;
import 'core/presentation/widgets/global_error_boundary.dart';
import 'core/router/app_router.dart';
import 'core/sync/presentation/providers/sync_status_provider.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as local;
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/fuel/presentation/providers/fuel_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/odometer/presentation/providers/odometer_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/vehicles/presentation/providers/vehicles_provider.dart';

class GasOMeterApp extends StatefulWidget {
  const GasOMeterApp({super.key});

  @override
  State<GasOMeterApp> createState() => _GasOMeterAppState();
}

class _GasOMeterAppState extends State<GasOMeterApp> {
  bool _globalErrorBoundaryEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadErrorBoundaryPreference();
  }

  Future<void> _loadErrorBoundaryPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _globalErrorBoundaryEnabled = prefs.getBool('global_error_boundary_enabled') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      // Se falhar, manter como ativo por segurança
      setState(() {
        _globalErrorBoundaryEnabled = true;
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // LEVEL 1: Base providers (no dependencies)
        // Auth Provider - deve ser o primeiro (base dependency)
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<local.AuthProvider>(),
          lazy: false, // Force immediate creation for proper initialization
        ),
        
        // Theme Provider - independent
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        
        // Settings Provider - independent
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<SettingsProvider>(),
        ),
        
        // Sync Status Provider - independent
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<SyncStatusProvider>(),
        ),
        
        // Premium Provider - independent 
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<PremiumProvider>(),
        ),
        
        // LEVEL 2: Domain providers (depend on Auth)
        // Vehicles Provider - depends on Auth for user context
        ChangeNotifierProvider(
          create: (_) {
            final vehiclesProvider = local_di.getIt<VehiclesProvider>();
            // Initialize after the provider is fully created
            Future.microtask(() => vehiclesProvider.initialize());
            return vehiclesProvider;
          },
          lazy: true,
        ),
        
        // LEVEL 3: Feature providers (depend on domain providers)
        // Fuel Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<FuelProvider>(),
          lazy: true,
        ),
        
        // Maintenance Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<MaintenanceProvider>(),
          lazy: true,
        ),
        
        // Odometer Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<OdometerProvider>(),
          lazy: true,
        ),
        
        // Expenses Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<ExpensesProvider>(),
          lazy: true,
        ),
        
        // LEVEL 4: Analytics providers (depend on multiple feature providers)
        // Reports Provider - depends on multiple providers for comprehensive reporting
        ChangeNotifierProvider(
          create: (_) => local_di.getIt<ReportsProvider>(),
          lazy: true,
        ),
      ],
        builder: (context, child) {
          return Consumer<local.AuthProvider>(
            builder: (context, authProvider, _) {
              // Wait for auth initialization before showing app
              if (!authProvider.isInitialized) {
                return MaterialApp(
                  title: 'GasOMeter - Controle de Veículos',
                  theme: GasometerTheme.lightTheme,
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 24),
                          Text(
                            'Carregando seu controle de veículos...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                );
              }
              
              final router = AppRouter.router(context);
              
              final app = Consumer<ThemeProvider>(
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
              
              // Enquanto carrega as preferências, usar configuração padrão
              if (_isLoading) {
                return app; // Temporariamente sem ErrorBoundary durante loading
              }
              
              // 🚨 DEBUG: GlobalErrorBoundary pode ser desabilitado via configurações
              if (!_globalErrorBoundaryEnabled) {
                if (kDebugMode) {
                  debugPrint('🚨 GlobalErrorBoundary DESABILITADO via configurações');
                }
                return app;
              }
              
              return GlobalErrorBoundary(child: app);
            },
          );
        },
      );
  }
}