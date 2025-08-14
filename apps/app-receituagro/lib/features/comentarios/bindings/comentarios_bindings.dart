import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/comentarios_controller.dart';
import '../services/comentarios_service.dart';
import '../services/mock_comentarios_repository.dart';
import '../services/mock_premium_service.dart';
import '../comentarios_page.dart';

/// Centralized provider configuration for comentarios module
class ComentariosProviders {
  /// Get change notifier providers for reactive services
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ComentariosService>(
        create: (_) => ComentariosService(
          repository: MockComentariosRepository(),
          premiumService: MockPremiumService(),
        ),
      ),
    ];
  }

  /// Get proxy providers that depend on other services
  static List<ChangeNotifierProxyProvider> getProxyProviders() {
    return [
      ChangeNotifierProxyProvider<ComentariosService, ComentariosController>(
        create: (context) => ComentariosController(
          service: context.read<ComentariosService>(),
        ),
        update: (_, service, controller) =>
            controller ?? ComentariosController(service: service),
      ),
    ];
  }

  /// Get static providers that don't need change notification
  static List<Provider> getStaticProviders() {
    return [
      Provider<IComentariosRepository>(
        create: (_) => MockComentariosRepository(),
      ),
      Provider<IPremiumService>(
        create: (_) => MockPremiumService(),
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

/// Example usage for wrapping the ComentariosPage with providers
class ComentariosPageWithProviders extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPageWithProviders({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ComentariosProviders.getAllProviders(),
      child: ComentariosPage(
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      ),
    );
  }
}