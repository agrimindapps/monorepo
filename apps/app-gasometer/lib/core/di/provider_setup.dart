import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import '../../features/fuel/presentation/providers/fuel_provider.dart';
import '../../features/maintenance/presentation/providers/maintenance_provider.dart';
import '../../features/premium/presentation/providers/premium_provider.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';
// Providers
import '../../features/vehicles/presentation/providers/vehicles_provider.dart';
import '../sync/presentation/providers/sync_status_provider.dart';
import 'injection_container.dart';

/// Configuração otimizada de providers com lazy loading e reutilização de instâncias
class ProviderSetup {
  
  /// Cache de providers para reutilização com ChangeNotifierProvider.value
  static final Map<Type, ChangeNotifier> _providerCache = {};
  
  /// Setup principal de providers com otimizações de performance
  static List<ChangeNotifierProvider> setupProviders() {
    return [
      // Auth Provider - Carregado imediatamente (essencial)
      ChangeNotifierProvider<auth_provider.AuthProvider>(
        create: (context) => _getOrCreateProvider<auth_provider.AuthProvider>(
          () => sl<auth_provider.AuthProvider>(),
        ),
        lazy: false, // Não lazy - necessário para autenticação
      ),
      
      // Vehicles Provider - Lazy loading com cache
      ChangeNotifierProvider<VehiclesProvider>(
        create: (context) => _getOrCreateProvider<VehiclesProvider>(
          () => sl<VehiclesProvider>(),
        ),
        lazy: true, // Lazy - só carrega quando necessário
      ),
      
      // Fuel Provider - Lazy loading
      ChangeNotifierProvider<FuelProvider>(
        create: (context) => _getOrCreateProvider<FuelProvider>(
          () => sl<FuelProvider>(),
        ),
        lazy: true,
      ),
      
      // Reports Provider - Lazy loading
      ChangeNotifierProvider<ReportsProvider>(
        create: (context) => _getOrCreateProvider<ReportsProvider>(
          () => sl<ReportsProvider>(),
        ),
        lazy: true,
      ),
      
      // Maintenance Provider - Lazy loading
      ChangeNotifierProvider<MaintenanceProvider>(
        create: (context) => _getOrCreateProvider<MaintenanceProvider>(
          () => sl<MaintenanceProvider>(),
        ),
        lazy: true,
      ),
      
      // Premium Provider - Lazy loading
      ChangeNotifierProvider<PremiumProvider>(
        create: (context) => _getOrCreateProvider<PremiumProvider>(
          () => sl<PremiumProvider>(),
        ),
        lazy: true,
      ),
      
      // Sync Status Provider - Não lazy (importante para status de sync)
      ChangeNotifierProvider<SyncStatusProvider>(
        create: (context) => _getOrCreateProvider<SyncStatusProvider>(
          () => sl<SyncStatusProvider>(),
        ),
        lazy: false,
      ),
    ];
  }
  
  /// Obtém ou cria provider com cache para reutilização
  static T _getOrCreateProvider<T extends ChangeNotifier>(T Function() factory) {
    if (_providerCache.containsKey(T)) {
      return _providerCache[T] as T;
    }
    
    final provider = factory();
    _providerCache[T] = provider;
    return provider;
  }
  
  /// Setup para providers específicos de páginas usando .value
  static ChangeNotifierProvider<T> createValueProvider<T extends ChangeNotifier>() {
    final cachedProvider = _providerCache[T];
    if (cachedProvider != null) {
      return ChangeNotifierProvider<T>.value(
        value: cachedProvider as T,
      );
    }
    
    // Fallback para criação normal se não estiver no cache
    throw Exception('Provider $T não encontrado no cache. Configure-o primeiro com setupProviders()');
  }
  
  /// Exemplo de uso otimizado para páginas específicas
  static Widget wrapWithOptimizedProviders({
    required Widget child,
    List<Type> requiredProviders = const [],
  }) {
    // Cria apenas os providers necessários usando .value para reutilizar instâncias
    final providers = <ChangeNotifierProvider>[];
    
    for (final providerType in requiredProviders) {
      if (providerType == VehiclesProvider) {
        if (_providerCache.containsKey(VehiclesProvider)) {
          providers.add(
            ChangeNotifierProvider<VehiclesProvider>.value(
              value: _providerCache[VehiclesProvider] as VehiclesProvider,
            ),
          );
        }
      } else if (providerType == FuelProvider) {
        if (_providerCache.containsKey(FuelProvider)) {
          providers.add(
            ChangeNotifierProvider<FuelProvider>.value(
              value: _providerCache[FuelProvider] as FuelProvider,
            ),
          );
        }
      }
      // Adicionar outros providers conforme necessário
    }
    
    if (providers.isEmpty) {
      return child;
    }
    
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
  
  /// Limpa cache de providers (útil para testes ou hot reload)
  static void clearCache() {
    for (final provider in _providerCache.values) {
      provider.dispose();
    }
    _providerCache.clear();
  }
  
  /// Pré-carrega providers críticos para melhor performance
  static Future<void> preloadCriticalProviders() async {
    // Pré-carrega providers essenciais
    _getOrCreateProvider<auth_provider.AuthProvider>(
      () => sl<auth_provider.AuthProvider>(),
    );
    
    _getOrCreateProvider<SyncStatusProvider>(
      () => sl<SyncStatusProvider>(),
    );
    
    // Inicializa providers críticos se necessário
    // Note: Implementar inicialização específica se necessário
  }
}

/// Extension para facilitar o uso de providers otimizados
extension OptimizedProviderExtension on BuildContext {
  /// Lê provider do cache se disponível, senão usa o padrão
  T readCached<T extends ChangeNotifier>() {
    final cached = ProviderSetup._providerCache[T];
    if (cached != null) {
      return cached as T;
    }
    return read<T>();
  }
  
  /// Observa provider do cache se disponível, senão usa o padrão
  T watchCached<T extends ChangeNotifier>() {
    final cached = ProviderSetup._providerCache[T];
    if (cached != null) {
      return cached as T;
    }
    return watch<T>();
  }
}

/// Exemplo de widget que demonstra uso otimizado
class OptimizedProviderExample extends StatelessWidget {
  const OptimizedProviderExample({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Usar ProviderSetup.wrapWithOptimizedProviders para páginas específicas
    return ProviderSetup.wrapWithOptimizedProviders(
      requiredProviders: [VehiclesProvider, FuelProvider],
      child: Scaffold(
        appBar: AppBar(title: const Text('Exemplo Otimizado')),
        body: Column(
          children: [
            // Usar Selector para rebuilds granulares
            Selector<VehiclesProvider, int>(
              selector: (context, provider) => provider.vehicleCount,
              builder: (context, count, child) {
                return Text('Total de veículos: $count');
              },
            ),
            
            // Usar context.readCached para acessar provider cachado
            ElevatedButton(
              onPressed: () {
                // Acessa provider do cache se disponível
                final vehiclesProvider = context.readCached<VehiclesProvider>();
                vehiclesProvider.loadVehicles();
              },
              child: const Text('Carregar Veículos'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Factory pattern para criação otimizada de providers específicos
class OptimizedProviderFactory {
  /// Cria provider de veículos com configuração otimizada
  static ChangeNotifierProvider<VehiclesProvider> createVehiclesProvider({
    bool lazy = true,
    bool useCache = true,
  }) {
    if (useCache && ProviderSetup._providerCache.containsKey(VehiclesProvider)) {
      return ChangeNotifierProvider<VehiclesProvider>.value(
        value: ProviderSetup._providerCache[VehiclesProvider] as VehiclesProvider,
      );
    }
    
    return ChangeNotifierProvider<VehiclesProvider>(
      create: (context) => ProviderSetup._getOrCreateProvider<VehiclesProvider>(
        () => sl<VehiclesProvider>(),
      ),
      lazy: lazy,
    );
  }
  
  /// Cria provider de combustível com configuração otimizada
  static ChangeNotifierProvider<FuelProvider> createFuelProvider({
    bool lazy = true,
    bool useCache = true,
  }) {
    if (useCache && ProviderSetup._providerCache.containsKey(FuelProvider)) {
      return ChangeNotifierProvider<FuelProvider>.value(
        value: ProviderSetup._providerCache[FuelProvider] as FuelProvider,
      );
    }
    
    return ChangeNotifierProvider<FuelProvider>(
      create: (context) => ProviderSetup._getOrCreateProvider<FuelProvider>(
        () => sl<FuelProvider>(),
      ),
      lazy: lazy,
    );
  }
}