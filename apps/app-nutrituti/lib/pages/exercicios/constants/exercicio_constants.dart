/// Constantes compartilhadas do módulo de exercícios
/// Centraliza todos os valores hardcoded para facilitar manutenção e configuração
class ExercicioConstants {
  
  // ========================================================================
  // CONSTANTES DE VALIDAÇÃO
  // ========================================================================
  
  /// Tamanho máximo do nome do exercício em caracteres
  static const int maxNomeLength = 100;
  
  /// Tamanho mínimo do nome do exercício em caracteres
  static const int minNomeLength = 2;
  
  /// Tamanho máximo da categoria em caracteres
  static const int maxCategoriaLength = 50;
  
  /// Duração mínima do exercício em minutos
  static const int minDuracaoMinutos = 1;
  
  /// Duração máxima do exercício em minutos (12 horas)
  static const int maxDuracaoMinutos = 720;
  
  /// Número máximo de calorias queimadas permitido
  static const int maxCaloriasQueimadas = 5000;
  
  /// Tamanho máximo das observações em caracteres
  static const int maxObservacoesLength = 500;
  
  /// Idade máxima de registro em anos
  static const int maxIdadeRegistroAnos = 10;
  
  /// Meta máxima de minutos semanais (7 dias * 24 horas * 60 minutos)
  static const double maxMetaMinutosSemanal = 10080;
  
  /// Meta máxima de calorias semanais
  static const double maxMetaCaloriasSemanal = 70000;
  
  /// Máximo de calorias por minuto (para validação de consistência)
  static const int maxCaloriasPorMinuto = 20;
  
  // ========================================================================
  // CONSTANTES DE INTERFACE E COMPORTAMENTO
  // ========================================================================
  
  /// Duração padrão inicial para novos exercícios (minutos)
  static const int duracaoPadraoMinutos = 30;
  
  /// Ícone de dica - tamanho padrão
  static const double iconeTipSize = 30.0;
  
  /// Largura da barra de progresso
  static const double progressBarWidth = 100.0;
  
  /// Primeiro ano do calendário
  static const int calendarioAnoInicio = 2020;
  
  /// Último ano do calendário
  static const int calendarioAnoFim = 2030;
  
  /// Máximo de marcadores no calendário
  static const int calendarioMaxMarkers = 3;
  
  // ========================================================================
  // CONSTANTES DE PERFORMANCE E CACHE
  // ========================================================================
  
  /// Tamanho máximo do cache de estatísticas
  static const int maxCacheSize = 100;
  
  /// Número máximo de logs recentes mantidos na memória
  static const int maxRecentLogs = 100;
  
  /// Duração limite para operações lentas (ms)
  static const int slowOperationThresholdMs = 1000;
  
  /// Tempo de expiração do cache em minutos
  static const int cacheExpiryMinutes = 5;
  
  // ========================================================================
  // CONSTANTES DE CONQUISTAS E GAMIFICAÇÃO
  // ========================================================================
  
  /// Meta de calorias para conquista "Queimando Calorias"
  static const int conquistaCaloriasMeta = 1000;
  
  /// Número de dias consecutivos para conquista "Constância"
  static const int conquistaDiasConsecutivos = 7;
  
  /// Número de sessões para conquista "Dedicação"
  static const int conquistaSessoesMeta = 30;
  
  /// Número de exercícios diferentes para conquista "Explorador"
  static const int conquistaExerciciosDiferentes = 10;
  
  // ========================================================================
  // CONSTANTES DE REDE E SINCRONIZAÇÃO
  // ========================================================================
  
  /// Status codes HTTP considerados para retry
  static const List<int> retryableHttpStatusCodes = [500, 502, 503, 504];
  
  /// Número máximo de tentativas de sincronização
  static const int maxSyncRetries = 3;
  
  /// Delay entre tentativas de retry em segundos
  static const int retryDelaySeconds = 2;
  
  /// Timeout padrão para operações de rede em segundos
  static const int networkTimeoutSeconds = 30;
  
  // ========================================================================
  // CONSTANTES DE LOG LEVELS
  // ========================================================================
  
  /// Level de log: verbose
  static const int logLevelVerbose = 500;
  
  /// Level de log: debug
  static const int logLevelDebug = 700;
  
  /// Level de log: info
  static const int logLevelInfo = 800;
  
  /// Level de log: warning
  static const int logLevelWarning = 900;
  
  /// Level de log: error
  static const int logLevelError = 1000;
  
  /// Level de log: fatal
  static const int logLevelFatal = 1200;
  
  // ========================================================================
  // CONSTANTES DE LAYOUT E UI
  // ========================================================================
  
  /// Largura máxima da tela principal
  static const double mainScreenMaxWidth = 1020.0;
  
  /// Padding padrão
  static const double defaultPadding = 8.0;
  
  /// Padding interno dos cards
  static const double cardInternalPadding = 16.0;
  
  /// Altura do gráfico
  static const double chartHeight = 200.0;
  
  /// Altura do container de conquistas
  static const double achievementsHeight = 120.0;
  
  /// Largura do container de conquistas individuais
  static const double achievementContainerWidth = 200.0;
  
  /// Largura do diálogo de exercício
  static const double exerciseDialogWidth = 400.0;
  
  /// Altura do diálogo de exercício
  static const double exerciseDialogHeight = 400.0;
  
  // ========================================================================
  // CONSTANTES DE CONFIGURAÇÃO DE NÍVEIS
  // ========================================================================
  
  /// Duração recomendada para iniciantes (minutos)
  static const int duracaoInicianteMinutos = 30;
  
  /// Duração recomendada para intermediários (minutos)
  static const int duracaoIntermediarioMinutos = 45;
  
  /// Duração recomendada para avançados (minutos)
  static const int duracaoAvancadoMinutos = 60;
  
  /// Frequência semanal recomendada para iniciantes
  static const int frequenciaInicianteSemanal = 3;
  
  /// Frequência semanal recomendada para intermediários
  static const int frequenciaIntermediarioSemanal = 4;
  
  /// Frequência semanal recomendada para avançados
  static const int frequenciaAvancadoSemanal = 5;
  
  // ========================================================================
  // MÉTODOS AUXILIARES
  // ========================================================================
  
  /// Retorna todas as constantes como mapa para debug/configuração
  static Map<String, dynamic> getAllConstants() {
    return {
      // Validação
      'maxNomeLength': maxNomeLength,
      'minNomeLength': minNomeLength,
      'maxCategoriaLength': maxCategoriaLength,
      'minDuracaoMinutos': minDuracaoMinutos,
      'maxDuracaoMinutos': maxDuracaoMinutos,
      'maxCaloriasQueimadas': maxCaloriasQueimadas,
      'maxObservacoesLength': maxObservacoesLength,
      'maxIdadeRegistroAnos': maxIdadeRegistroAnos,
      'maxMetaMinutosSemanal': maxMetaMinutosSemanal,
      'maxMetaCaloriasSemanal': maxMetaCaloriasSemanal,
      'maxCaloriasPorMinuto': maxCaloriasPorMinuto,
      
      // Interface
      'duracaoPadraoMinutos': duracaoPadraoMinutos,
      'iconeTipSize': iconeTipSize,
      'progressBarWidth': progressBarWidth,
      'calendarioAnoInicio': calendarioAnoInicio,
      'calendarioAnoFim': calendarioAnoFim,
      'calendarioMaxMarkers': calendarioMaxMarkers,
      
      // Performance
      'maxCacheSize': maxCacheSize,
      'maxRecentLogs': maxRecentLogs,
      'slowOperationThresholdMs': slowOperationThresholdMs,
      'cacheExpiryMinutes': cacheExpiryMinutes,
      
      // Conquistas
      'conquistaCaloriasMeta': conquistaCaloriasMeta,
      'conquistaDiasConsecutivos': conquistaDiasConsecutivos,
      'conquistaSessoesMeta': conquistaSessoesMeta,
      'conquistaExerciciosDiferentes': conquistaExerciciosDiferentes,
      
      // Rede
      'maxSyncRetries': maxSyncRetries,
      'retryDelaySeconds': retryDelaySeconds,
      'networkTimeoutSeconds': networkTimeoutSeconds,
      
      // Layout
      'mainScreenMaxWidth': mainScreenMaxWidth,
      'defaultPadding': defaultPadding,
      'cardInternalPadding': cardInternalPadding,
      'chartHeight': chartHeight,
      'achievementsHeight': achievementsHeight,
      'achievementContainerWidth': achievementContainerWidth,
      'exerciseDialogWidth': exerciseDialogWidth,
      'exerciseDialogHeight': exerciseDialogHeight,
      
      // Níveis
      'duracaoInicianteMinutos': duracaoInicianteMinutos,
      'duracaoIntermediarioMinutos': duracaoIntermediarioMinutos,
      'duracaoAvancadoMinutos': duracaoAvancadoMinutos,
      'frequenciaInicianteSemanal': frequenciaInicianteSemanal,
      'frequenciaIntermediarioSemanal': frequenciaIntermediarioSemanal,
      'frequenciaAvancadoSemanal': frequenciaAvancadoSemanal,
    };
  }
  
  /// Valida se um valor está dentro dos limites definidos
  static bool isValidDuration(int minutes) {
    return minutes >= minDuracaoMinutos && minutes <= maxDuracaoMinutos;
  }
  
  /// Valida se um nome está dentro dos limites
  static bool isValidName(String name) {
    return name.length >= minNomeLength && name.length <= maxNomeLength;
  }
  
  /// Valida se calorias estão dentro dos limites
  static bool isValidCalories(int calories) {
    return calories >= 0 && calories <= maxCaloriasQueimadas;
  }
}