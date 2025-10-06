import 'package:core/core.dart';
import '../../features/busca_avancada/di/busca_di.dart';
import '../../features/culturas/di/culturas_di.dart';
import '../../features/defensivos/di/defensivos_di.dart';

/// Configuração centralizada de todos os repositories
/// Segue padrão Clean Architecture + GetIt para DI
/// 
/// Esta função deve ser chamada no main.dart após inicialização do core
void configureAllRepositoriesDependencies() {
  configureCulturasDependencies();
  configureDefensivosDependencies();
  configureBuscaDependencies();
}

/// Função para limpar todas as dependências (útil para testes)
void clearAllRepositoriesDependencies() {
  final getIt = GetIt.instance;
  final typesToClear = [
    'ICulturasRepository',
    'GetCulturasUseCase',
    'CulturasProvider',
    'IDefensivosRepository',
    'GetDefensivosUseCase',
    'DefensivosProvider',
    'HomeDefensivosProvider',
    'IBuscaRepository',
    'BuscarComFiltrosUseCase',
    'BuscaProvider',
    'ISubscriptionRepository',
    'GetUserPremiumStatusUseCase',
    'SubscriptionProvider',
  ];
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
    getIt.get<Object>(instanceName: 'ICulturasRepository');
    getIt.get<Object>(instanceName: 'IDefensivosRepository');
    getIt.get<Object>(instanceName: 'IBuscaRepository');
    getIt.get<Object>(instanceName: 'ISubscriptionRepository');
    
    return true;
  } catch (e) {
    return false;
  }
}
