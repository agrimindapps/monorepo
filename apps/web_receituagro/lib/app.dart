import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'services/firebase_analytics_service.dart';
import 'themes/manager.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize analytics
    GAnalyticsService.initializeService();

    return MaterialApp(
      title: 'ReceituAgro Web - Gerenciamento de Defensivos',
      debugShowCheckedModeBanner: false,
      theme: ThemeManager().currentTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
