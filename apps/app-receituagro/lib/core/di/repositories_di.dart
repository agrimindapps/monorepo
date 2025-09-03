import 'package:get_it/get_it.dart';

// Busca Avançada
import '../../features/busca_avancada/di/busca_di.dart';
// Culturas
import '../../features/culturas/di/culturas_di.dart';
// Defensivos
import '../../features/defensivos/di/defensivos_di.dart';
// Subscription (será criado)
import '../../features/subscription/di/subscription_di.dart';

/// Configuração centralizada de todos os repositories
/// Segue padrão Clean Architecture + GetIt para DI
/// 
/// Esta função deve ser chamada no main.dart após inicialização do core
void configureAllRepositoriesDependencies() {
  // Configurar dependências de culturas
  configureCulturasDependencies();
  
  // Configurar dependências de defensivos
  configureDefensivosDependencies();
  
  // Configurar dependências de busca avançada
  configureBuscaDependencies();
  
  // Configurar dependências de subscription
  configureSubscriptionDependencies();
}

/// Função para limpar todas as dependências (útil para testes)
void clearAllRepositoriesDependencies() {
  final getIt = GetIt.instance;
  
  // Lista de tipos para limpar (adicionar novos conforme necessário)
  final typesToClear = [
    // Culturas
    'ICulturasRepository',
    'GetCulturasUseCase',
    'CulturasProvider',
    
    // Defensivos
    'IDefensivosRepository',
    'GetDefensivosUseCase',
    'DefensivosProvider',
    'HomeDefensivosProvider',
    
    // Busca
    'IBuscaRepository',
    'BuscarComFiltrosUseCase',
    'BuscaProvider',
    
    // Subscription
    'ISubscriptionRepository',
    'GetUserPremiumStatusUseCase',
    'SubscriptionProvider',
  ];
  
  // Limpar dependências se registradas
  for (final type in typesToClear) {
    if (getIt.isRegistered(instanceName: type)) {
      getIt.unregister(instanceName: type);
    }
  }
}

/// Verifica se todas as dependências estão registradas
bool areAllRepositoriesRegistered() {
  final getIt = GetIt.instance;
  
  try {
    // Verificar dependências críticas
    getIt.get<Object>(instanceName: 'ICulturasRepository');
    getIt.get<Object>(instanceName: 'IDefensivosRepository');
    getIt.get<Object>(instanceName: 'IBuscaRepository');
    getIt.get<Object>(instanceName: 'ISubscriptionRepository');
    
    return true;
  } catch (e) {
    return false;
  }
}