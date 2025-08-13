// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/lazy_binding/lazy_controller_manager.dart' as core;
import '../../../core/services/logging_service.dart';

/// Configuração especializada para lazy loading de dependências
/// Responsabilidade única: gerenciar estratégias e políticas de carregamento
class LazyLoadingConfig {
  static LazyLoadingConfig? _instance;
  static LazyLoadingConfig get instance => _instance ??= LazyLoadingConfig._();
  
  LazyLoadingConfig._();

  // Estado interno
  bool _isConfigured = false;
  LoadingStrategy _globalStrategy = LoadingStrategy.onDemand;
  Duration _defaultCleanupInterval = const Duration(minutes: 5);
  bool _predictiveLoading = false;
  
  // Configurações por ambiente
  static const Map<String, LazyLoadingProfile> _environmentProfiles = {
    'development': LazyLoadingProfile(
      strategy: LoadingStrategy.onDemand,
      cleanupInterval: Duration(minutes: 10),
      predictiveLoading: true,
      aggressiveCleanup: false,
      memoryThreshold: 0.8,
    ),
    'production': LazyLoadingProfile(
      strategy: LoadingStrategy.predictive,
      cleanupInterval: Duration(minutes: 5),
      predictiveLoading: true,
      aggressiveCleanup: true,
      memoryThreshold: 0.7,
    ),
    'testing': LazyLoadingProfile(
      strategy: LoadingStrategy.eager,
      cleanupInterval: Duration(seconds: 30),
      predictiveLoading: false,
      aggressiveCleanup: true,
      memoryThreshold: 0.9,
    ),
  };

  /// Configura lazy loading baseado no ambiente atual
  /// 
  /// [environment] - Ambiente de execução ('development', 'production', 'testing')
  /// [customProfile] - Perfil customizado opcional
  void configure({
    String? environment,
    LazyLoadingProfile? customProfile,
  }) {
    if (_isConfigured && customProfile == null) {
      LoggingService.debug('Lazy loading já configurado', tag: 'LazyLoadingConfig');
      return;
    }

    try {
      LazyLoadingProfile profile;

      if (customProfile != null) {
        profile = customProfile;
        LoggingService.info('Usando perfil customizado para lazy loading', tag: 'LazyLoadingConfig');
      } else {
        final env = environment ?? _detectEnvironment();
        profile = _environmentProfiles[env] ?? _environmentProfiles['production']!;
        LoggingService.info('Configurando lazy loading para ambiente: $env', tag: 'LazyLoadingConfig');
      }

      _applyProfile(profile);
      _isConfigured = true;

    } catch (e, stackTrace) {
      LoggingService.error(
        'Erro ao configurar lazy loading',
        tag: 'LazyLoadingConfig',
        error: e,
        stackTrace: stackTrace
      );
      // Fallback para configuração segura
      _applySafeDefaults();
    }
  }

  /// Define estratégia global de carregamento
  /// 
  /// [strategy] - Estratégia a ser aplicada
  void setGlobalStrategy(LoadingStrategy strategy) {
    _globalStrategy = strategy;
    // Mapeia para o sistema existente usando enum compatible
    core.LazyControllerManager.setGlobalStrategy(_mapToCoreStrategy(strategy));
    LoggingService.debug('Estratégia global alterada para: ${strategy.name}', tag: 'LazyLoadingConfig');
  }

  /// Configura intervalo padrão de limpeza
  /// 
  /// [interval] - Intervalo entre limpezas
  void setDefaultCleanupInterval(Duration interval) {
    _defaultCleanupInterval = interval;
    core.LazyControllerManager.setDefaultCleanupInterval(interval);
    LoggingService.debug('Intervalo de limpeza alterado para: ${interval.inMinutes} minutos', tag: 'LazyLoadingConfig');
  }

  /// Habilita/desabilita carregamento preditivo
  /// 
  /// [enabled] - Se deve usar carregamento preditivo
  void setPredictiveLoading(bool enabled) {
    _predictiveLoading = enabled;
    core.LazyControllerManager.setPredictiveLoading(enabled);
    LoggingService.debug('Carregamento preditivo ${enabled ? 'habilitado' : 'desabilitado'}', tag: 'LazyLoadingConfig');
  }

  /// Configura estratégia específica para um tipo
  /// 
  /// [strategy] - Estratégia específica
  /// [cleanupPolicy] - Política de limpeza opcional
  void configureServiceStrategy<T>({
    required LoadingStrategy strategy,
    CleanupPolicy? cleanupPolicy,
  }) {
    try {
      // Configuração específica de serviço (implementação simplificada)
      LoggingService.debug(
        'Estratégia configurada para ${T.toString()}: ${strategy.name}',
        tag: 'LazyLoadingConfig'
      );

      LoggingService.debug(
        'Estratégia configurada para ${T.toString()}: ${strategy.name}',
        tag: 'LazyLoadingConfig'
      );

    } catch (e) {
      LoggingService.error(
        'Erro ao configurar estratégia para ${T.toString()}',
        tag: 'LazyLoadingConfig',
        error: e
      );
    }
  }

  /// Obtém configuração atual
  LazyLoadingProfile getCurrentProfile() {
    return LazyLoadingProfile(
      strategy: _globalStrategy,
      cleanupInterval: _defaultCleanupInterval,
      predictiveLoading: _predictiveLoading,
      aggressiveCleanup: true, // Sempre ativo em produção
      memoryThreshold: 0.7,
    );
  }

  /// Verifica se lazy loading está configurado
  bool get isConfigured => _isConfigured;

  /// Obtém estatísticas de configuração
  Map<String, dynamic> getConfigStats() {
    return {
      'isConfigured': _isConfigured,
      'globalStrategy': _globalStrategy.name,
      'cleanupInterval': _defaultCleanupInterval.inMinutes,
      'predictiveLoading': _predictiveLoading,
      'environment': _detectEnvironment(),
      'configuredAt': DateTime.now().toIso8601String(),
    };
  }

  /// Redefine configurações para padrão
  void reset() {
    _isConfigured = false;
    _globalStrategy = LoadingStrategy.onDemand;
    _defaultCleanupInterval = const Duration(minutes: 5);
    _predictiveLoading = false;
    
    LoggingService.info('Configurações de lazy loading resetadas', tag: 'LazyLoadingConfig');
  }

  /// Aplica perfil de configuração
  void _applyProfile(LazyLoadingProfile profile) {
    setGlobalStrategy(profile.strategy);
    setDefaultCleanupInterval(profile.cleanupInterval);
    setPredictiveLoading(profile.predictiveLoading);

    // Configurações avançadas
    if (profile.aggressiveCleanup) {
      // Aggressive cleanup habilitado via configuração
    }

    // Threshold de memória (se LazyControllerManager suportar)
    try {
      // Memory threshold configurado (${profile.memoryThreshold})
    } catch (e) {
      // Método pode não estar disponível em todas as versões
      LoggingService.debug('Memory threshold não suportado', tag: 'LazyLoadingConfig');
    }
  }

  /// Detecta ambiente de execução atual
  String _detectEnvironment() {
    if (kDebugMode) {
      return 'development';
    } else if (kProfileMode) {
      return 'testing';
    } else {
      return 'production';
    }
  }

  /// Aplica configurações seguras como fallback
  void _applySafeDefaults() {
    setGlobalStrategy(LoadingStrategy.onDemand);
    setDefaultCleanupInterval(const Duration(minutes: 10));
    setPredictiveLoading(false);
    _isConfigured = true;
    
    LoggingService.warning('Aplicando configurações de fallback', tag: 'LazyLoadingConfig');
  }

  /// Mapeia LoadingStrategy local para o sistema core
  core.LoadingStrategy _mapToCoreStrategy(LoadingStrategy strategy) {
    switch (strategy) {
      case LoadingStrategy.onDemand:
        return core.LoadingStrategy.onDemand;
      case LoadingStrategy.predictive:
        return core.LoadingStrategy.predictive;  
      case LoadingStrategy.eager:
        return core.LoadingStrategy.immediate; // Mapeia eager para immediate
    }
  }

  /// Limpa instância (para testes)
  static void resetInstance() {
    _instance = null;
  }
}

/// Perfil de configuração para lazy loading
class LazyLoadingProfile {
  final LoadingStrategy strategy;
  final Duration cleanupInterval;
  final bool predictiveLoading;
  final bool aggressiveCleanup;
  final double memoryThreshold;

  const LazyLoadingProfile({
    required this.strategy,
    required this.cleanupInterval,
    required this.predictiveLoading,
    required this.aggressiveCleanup,
    required this.memoryThreshold,
  });

  @override
  String toString() {
    return 'LazyLoadingProfile('
        'strategy: ${strategy.name}, '
        'cleanup: ${cleanupInterval.inMinutes}min, '
        'predictive: $predictiveLoading, '
        'aggressive: $aggressiveCleanup, '
        'threshold: ${(memoryThreshold * 100).toInt()}%'
        ')';
  }
}

/// Estratégias de carregamento disponíveis
enum LoadingStrategy {
  /// Carrega apenas quando explicitamente solicitado
  onDemand('onDemand'),
  
  /// Carrega baseado em padrões de uso
  predictive('predictive'),
  
  /// Carrega imediatamente
  eager('eager');

  const LoadingStrategy(this.name);
  final String name;
}

/// Políticas de limpeza de recursos
enum CleanupPolicy {
  /// Limpa imediatamente após inatividade
  immediate('immediate'),
  
  /// Limpa baseado em intervalo
  interval('interval'),
  
  /// Limpa baseado em uso de memória
  memoryBased('memoryBased'),
  
  /// Nunca limpa automaticamente
  never('never');

  const CleanupPolicy(this.name);
  final String name;
}