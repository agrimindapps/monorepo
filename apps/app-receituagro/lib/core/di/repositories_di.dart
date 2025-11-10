import 'package:core/core.dart' hide Column;
import '../../features/busca_avancada/di/busca_di.dart';
// ❌ REMOVIDO: import '../../features/culturas/di/culturas_di.dart'; (duplicado via Injectable)
// ❌ REMOVIDO: import '../../features/defensivos/di/defensivos_di.dart'; (duplicado via Injectable)

/// Configuração centralizada de todos os repositories
/// Segue padrão Clean Architecture + GetIt para DI
///
/// Esta função deve ser chamada no main.dart após inicialização do core
///
/// ⚠️ NOTA: Culturas e Defensivos agora são gerenciados via Injectable (@LazySingleton)
/// Apenas Busca precisa de registro manual (por enquanto)
void configureAllRepositoriesDependencies() {
  // ❌ REMOVIDO: configureCulturasDependencies(); (duplicado - registrado via @LazySingleton)
  // ❌ REMOVIDO: configureDefensivosDependencies(); (duplicado - registrado via @LazySingleton)
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
