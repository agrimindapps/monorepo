enum DevelopmentAction {
  simulateData('simulate', 'Simular Dados'),
  removeData('remove', 'Remover Dados'),
  resetSettings('reset', 'Reset Configurações'),
  clearCache('cache', 'Limpar Cache'),
  exportLogs('logs', 'Exportar Logs');

  const DevelopmentAction(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum SimulationScope {
  minimal('minimal', 'Mínimo', '1 animal, 30 dias'),
  standard('standard', 'Padrão', '2 animais, 14 meses'),
  comprehensive('comprehensive', 'Completo', '5 animais, 24 meses'),
  stress('stress', 'Stress Test', '10 animais, 36 meses');

  const SimulationScope(this.id, this.displayName, this.description);
  final String id;
  final String displayName;
  final String description;
}

class SimulationConfig {
  final SimulationScope scope;
  final int animalCount;
  final int monthsOfData;
  final bool includeWeights;
  final bool includeVaccines;
  final bool includeReminders;
  final bool includeMedications;
  final bool includeExpenses;
  final DateTime startDate;

  const SimulationConfig({
    required this.scope,
    required this.animalCount,
    required this.monthsOfData,
    this.includeWeights = true,
    this.includeVaccines = true,
    this.includeReminders = true,
    this.includeMedications = true,
    this.includeExpenses = true,
    required this.startDate,
  });

  SimulationConfig copyWith({
    SimulationScope? scope,
    int? animalCount,
    int? monthsOfData,
    bool? includeWeights,
    bool? includeVaccines,
    bool? includeReminders,
    bool? includeMedications,
    bool? includeExpenses,
    DateTime? startDate,
  }) {
    return SimulationConfig(
      scope: scope ?? this.scope,
      animalCount: animalCount ?? this.animalCount,
      monthsOfData: monthsOfData ?? this.monthsOfData,
      includeWeights: includeWeights ?? this.includeWeights,
      includeVaccines: includeVaccines ?? this.includeVaccines,
      includeReminders: includeReminders ?? this.includeReminders,
      includeMedications: includeMedications ?? this.includeMedications,
      includeExpenses: includeExpenses ?? this.includeExpenses,
      startDate: startDate ?? this.startDate,
    );
  }

  int get estimatedRecords {
    int records = animalCount; // Animals themselves
    
    // Estimate records per animal per month
    if (includeWeights) records += animalCount * monthsOfData * 4; // 4 weights per month
    if (includeVaccines) records += animalCount * (monthsOfData / 3).ceil(); // vaccine every 3 months
    if (includeReminders) records += animalCount * monthsOfData * 2; // 2 reminders per month
    if (includeMedications) records += animalCount * (monthsOfData / 4).ceil(); // medication every 4 months
    if (includeExpenses) records += animalCount * monthsOfData * 3; // 3 expenses per month
    
    return records;
  }

  Duration get estimatedDuration {
    const baseSeconds = 2;
    final recordSeconds = (estimatedRecords * 0.01).ceil();
    return Duration(seconds: baseSeconds + recordSeconds);
  }

  String get scopeDescription {
    return '$animalCount animais, $monthsOfData meses (~$estimatedRecords registros)';
  }

  static SimulationConfig defaultConfig() {
    return SimulationConfig(
      scope: SimulationScope.standard,
      animalCount: 2,
      monthsOfData: 14,
      startDate: DateTime.now().subtract(const Duration(days: 30 * 14)),
    );
  }

  static SimulationConfig fromScope(SimulationScope scope) {
    switch (scope) {
      case SimulationScope.minimal:
        return SimulationConfig(
          scope: scope,
          animalCount: 1,
          monthsOfData: 1,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
        );
      case SimulationScope.standard:
        return SimulationConfig(
          scope: scope,
          animalCount: 2,
          monthsOfData: 14,
          startDate: DateTime.now().subtract(const Duration(days: 30 * 14)),
        );
      case SimulationScope.comprehensive:
        return SimulationConfig(
          scope: scope,
          animalCount: 5,
          monthsOfData: 24,
          startDate: DateTime.now().subtract(const Duration(days: 30 * 24)),
        );
      case SimulationScope.stress:
        return SimulationConfig(
          scope: scope,
          animalCount: 10,
          monthsOfData: 36,
          startDate: DateTime.now().subtract(const Duration(days: 30 * 36)),
        );
    }
  }
}

class SimulationResult {
  final bool success;
  final String? error;
  final Map<String, int> createdRecords;
  final Duration duration;
  final DateTime timestamp;

  const SimulationResult({
    required this.success,
    this.error,
    required this.createdRecords,
    required this.duration,
    required this.timestamp,
  });

  int get totalRecords => createdRecords.values.fold(0, (sum, count) => sum + count);

  String get summary {
    if (!success) return 'Falha na simulação: $error';
    
    final recordsText = '$totalRecords registro${totalRecords > 1 ? 's' : ''}';
    final durationText = '${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}s';
    return '$recordsText criados em $durationText';
  }

  static SimulationResult createSuccess({
    required Map<String, int> createdRecords,
    required Duration duration,
  }) {
    return SimulationResult(
      success: true,
      createdRecords: createdRecords,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  static SimulationResult createFailure({
    required String error,
    required Duration duration,
  }) {
    return SimulationResult(
      success: false,
      error: error,
      createdRecords: const {},
      duration: duration,
      timestamp: DateTime.now(),
    );
  }
}

class DevelopmentStats {
  final int totalSimulations;
  final DateTime? lastSimulation;
  final int totalDataResets;
  final DateTime? lastDataReset;
  final Map<String, int> simulationsByScope;

  const DevelopmentStats({
    this.totalSimulations = 0,
    this.lastSimulation,
    this.totalDataResets = 0,
    this.lastDataReset,
    this.simulationsByScope = const {},
  });

  String get lastSimulationText {
    if (lastSimulation == null) return 'Nunca';
    
    final difference = DateTime.now().difference(lastSimulation!);
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else {
      return 'Hoje';
    }
  }

  String get lastDataResetText {
    if (lastDataReset == null) return 'Nunca';
    
    final difference = DateTime.now().difference(lastDataReset!);
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else {
      return 'Hoje';
    }
  }

  DevelopmentStats copyWith({
    int? totalSimulations,
    DateTime? lastSimulation,
    int? totalDataResets,
    DateTime? lastDataReset,
    Map<String, int>? simulationsByScope,
  }) {
    return DevelopmentStats(
      totalSimulations: totalSimulations ?? this.totalSimulations,
      lastSimulation: lastSimulation ?? this.lastSimulation,
      totalDataResets: totalDataResets ?? this.totalDataResets,
      lastDataReset: lastDataReset ?? this.lastDataReset,
      simulationsByScope: simulationsByScope ?? this.simulationsByScope,
    );
  }
}

class DevelopmentRepository {
  static List<SimulationScope> getAvailableScopes() {
    return SimulationScope.values;
  }

  static List<DevelopmentAction> getAvailableActions() {
    return DevelopmentAction.values;
  }

  static List<String> getAnimalNames() {
    return [
      'Max', 'Luna', 'Charlie', 'Bella', 'Rocky', 'Daisy',
      'Buddy', 'Molly', 'Cooper', 'Lola', 'Bear', 'Sophie',
      'Tucker', 'Chloe', 'Jack', 'Zoey', 'Toby', 'Princess'
    ];
  }

  static List<String> getDogBreeds() {
    return [
      'Golden Retriever', 'Labrador', 'Pastor Alemão', 'Bulldog Francês',
      'Poodle', 'Border Collie', 'Rottweiler', 'Yorkshire Terrier',
      'Beagle', 'Dachshund', 'Siberian Husky', 'Shih Tzu'
    ];
  }

  static List<String> getCatBreeds() {
    return [
      'Persa', 'Siamês', 'Maine Coon', 'Ragdoll',
      'British Shorthair', 'Sphynx', 'Bengala', 'Angora'
    ];
  }

  static List<String> getColors() {
    return [
      'Dourado', 'Preto', 'Branco', 'Marrom', 'Cinza',
      'Chocolate', 'Creme', 'Rajado', 'Tricolor', 'Caramelo'
    ];
  }

  static List<String> getVaccineNames() {
    return [
      'V10', 'V8', 'Antirrábica', 'Gripe Canina', 'Giardia',
      'Tríplice Felina', 'Quíntupla Felina', 'Leucemia Felina'
    ];
  }

  static List<String> getMedicationNames() {
    return [
      'Vermífugo', 'Antipulgas', 'Anti-inflamatório', 'Antibiótico',
      'Vitaminas', 'Probióticos', 'Antialérgico', 'Analgésico'
    ];
  }

  static List<String> getExpenseTypes() {
    return [
      'Consulta', 'Ração', 'Medicamento', 'Brinquedo', 'Vacina',
      'Exame', 'Cirurgia', 'Petshop', 'Transporte', 'Emergência'
    ];
  }

  static List<String> getReminderTypes() {
    return [
      'Consulta', 'Vacina', 'Medicamento', 'Banho', 'Tosa',
      'Vermífugo', 'Antipulgas', 'Exame', 'Pesagem'
    ];
  }

  static String getRandomGender() {
    return ['Macho', 'Fêmea'][DateTime.now().millisecond % 2];
  }

  static double getRandomWeight(String species) {
    final random = DateTime.now().millisecond;
    if (species == 'Cachorro') {
      return 5.0 + (random % 50); // 5-55kg
    } else {
      return 2.0 + (random % 8); // 2-10kg
    }
  }

  static bool shouldGenerateRecord(String recordType, int monthIndex, int recordIndex) {
    switch (recordType) {
      case 'weight':
        return recordIndex % 7 == 0; // Weekly weights
      case 'vaccine':
        return monthIndex % 3 == 0 && recordIndex == 0; // Every 3 months
      case 'medication':
        return monthIndex % 4 == 0 && recordIndex == 1; // Every 4 months
      case 'reminder':
        return recordIndex % 14 == 0; // Bi-weekly reminders
      case 'expense':
        return recordIndex % 10 == 0; // Every 10 days
      default:
        return false;
    }
  }

  static Map<String, String> getWarnings(SimulationConfig config) {
    final warnings = <String, String>{};
    
    if (config.estimatedRecords > 10000) {
      warnings['performance'] = 'Muitos registros podem afetar a performance';
    }
    
    if (config.animalCount > 20) {
      warnings['animals'] = 'Muitos animais podem confundir a interface';
    }
    
    if (config.monthsOfData > 48) {
      warnings['timespan'] = 'Período muito longo pode gerar dados irreais';
    }
    
    return warnings;
  }
}