import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import 'di/settings_di.dart';
import 'presentation/providers/settings_provider.dart';
import 'settings_page.dart';

/// Example of how to integrate the refactored SettingsPage with Provider
/// This demonstrates proper provider integration and dependency injection
class SettingsIntegrationExample extends StatelessWidget {
  const SettingsIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Option 1: Using ChangeNotifierProvider with DI
    return ChangeNotifierProvider<SettingsProvider>(
      create: (_) => di.sl<SettingsProvider>(),
      child: const SettingsPage(),
    );
  }

  /// Alternative integration using ProxyProvider if needed
  static Widget withProxyProvider() {
    return ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(
        getUserSettingsUseCase: di.sl(),
        updateUserSettingsUseCase: di.sl(),
      ),
      child: const SettingsPage(),
    );
  }

  /// Integration for full app - wrap in MultiProvider
  static Widget forFullApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => di.sl<SettingsProvider>(),
        ),
        // Other providers...
      ],
      child: child,
    );
  }

  /// Initialization method to call in main() or app startup
  static Future<void> initialize() async {
    // Ensure DI is registered
    SettingsDI.register(di.sl);
    
    // Initialize the singleton provider
    final provider = di.sl<SettingsProvider>();
    await provider.initialize('default_user'); // Replace with actual user ID from auth
  }
}

// Example usage in routing:
// 
// GoRoute(
//   path: '/settings',
//   builder: (context, state) => const SettingsIntegrationExample(),
// )
//
// Or in MaterialApp routes:
//
// routes: {
//   '/settings': (context) => const SettingsIntegrationExample(),
// }