/// Constantes compartilhadas do módulo de meditação
/// Centraliza todos os valores hardcoded para facilitar manutenção e configuração
class MeditacaoConstants {
  
  // ========================================================================
  // CONSTANTES DE DURAÇÃO E TEMPO
  // ========================================================================
  
  /// Durações padrão para sessões de meditação (em minutos)
  static const List<int> duracoesPadrao = [5, 10, 15, 20, 30];
  
  /// Duração mínima para uma sessão de meditação (minutos)
  static const int duracaoMinima = 1;
  
  /// Duração máxima para uma sessão de meditação (minutos)
  static const int duracaoMaxima = 120;
  
  /// Duração padrão inicial para timer (minutos)
  static const int duracaoPadraoMinutos = 10;
  
  /// Intervalo de atualização do timer (segundos)
  static const int intervalTimerSegundos = 1;
  
  // ========================================================================
  // CONSTANTES DE CONQUISTAS
  // ========================================================================
  
  /// Número de dias consecutivos para conquista "Consistência"
  static const int conquistaDiasConsecutivos = 7;
  
  /// Total de minutos para conquista "Dedicação"
  static const int conquistaTotalMinutos = 60;
  
  /// Número mínimo de tipos diferentes para conquista "Explorador"
  static const int conquistaTiposDiferentes = 4;
  
  /// Número mínimo de sessões para primeira conquista
  static const int conquistaPrimeiraSessao = 1;
  
  // ========================================================================
  // CONSTANTES DE NOTIFICAÇÃO
  // ========================================================================
  
  /// Hora padrão para notificação de lembrete
  static const int notificacaoHoraPadrao = 8;
  
  /// Minuto padrão para notificação de lembrete
  static const int notificacaoMinutoPadrao = 0;
  
  /// Intervalo para verificar conquistas recentes (horas)
  static const int conquistasRecentesHoras = 24;
  
  // ========================================================================
  // CONSTANTES DE INTERFACE E LAYOUT
  // ========================================================================
  
  /// Padding padrão para cards e widgets
  static const double paddingPadrao = 16.0;
  
  /// Padding pequeno para espaçamentos internos
  static const double paddingPequeno = 8.0;
  
  /// Padding grande para seções principais
  static const double paddingGrande = 24.0;
  
  /// Altura padrão para botões
  static const double alturaBot = 48.0;
  
  /// Raio padrão para bordas arredondadas
  static const double borderRadius = 12.0;
  
  /// Largura máxima para cards e containers
  static const double larguraMaxContainer = 400.0;
  
  /// Altura do timer circular
  static const double alturaTimer = 200.0;
  
  /// Largura do timer circular
  static const double larguraTimer = 200.0;
  
  /// Espessura da linha do timer circular
  static const double espessuraLinhaTimer = 8.0;
  
  // ========================================================================
  // CONSTANTES DE TIPOS DE MEDITAÇÃO
  // ========================================================================
  
  /// Tipos de meditação disponíveis
  static const List<String> tiposMeditacao = [
    'Mindfulness',
    'Respiração',
    'Body Scan',
    'Loving Kindness',
    'Concentração',
    'Caminhada',
  ];
  
  /// Tipo padrão de meditação
  static const String tipoPadrao = 'Mindfulness';
  
  // ========================================================================
  // CONSTANTES DE HUMOR/ESTADO
  // ========================================================================
  
  /// Estados de humor disponíveis antes da meditação
  static const List<String> humoresDisponiveis = [
    'Muito Estressado',
    'Estressado',
    'Neutro',
    'Calmo',
    'Muito Calmo',
  ];
  
  /// Estados de humor após a meditação
  static const List<String> humoresPosDisponiveis = [
    'Pior',
    'Igual',
    'Melhor',
    'Muito Melhor',
    'Excelente',
  ];
  
  // ========================================================================
  // CONSTANTES DE ÁUDIO
  // ========================================================================
  
  /// Volume padrão para áudios de meditação (0.0 a 1.0)
  static const double volumePadrao = 0.7;
  
  /// Volume mínimo permitido
  static const double volumeMinimo = 0.0;
  
  /// Volume máximo permitido
  static const double volumeMaximo = 1.0;
  
  /// Duração do fade in/out do áudio (milissegundos)
  static const int duracaoFadeMs = 2000;
  
  // ========================================================================
  // CONSTANTES DE ESTATÍSTICAS
  // ========================================================================
  
  /// Número máximo de sessões a mostrar no histórico
  static const int maxHistoricoSessoes = 50;
  
  /// Número de dias para calcular estatísticas semanais
  static const int diasSemana = 7;
  
  /// Número de dias para calcular estatísticas mensais
  static const int diasMes = 30;
  
  /// Número de dias para calcular estatísticas anuais
  static const int diasAno = 365;
  
  // ========================================================================
  // CONSTANTES DE CORES E TEMAS
  // ========================================================================
  
  /// Opacidade para overlays e backgrounds
  static const double opacidadeOverlay = 0.1;
  
  /// Opacidade para elementos desabilitados
  static const double opacidadeDesabilitado = 0.5;
  
  /// Elevação padrão para cards
  static const double elevacaoPadrao = 4.0;
  
  /// Elevação para elementos em foco
  static const double elevacaoFoco = 8.0;
  
  // ========================================================================
  // CONSTANTES DE VALIDAÇÃO
  // ========================================================================
  
  /// Comprimento máximo para título de sessão
  static const int maxTituloLength = 100;
  
  /// Comprimento máximo para anotações
  static const int maxAnotacoesLength = 500;
  
  /// Número máximo de tags por sessão
  static const int maxTagsPorSessao = 5;
  
  // ========================================================================
  // CONSTANTES DE CACHE E PERFORMANCE
  // ========================================================================
  
  /// Tempo de expiração do cache (minutos)
  static const int cacheExpiryMinutes = 10;
  
  /// Tamanho máximo do cache de sessões
  static const int maxCacheSessoes = 100;
  
  /// Intervalo para auto-save (segundos)
  static const int intervalAutoSaveSegundos = 30;
  
  // ========================================================================
  // CONSTANTES DE CONFIGURAÇÃO
  // ========================================================================
  
  /// Número máximo de tentativas para operações de rede
  static const int maxTentativasRede = 3;
  
  /// Timeout para operações de rede (segundos)
  static const int timeoutRedeSegundos = 30;
  
  /// Intervalo entre tentativas (segundos)
  static const int intervalTentativasSegundos = 2;
  
  // ========================================================================
  // MÉTODOS AUXILIARES
  // ========================================================================
  
  /// Retorna todas as constantes como mapa para debug/configuração
  static Map<String, dynamic> getAllConstants() {
    return {
      // Duração e tempo
      'duracoesPadrao': duracoesPadrao,
      'duracaoMinima': duracaoMinima,
      'duracaoMaxima': duracaoMaxima,
      'duracaoPadraoMinutos': duracaoPadraoMinutos,
      'intervalTimerSegundos': intervalTimerSegundos,
      
      // Conquistas
      'conquistaDiasConsecutivos': conquistaDiasConsecutivos,
      'conquistaTotalMinutos': conquistaTotalMinutos,
      'conquistaTiposDiferentes': conquistaTiposDiferentes,
      'conquistaPrimeiraSessao': conquistaPrimeiraSessao,
      
      // Notificação
      'notificacaoHoraPadrao': notificacaoHoraPadrao,
      'notificacaoMinutoPadrao': notificacaoMinutoPadrao,
      'conquistasRecentesHoras': conquistasRecentesHoras,
      
      // Interface
      'paddingPadrao': paddingPadrao,
      'paddingPequeno': paddingPequeno,
      'paddingGrande': paddingGrande,
      'alturaBot': alturaBot,
      'borderRadius': borderRadius,
      'larguraMaxContainer': larguraMaxContainer,
      'alturaTimer': alturaTimer,
      'larguraTimer': larguraTimer,
      'espessuraLinhaTimer': espessuraLinhaTimer,
      
      // Tipos e humor
      'tiposMeditacao': tiposMeditacao,
      'tipoPadrao': tipoPadrao,
      'humoresDisponiveis': humoresDisponiveis,
      'humoresPosDisponiveis': humoresPosDisponiveis,
      
      // Áudio
      'volumePadrao': volumePadrao,
      'volumeMinimo': volumeMinimo,
      'volumeMaximo': volumeMaximo,
      'duracaoFadeMs': duracaoFadeMs,
      
      // Estatísticas
      'maxHistoricoSessoes': maxHistoricoSessoes,
      'diasSemana': diasSemana,
      'diasMes': diasMes,
      'diasAno': diasAno,
      
      // Cores e temas
      'opacidadeOverlay': opacidadeOverlay,
      'opacidadeDesabilitado': opacidadeDesabilitado,
      'elevacaoPadrao': elevacaoPadrao,
      'elevacaoFoco': elevacaoFoco,
      
      // Validação
      'maxTituloLength': maxTituloLength,
      'maxAnotacoesLength': maxAnotacoesLength,
      'maxTagsPorSessao': maxTagsPorSessao,
      
      // Cache e performance
      'cacheExpiryMinutes': cacheExpiryMinutes,
      'maxCacheSessoes': maxCacheSessoes,
      'intervalAutoSaveSegundos': intervalAutoSaveSegundos,
      
      // Configuração
      'maxTentativasRede': maxTentativasRede,
      'timeoutRedeSegundos': timeoutRedeSegundos,
      'intervalTentativasSegundos': intervalTentativasSegundos,
    };
  }
  
  /// Valida se uma duração está dentro dos limites
  static bool isValidDuration(int minutes) {
    return minutes >= duracaoMinima && minutes <= duracaoMaxima;
  }
  
  /// Valida se um tipo de meditação é válido
  static bool isValidTipo(String tipo) {
    return tiposMeditacao.contains(tipo);
  }
  
  /// Valida se um humor é válido
  static bool isValidHumor(String humor) {
    return humoresDisponiveis.contains(humor) || humoresPosDisponiveis.contains(humor);
  }
  
  /// Valida se um volume está dentro dos limites
  static bool isValidVolume(double volume) {
    return volume >= volumeMinimo && volume <= volumeMaximo;
  }
  
  /// Converte minutos para segundos
  static int minutesToSeconds(int minutes) {
    return minutes * 60;
  }
  
  /// Converte segundos para minutos
  static int secondsToMinutes(int seconds) {
    return (seconds / 60).round();
  }
  
  /// Retorna a duração mais próxima da lista padrão
  static int getNearestDuration(int targetMinutes) {
    if (duracoesPadrao.isEmpty) return duracaoPadraoMinutos;
    
    int nearest = duracoesPadrao.first;
    int minDiff = (targetMinutes - nearest).abs();
    
    for (int duration in duracoesPadrao) {
      int diff = (targetMinutes - duration).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = duration;
      }
    }
    
    return nearest;
  }
}