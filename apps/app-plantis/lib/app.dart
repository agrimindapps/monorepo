import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/plants/presentation/providers/plants_list_provider.dart';
import 'features/spaces/presentation/providers/spaces_provider.dart';
import 'features/tasks/presentation/providers/tasks_provider.dart';
import 'core/di/injection_container.dart' as di;

class PlantisApp extends StatelessWidget {
  const PlantisApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<PlantsListProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<SpacesProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<TasksProvider>(),
        ),
      ],
      builder: (context, child) {
        final router = AppRouter.router(context);
        
        return MaterialApp.router(
          title: 'Plantis - Cuidado de Plantas',
          theme: PlantisTheme.lightTheme,
          darkTheme: PlantisTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}