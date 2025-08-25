import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config_page.dart';
import '../services/device_service.dart';
import '../services/premium_service.dart';
import '../services/theme_service.dart';

/// Centralized provider configuration for settings module
class SettingsProviders {
  /// Get all providers needed for the settings module
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<IThemeService>(
        create: (_) => MockThemeService(),
      ),
      ChangeNotifierProvider<IPremiumService>(
        create: (_) => MockPremiumService(),
      ),
    ];
  }

  /// Get static providers that don't need change notification
  static List<Provider> getStaticProviders() {
    return [
      Provider<IDeviceService>(
        create: (_) => MockDeviceService(),
      ),
    ];
  }

  /// Get all providers in a single list for easier integration
  static List<InheritedProvider> getAllProviders() {
    return [
      ...getProviders(),
      ...getStaticProviders(),
    ];
  }
}

/// Example usage for wrapping the ConfigPage with providers
class SettingsPageWithProviders extends StatelessWidget {
  const SettingsPageWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: SettingsProviders.getAllProviders(),
      child: const ConfigPage(),
    );
  }
}