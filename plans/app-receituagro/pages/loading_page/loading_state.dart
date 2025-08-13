// Project imports:
import '../../core/bootstrap/bootstrap_phase.dart';

/// Define os possíveis estados durante o processo de inicialização do app
/// Agora mapeados para as fases do AppBootstrapper
enum LoadingState {
  /// Estado inicial
  initial,

  /// Configuração
  configuration,

  /// Dependências Core
  coreDependencies,

  /// Repositórios
  repositories,

  /// Controllers
  controllers,

  /// Serviços de UI
  uiServices,

  /// Rotas
  routes,

  /// Pronto para navegar
  completed,

  /// Erro durante o processo
  error,
}

/// Extensão para obter mensagem amigável de cada estado
extension LoadingStateMessage on LoadingState {
  String get message {
    switch (this) {
      case LoadingState.initial:
        return 'Iniciando...';
      case LoadingState.configuration:
        return 'Configurando aplicação...';
      case LoadingState.coreDependencies:
        return 'Inicializando dependências...';
      case LoadingState.repositories:
        return 'Carregando repositórios...';
      case LoadingState.controllers:
        return 'Preparando controllers...';
      case LoadingState.uiServices:
        return 'Configurando interface...';
      case LoadingState.routes:
        return 'Preparando navegação...';
      case LoadingState.completed:
        return 'Finalizando...';
      case LoadingState.error:
        return 'Ocorreu um erro...';
    }
  }

  /// Retorna o progresso associado a cada estado
  double get progress {
    switch (this) {
      case LoadingState.initial:
        return 0.0;
      case LoadingState.configuration:
        return 0.15;
      case LoadingState.coreDependencies:
        return 0.30;
      case LoadingState.repositories:
        return 0.50;
      case LoadingState.controllers:
        return 0.70;
      case LoadingState.uiServices:
        return 0.85;
      case LoadingState.routes:
        return 0.95;
      case LoadingState.completed:
        return 1.0;
      case LoadingState.error:
        return 0.0;
    }
  }
}

/// Mapeia BootstrapPhase para LoadingState
LoadingState bootstrapPhaseToLoadingState(BootstrapPhase phase) {
  switch (phase) {
    case BootstrapPhase.notStarted:
      return LoadingState.initial;
    case BootstrapPhase.configuration:
      return LoadingState.configuration;
    case BootstrapPhase.coreDependencies:
      return LoadingState.coreDependencies;
    case BootstrapPhase.repositories:
      return LoadingState.repositories;
    case BootstrapPhase.controllers:
      return LoadingState.controllers;
    case BootstrapPhase.uiServices:
      return LoadingState.uiServices;
    case BootstrapPhase.routes:
      return LoadingState.routes;
    case BootstrapPhase.completed:
      return LoadingState.completed;
    case BootstrapPhase.rollback:
      return LoadingState.error;
  }
}
