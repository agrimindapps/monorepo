/// Calculadora de Necessidade Hídrica de Culturas
/// Calcula volume de água necessário para irrigação
library;

enum IrrigationCropType {
  corn, // Milho
  soybean, // Soja
  wheat, // Trigo
  rice, // Arroz
  beans, // Feijão
  coffee, // Café
  sugarcane, // Cana
  tomato, // Tomate
  lettuce, // Alface
  citrus, // Citros
}

enum CropStage {
  initial, // Inicial
  development, // Desenvolvimento
  mid, // Intermediário
  late, // Final
}

enum IrrigationSystem {
  sprinkler, // Aspersão
  drip, // Gotejamento
  microsprinkler, // Microaspersão
  centerPivot, // Pivô central
  flood, // Inundação
}

class IrrigationResult {
  /// Evapotranspiração da cultura (mm/dia)
  final double etcMmDay;

  /// Volume diário (litros/dia)
  final double dailyVolumeLiters;

  /// Volume diário (m³/dia)
  final double dailyVolumeM3;

  /// Volume semanal (litros)
  final double weeklyVolumeLiters;

  /// Lâmina de água por hectare (mm)
  final double waterDepthMm;

  /// Tempo de irrigação estimado (horas)
  final double irrigationTimeHours;

  /// Frequência recomendada (dias)
  final int frequencyDays;

  /// Recomendações
  final List<String> recommendations;

  const IrrigationResult({
    required this.etcMmDay,
    required this.dailyVolumeLiters,
    required this.dailyVolumeM3,
    required this.weeklyVolumeLiters,
    required this.waterDepthMm,
    required this.irrigationTimeHours,
    required this.frequencyDays,
    required this.recommendations,
  });
}

class IrrigationCalculator {
  // Coeficiente de cultura (Kc) por estágio
  static const Map<IrrigationCropType, Map<CropStage, double>> cropKc = {
    IrrigationCropType.corn: {
      CropStage.initial: 0.40,
      CropStage.development: 0.80,
      CropStage.mid: 1.20,
      CropStage.late: 0.60,
    },
    IrrigationCropType.soybean: {
      CropStage.initial: 0.35,
      CropStage.development: 0.75,
      CropStage.mid: 1.15,
      CropStage.late: 0.50,
    },
    IrrigationCropType.wheat: {
      CropStage.initial: 0.35,
      CropStage.development: 0.75,
      CropStage.mid: 1.15,
      CropStage.late: 0.40,
    },
    IrrigationCropType.rice: {
      CropStage.initial: 1.05,
      CropStage.development: 1.20,
      CropStage.mid: 1.20,
      CropStage.late: 0.90,
    },
    IrrigationCropType.beans: {
      CropStage.initial: 0.35,
      CropStage.development: 0.70,
      CropStage.mid: 1.10,
      CropStage.late: 0.30,
    },
    IrrigationCropType.coffee: {
      CropStage.initial: 0.90,
      CropStage.development: 0.95,
      CropStage.mid: 1.00,
      CropStage.late: 0.95,
    },
    IrrigationCropType.sugarcane: {
      CropStage.initial: 0.50,
      CropStage.development: 0.85,
      CropStage.mid: 1.25,
      CropStage.late: 0.75,
    },
    IrrigationCropType.tomato: {
      CropStage.initial: 0.45,
      CropStage.development: 0.75,
      CropStage.mid: 1.15,
      CropStage.late: 0.80,
    },
    IrrigationCropType.lettuce: {
      CropStage.initial: 0.45,
      CropStage.development: 0.60,
      CropStage.mid: 1.00,
      CropStage.late: 0.90,
    },
    IrrigationCropType.citrus: {
      CropStage.initial: 0.65,
      CropStage.development: 0.65,
      CropStage.mid: 0.65,
      CropStage.late: 0.65,
    },
  };

  // Eficiência por sistema de irrigação
  static const Map<IrrigationSystem, double> systemEfficiency = {
    IrrigationSystem.sprinkler: 0.75,
    IrrigationSystem.drip: 0.90,
    IrrigationSystem.microsprinkler: 0.85,
    IrrigationSystem.centerPivot: 0.80,
    IrrigationSystem.flood: 0.60,
  };

  static const Map<IrrigationCropType, String> cropNames = {
    IrrigationCropType.corn: 'Milho',
    IrrigationCropType.soybean: 'Soja',
    IrrigationCropType.wheat: 'Trigo',
    IrrigationCropType.rice: 'Arroz',
    IrrigationCropType.beans: 'Feijão',
    IrrigationCropType.coffee: 'Café',
    IrrigationCropType.sugarcane: 'Cana-de-açúcar',
    IrrigationCropType.tomato: 'Tomate',
    IrrigationCropType.lettuce: 'Alface',
    IrrigationCropType.citrus: 'Citros',
  };

  static const Map<CropStage, String> stageNames = {
    CropStage.initial: 'Inicial',
    CropStage.development: 'Desenvolvimento',
    CropStage.mid: 'Intermediário',
    CropStage.late: 'Final',
  };

  static const Map<IrrigationSystem, String> systemNames = {
    IrrigationSystem.sprinkler: 'Aspersão',
    IrrigationSystem.drip: 'Gotejamento',
    IrrigationSystem.microsprinkler: 'Microaspersão',
    IrrigationSystem.centerPivot: 'Pivô Central',
    IrrigationSystem.flood: 'Inundação',
  };

  /// Calcula necessidade hídrica
  /// ETo = Evapotranspiração de referência (mm/dia) - típico 4-6 mm/dia
  static IrrigationResult calculate({
    required IrrigationCropType crop,
    required CropStage stage,
    required double etoMmDay, // Evapotranspiração de referência
    required double areaHa,
    required IrrigationSystem system,
    double flowRateLitersHour = 10000, // Vazão do sistema
  }) {
    final kc = cropKc[crop]![stage]!;
    final efficiency = systemEfficiency[system]!;

    // ETc = ETo × Kc
    final etcMmDay = etoMmDay * kc;

    // Volume necessário considerando eficiência
    // 1 mm/ha = 10.000 litros
    final waterDepthMm = etcMmDay / efficiency;
    final dailyVolumeLiters = waterDepthMm * areaHa * 10000;
    final dailyVolumeM3 = dailyVolumeLiters / 1000;
    final weeklyVolumeLiters = dailyVolumeLiters * 7;

    // Tempo de irrigação
    final irrigationTimeHours = dailyVolumeLiters / flowRateLitersHour;

    // Frequência recomendada baseada no sistema
    final frequencyDays = _getFrequency(system, etcMmDay);

    final recommendations = _getRecommendations(
      crop,
      stage,
      system,
      etcMmDay,
    );

    return IrrigationResult(
      etcMmDay: double.parse(etcMmDay.toStringAsFixed(2)),
      dailyVolumeLiters: double.parse(dailyVolumeLiters.toStringAsFixed(0)),
      dailyVolumeM3: double.parse(dailyVolumeM3.toStringAsFixed(1)),
      weeklyVolumeLiters: double.parse(weeklyVolumeLiters.toStringAsFixed(0)),
      waterDepthMm: double.parse(waterDepthMm.toStringAsFixed(2)),
      irrigationTimeHours: double.parse(irrigationTimeHours.toStringAsFixed(1)),
      frequencyDays: frequencyDays,
      recommendations: recommendations,
    );
  }

  static int _getFrequency(IrrigationSystem system, double etc) {
    // Frequência baseada no sistema e demanda
    if (system == IrrigationSystem.drip) return 1; // Diário
    if (system == IrrigationSystem.microsprinkler) return 2;
    if (etc > 6) return 2; // Alta demanda
    if (etc > 4) return 3; // Média demanda
    return 4; // Baixa demanda
  }

  static List<String> _getRecommendations(
    IrrigationCropType crop,
    CropStage stage,
    IrrigationSystem system,
    double etc,
  ) {
    final recs = <String>[];

    // Por estágio
    if (stage == CropStage.mid) {
      recs.add('Fase crítica - manter umidade adequada do solo');
    }
    if (stage == CropStage.initial) {
      recs.add('Irrigações leves e frequentes para estabelecimento');
    }

    // Por demanda
    if (etc > 6) {
      recs.add('⚠️ Alta demanda evaporativa - aumentar frequência');
    }

    // Por sistema
    if (system == IrrigationSystem.drip) {
      recs.add('Verificar entupimento dos gotejadores regularmente');
    }
    if (system == IrrigationSystem.sprinkler) {
      recs.add('Evitar irrigação em horários de vento forte');
      recs.add('Irrigar preferencialmente de manhã cedo');
    }

    // Gerais
    recs.add('Monitorar umidade do solo com tensiômetro');
    recs.add('Ajustar irrigação conforme previsão de chuvas');

    return recs;
  }

  static String getCropName(IrrigationCropType crop) => cropNames[crop]!;
  static String getStageName(CropStage stage) => stageNames[stage]!;
  static String getSystemName(IrrigationSystem system) => systemNames[system]!;
}
