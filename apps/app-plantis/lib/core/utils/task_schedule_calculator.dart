/// Calculadora avançada para agendamento de tarefas
/// 
/// Responsável por calcular datas futuras para tarefas considerando:
/// - Frequências diárias, semanais, mensais e personalizadas
/// - Fins de semana e feriados (opcional)
/// - Configurações de horário padrão
/// - Validações de frequência mínima/máxima
/// - Ajustes para diferentes tipos de cuidado
class TaskScheduleCalculator {
  static const int _defaultTaskHour = 9; // 9h da manhã
  static const int _defaultTaskMinute = 0;
  
  // Limites de intervalo por tipo de cuidado (em dias)
  static const Map<String, TaskIntervalLimits> _careTypeLimits = {
    'agua': TaskIntervalLimits(minDays: 1, maxDays: 14),
    'adubo': TaskIntervalLimits(minDays: 7, maxDays: 90),
    'poda': TaskIntervalLimits(minDays: 14, maxDays: 180),
    'replantar': TaskIntervalLimits(minDays: 90, maxDays: 730), // 2 anos
    'banho_sol': TaskIntervalLimits(minDays: 1, maxDays: 7),
    'inspecao_pragas': TaskIntervalLimits(minDays: 3, maxDays: 30),
  };

  /// Calcula a próxima data de tarefa baseado no intervalo
  /// 
  /// [baseDate] - Data base para o cálculo (normalmente data de conclusão da tarefa anterior)
  /// [intervalDays] - Intervalo em dias
  /// [careType] - Tipo de cuidado para aplicar regras específicas
  /// [skipWeekends] - Se deve pular fins de semana (padrão: false)
  /// [customHour] - Hora específica (padrão: 9h)
  /// [customMinute] - Minuto específico (padrão: 0)
  static DateTime calculateNextDate({
    required DateTime baseDate,
    required int intervalDays,
    required String careType,
    bool skipWeekends = false,
    int? customHour,
    int? customMinute,
  }) {
    // Validar intervalo
    final validatedInterval = _validateAndAdjustInterval(intervalDays, careType);
    
    // Calcular data base
    var nextDate = baseDate.add(Duration(days: validatedInterval));
    
    // Definir horário padrão
    final hour = customHour ?? _getDefaultHourForCareType(careType);
    final minute = customMinute ?? _defaultTaskMinute;
    
    nextDate = DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      hour,
      minute,
    );
    
    // Ajustar para pular fins de semana se solicitado
    if (skipWeekends) {
      nextDate = _skipWeekends(nextDate);
    }
    
    // Aplicar ajustes específicos por tipo de cuidado
    nextDate = _applyCareTypeAdjustments(nextDate, careType);
    
    return nextDate;
  }

  /// Calcula múltiplas datas futuras
  /// 
  /// Útil para gerar cronograma de tarefas ou preview
  static List<DateTime> calculateMultipleDates({
    required DateTime baseDate,
    required int intervalDays,
    required String careType,
    required int count,
    bool skipWeekends = false,
    int? customHour,
    int? customMinute,
  }) {
    final dates = <DateTime>[];
    var currentBase = baseDate;
    
    for (int i = 0; i < count; i++) {
      final nextDate = calculateNextDate(
        baseDate: currentBase,
        intervalDays: intervalDays,
        careType: careType,
        skipWeekends: skipWeekends,
        customHour: customHour,
        customMinute: customMinute,
      );
      
      dates.add(nextDate);
      currentBase = nextDate;
    }
    
    return dates;
  }

  /// Calcula o próximo dia útil (segunda a sexta)
  static DateTime getNextBusinessDay(DateTime date) {
    var nextDay = date;
    
    while (nextDay.weekday > 5) { // 6 = sábado, 7 = domingo
      nextDay = nextDay.add(const Duration(days: 1));
    }
    
    return nextDay;
  }

  /// Verifica se uma data cai em fim de semana
  static bool isWeekend(DateTime date) {
    return date.weekday > 5; // 6 = sábado, 7 = domingo
  }

  /// Calcula estatísticas de frequência para um período
  static TaskFrequencyStats calculateFrequencyStats({
    required int intervalDays,
    required String careType,
    int periodDays = 30,
  }) {
    final tasksPerPeriod = (periodDays / intervalDays).ceil();
    final averageDaysBetween = intervalDays.toDouble();
    final limits = _careTypeLimits[careType];
    
    return TaskFrequencyStats(
      intervalDays: intervalDays,
      tasksPerPeriod: tasksPerPeriod,
      averageDaysBetween: averageDaysBetween,
      isWithinRecommendedLimits: limits?.isWithinLimits(intervalDays) ?? true,
      recommendedMinDays: limits?.minDays,
      recommendedMaxDays: limits?.maxDays,
    );
  }

  /// Sugere intervalo otimizado baseado no tipo de cuidado e estação do ano
  static int suggestOptimalInterval({
    required String careType,
    DateTime? currentDate,
    String? plantType, // Futuro: usar para ajustes específicos
  }) {
    final now = currentDate ?? DateTime.now();
    final limits = _careTypeLimits[careType];
    
    if (limits == null) {
      return 7; // Padrão semanal
    }
    
    // Ajustar baseado na estação (simplificado para Brasil)
    final isWinter = _isWinter(now);
    final isSummer = _isSummer(now);
    
    int baseInterval = _getBaseIntervalForCareType(careType);
    
    // Ajustes sazonais
    switch (careType) {
      case 'agua':
        if (isSummer) {
          baseInterval = (baseInterval * 0.8).round(); // 20% mais frequente no verão
        } else if (isWinter) {
          baseInterval = (baseInterval * 1.3).round(); // 30% menos frequente no inverno
        }
        break;
      case 'adubo':
        if (isWinter) {
          baseInterval = (baseInterval * 1.5).round(); // Menos adubo no inverno
        }
        break;
      case 'banho_sol':
        if (isWinter) {
          baseInterval = Math.max(1, (baseInterval * 0.7).round()); // Mais sol no inverno
        }
        break;
    }
    
    // Garantir que está dentro dos limites
    return limits.clampToLimits(baseInterval);
  }

  /// Verifica se um intervalo é válido para um tipo de cuidado
  static bool isValidInterval(int intervalDays, String careType) {
    final limits = _careTypeLimits[careType];
    return limits?.isWithinLimits(intervalDays) ?? true;
  }

  /// Obtém os limites recomendados para um tipo de cuidado
  static TaskIntervalLimits? getLimitsForCareType(String careType) {
    return _careTypeLimits[careType];
  }

  // Métodos privados

  static int _validateAndAdjustInterval(int intervalDays, String careType) {
    if (intervalDays <= 0) {
      throw ArgumentError('Intervalo deve ser maior que zero');
    }
    
    final limits = _careTypeLimits[careType];
    if (limits != null) {
      return limits.clampToLimits(intervalDays);
    }
    
    return intervalDays;
  }

  static int _getDefaultHourForCareType(String careType) {
    switch (careType) {
      case 'agua':
        return 7; // Cedo da manhã para rega
      case 'banho_sol':
        return 8; // Manhã para sol
      case 'adubo':
        return 9; // Meio da manhã
      case 'poda':
        return 10; // Meio da manhã
      case 'inspecao_pragas':
        return 9; // Meio da manhã
      case 'replantar':
        return 9; // Meio da manhã
      default:
        return _defaultTaskHour;
    }
  }

  static DateTime _skipWeekends(DateTime date) {
    if (isWeekend(date)) {
      return getNextBusinessDay(date);
    }
    return date;
  }

  static DateTime _applyCareTypeAdjustments(DateTime date, String careType) {
    switch (careType) {
      case 'banho_sol':
        // Evitar sol muito forte (meio-dia às 14h)
        if (date.hour >= 12 && date.hour <= 14) {
          return DateTime(date.year, date.month, date.day, 8, date.minute);
        }
        break;
      case 'rega':
        // Evitar rega no fim do dia
        if (date.hour >= 18) {
          return DateTime(date.year, date.month, date.day, 7, date.minute);
        }
        break;
    }
    
    return date;
  }

  static int _getBaseIntervalForCareType(String careType) {
    switch (careType) {
      case 'agua':
        return 3;
      case 'adubo':
        return 14;
      case 'poda':
        return 30;
      case 'replantar':
        return 180;
      case 'banho_sol':
        return 1;
      case 'inspecao_pragas':
        return 7;
      default:
        return 7;
    }
  }

  static bool _isWinter(DateTime date) {
    // Simplificado para Brasil (Jun-Set)
    return date.month >= 6 && date.month <= 9;
  }

  static bool _isSummer(DateTime date) {
    // Simplificado para Brasil (Dez-Mar)
    return date.month >= 12 || date.month <= 3;
  }
}

/// Limites de intervalo para um tipo de cuidado
class TaskIntervalLimits {
  final int minDays;
  final int maxDays;

  const TaskIntervalLimits({
    required this.minDays,
    required this.maxDays,
  });

  bool isWithinLimits(int days) {
    return days >= minDays && days <= maxDays;
  }

  int clampToLimits(int days) {
    if (days < minDays) return minDays;
    if (days > maxDays) return maxDays;
    return days;
  }

  @override
  String toString() {
    return 'TaskIntervalLimits(min: ${minDays}d, max: ${maxDays}d)';
  }
}

/// Estatísticas de frequência de tarefas
class TaskFrequencyStats {
  final int intervalDays;
  final int tasksPerPeriod;
  final double averageDaysBetween;
  final bool isWithinRecommendedLimits;
  final int? recommendedMinDays;
  final int? recommendedMaxDays;

  const TaskFrequencyStats({
    required this.intervalDays,
    required this.tasksPerPeriod,
    required this.averageDaysBetween,
    required this.isWithinRecommendedLimits,
    this.recommendedMinDays,
    this.recommendedMaxDays,
  });

  /// Se a frequência é considerada alta (mais de 15 tarefas por mês)
  bool get isHighFrequency => tasksPerPeriod > 15;

  /// Se a frequência é considerada baixa (menos de 2 tarefas por mês)
  bool get isLowFrequency => tasksPerPeriod < 2;

  /// Se a frequência é considerada normal
  bool get isNormalFrequency => !isHighFrequency && !isLowFrequency;

  @override
  String toString() {
    return 'TaskFrequencyStats(interval: ${intervalDays}d, tasksPerMonth: $tasksPerPeriod, withinLimits: $isWithinRecommendedLimits)';
  }
}

/// Classe utilitária para operações matemáticas
class Math {
  static int max(int a, int b) => a > b ? a : b;
  static int min(int a, int b) => a < b ? a : b;
}