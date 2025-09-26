import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'core/router/app_router.dart';
import 'core/theme/gasometer_theme.dart';

class GasOMeterApp extends ConsumerWidget {
  const GasOMeterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GasOMeter - Controle de Veículos',
      theme: GasometerTheme.lightTheme,
      darkTheme: GasometerTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}