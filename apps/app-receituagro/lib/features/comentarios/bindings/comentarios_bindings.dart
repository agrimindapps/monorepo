import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/interfaces/i_premium_service.dart';
import '../comentarios_page.dart';
import '../controller/comentarios_controller.dart';
import '../services/comentarios_service.dart';
import '../services/mock_comentarios_repository.dart';

/// Mock implementation of IPremiumService for comentarios module
class _MockPremiumService extends ChangeNotifier implements IPremiumService {
  @override
  bool get isPremium => false;
  
  @override
  PremiumStatus get status => const PremiumStatus(isActive: false);
  
  @override
  bool get shouldShowPremiumDialogs => true;
  
  @override
  Future<void> checkPremiumStatus() async {}
  
  @override
  Future<bool> isPremiumUser() async => false;
  
  @override
  Future<String?> getSubscriptionType() async => null;
  
  @override
  Future<DateTime?> getSubscriptionExpiry() async => null;
  
  @override
  Future<bool> isSubscriptionActive() async => false;
  
  @override
  Future<int> getRemainingDays() async => 0;
  
  @override
  Future<void> refreshPremiumStatus() async {}
  
  @override
  bool canUseFeature(String featureName) => false;
  
  @override
  Future<bool> hasFeatureAccess(String featureId) async => false;
  
  @override
  int getFeatureLimit(String featureName) => 0;
  
  @override
  bool hasReachedLimit(String featureName, int currentUsage) => true;
  
  @override
  Future<List<String>> getPremiumFeatures() async => [];
  
  @override
  Future<bool> isTrialAvailable() async => false;
  
  @override
  Future<bool> startTrial() async => false;
  
  @override
  Future<void> generateTestSubscription() async {}
  
  @override
  Future<void> removeTestSubscription() async {}
  
  @override
  Future<void> navigateToPremium() async {}
  
  @override
  String? get upgradeUrl => null;
  
  @override
  Stream<bool> get premiumStatusStream => const Stream.empty();
}

/// Centralized provider configuration for comentarios module
class ComentariosProviders {
  /// Get change notifier providers for reactive services
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ComentariosService>(
        create: (_) => ComentariosService(
          repository: MockComentariosRepository(),
          premiumService: _MockPremiumService(),
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
      Provider<IPremiumService>.value(
        value: _MockPremiumService(),
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