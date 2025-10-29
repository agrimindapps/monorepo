import 'dart:async';

import 'package:flutter/material.dart';

import 'services/firebase_analytics_service.dart';

import 'themes/manager.dart';
import 'app-site/router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _MyApp();
}

class _MyApp extends State<App> {
  Timer? _timer, _timerTheme;
  ThemeData currentTheme = ThemeManager().currentTheme;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    GAnalyticsService.initializeService();

    _timerTheme = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTheme = ThemeManager().currentTheme;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerTheme?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReceituAgro Web',
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Stack(
          children: [
            Navigator(
              key: navigatorKey,
              initialRoute: '/',
              onGenerateRoute: Routes.generateRoute,
            ),
          ],
        ),
      ),
    );
  }
}
