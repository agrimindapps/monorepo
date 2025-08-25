import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as app_auth;
import 'features/plants/presentation/providers/plant_task_provider.dart';
import 'features/plants/presentation/providers/plants_list_provider.dart';
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/tasks/presentation/providers/tasks_provider.dart';

class PlantisApp extends StatelessWidget {
  const PlantisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<app_auth.AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PlantsListProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PlantTaskProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TasksProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PremiumProvider>()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp.router(
              title: 'Plantis - Cuidado de Plantas',
              theme: PlantisTheme.lightTheme,
              darkTheme: PlantisTheme.darkTheme,
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
