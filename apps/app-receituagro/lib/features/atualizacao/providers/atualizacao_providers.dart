import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/atualizacao_controller.dart';
import '../services/atualizacao_data_service.dart';
import '../services/theme_service.dart';
import '../views/atualizacao_page.dart';

/// Centralized provider configuration for updates module
class AtualizacaoProviders {
  /// Get change notifier providers for reactive services
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<IThemeService>(
        create: (_) => MockThemeService(),
      ),
    ];
  }

  /// Get proxy providers that depend on other services
  static List<ChangeNotifierProxyProvider> getProxyProviders() {
    return [
      ChangeNotifierProxyProvider<IThemeService, AtualizacaoController>(
        create: (context) => AtualizacaoController(
          dataService: MockAtualizacaoDataService(),
          themeService: context.read<IThemeService>(),
        ),
        update: (_, themeService, controller) =>
            controller ?? AtualizacaoController(
              dataService: MockAtualizacaoDataService(),
              themeService: themeService,
            ),
      ),
    ];
  }

  /// Get static providers that don't need change notification
  static List<Provider> getStaticProviders() {
    return [
      Provider<IAtualizacaoDataService>(
        create: (_) => MockAtualizacaoDataService(),
      ),
    ];
  }

  /// Get all providers in a single list for easier integration
  static List<InheritedProvider> getAllProviders() {
    return [
      ...getProviders(),
      ...getProxyProviders(),
      ...getStaticProviders(),
    ];
  }
}

/// Example usage for wrapping the AtualizacaoPage with providers
class AtualizacaoPageWithProviders extends StatelessWidget {
  const AtualizacaoPageWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AtualizacaoProviders.getAllProviders(),
      child: const AtualizacaoPage(),
    );
  }
}