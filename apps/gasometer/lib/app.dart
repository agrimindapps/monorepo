import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
// import 'core/di/injection_container.dart' as di;

class GasOMeterApp extends StatelessWidget {
  const GasOMeterApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
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