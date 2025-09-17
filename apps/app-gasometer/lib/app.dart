import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// import 'core/di/injectable_config.dart' as local_di; // Commented out - using manual DI
import 'core/di/injection_container.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/receipt_image_service.dart';
import 'core/sync/presentation/providers/sync_status_provider.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as local;
import 'features/data_export/presentation/providers/data_export_provider.dart';
import 'features/expenses/presentation/providers/expenses_provider.dart';
import 'features/fuel/presentation/providers/fuel_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/odometer/presentation/providers/odometer_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/vehicles/presentation/providers/vehicles_provider.dart';
import 'features/device_management/presentation/providers/device_management_provider.dart';

class GasOMeterApp extends StatefulWidget {
  const GasOMeterApp({super.key});

  @override
  State<GasOMeterApp> createState() => _GasOMeterAppState();
}

class _GasOMeterAppState extends State<GasOMeterApp> {
  @override
  void initState() {
    super.initState();
    // Inicialização simplificada
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // LEVEL 1: Base providers (no dependencies)
        // Auth Provider - deve ser o primeiro (base dependency)
        ChangeNotifierProvider(
          create: (_) => sl<local.AuthProvider>(),
          lazy: false, // Force immediate creation for proper initialization
        ),
        
        // Theme Provider - independent
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        
        // Settings Provider - independent
        ChangeNotifierProvider(
          create: (_) => sl<SettingsProvider>(),
        ),
        
        // Receipt Image Service - independent service
        Provider<ReceiptImageService>(
          create: (_) => sl<ReceiptImageService>(),
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
        
        // Expenses Provider - depends on Vehicles for vehicle context
        ChangeNotifierProvider(
          create: (_) => sl<ExpensesProvider>(),
          lazy: true,
        ),
        
        // LEVEL 4: Analytics providers (depend on multiple feature providers)
        // Reports Provider - depends on multiple providers for comprehensive reporting
        ChangeNotifierProvider(
          create: (_) => sl<ReportsProvider>(),
          lazy: true,
        ),
        
        // Data Export Provider - depends on Auth for user context
        ChangeNotifierProvider(
          create: (_) => sl<DataExportProvider>(),
          lazy: true,
        ),
        
        // Device Management Provider - depends on Auth for user context
        ChangeNotifierProvider(
          create: (_) => sl<DeviceManagementProvider>(),
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
                  locale: const Locale('pt', 'BR'),
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('pt', 'BR'),
                  ],
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
                    locale: const Locale('pt', 'BR'),
                    localizationsDelegates: [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: [
                      Locale('pt', 'BR'),
                    ],
                    routerConfig: router,
                    debugShowCheckedModeBanner: false,
                  );
                },
              );
              
              // ErrorBoundary removido completamente
              return app;
            },
          );
        },
      );
  }
}