import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import do arquivo gerado (será criado pelo build_runner)
import 'injectable_config.config.dart';

final getIt = GetIt.instance;

/// Configuração automática do DI usando build_runner
/// 
/// Este arquivo substitui a configuração manual por uma abordagem automática
/// baseada em annotations @injectable, @singleton, @factory, etc.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

/// Inicializa dependências com suporte a environment
void configureDependenciesForEnvironment(String environment) {
  getIt.init(environment: environment);
}

/// Reset do container para testes
void resetDependencies() {
  getIt.reset();
}

/// Registra dependências externas que não podem ser anotadas
void registerExternalDependencies() {
  // Registrar dependências externas aqui se necessário
  // Ex: Firebase, SharedPreferences, etc.
}