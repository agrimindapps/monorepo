/// Entidade de cálculo de vazão de bicos pulverizadores
/// Representa o resultado completo do cálculo de vazão
library;

import 'package:equatable/equatable.dart';

/// Tipo de bico pulverizador
enum NozzleType {
  fanJet('Leque'),
  hollowCone('Cone Vazio'),
  fullCone('Cone Cheio'),
  flatJet('Jato Plano');

  const NozzleType(this.displayName);
  final String displayName;
}

/// Código de cor do bico por faixa de vazão (padrão ISO)
enum NozzleColorCode {
  orange('Laranja', 0.4, 0.6),
  green('Verde', 0.6, 0.8),
  yellow('Amarelo', 0.8, 1.2),
  blue('Azul', 1.2, 1.6),
  red('Vermelho', 1.6, 2.0),
  brown('Marrom', 2.0, 2.5),
  gray('Cinza', 2.5, 3.2),
  white('Branco', 3.2, 4.0),
  purple('Roxo', 4.0, 5.0);

  const NozzleColorCode(this.displayName, this.minFlow, this.maxFlow);
  
  /// Nome para exibição
  final String displayName;
  
  /// Vazão mínima (L/min)
  final double minFlow;
  
  /// Vazão máxima (L/min)
  final double maxFlow;

  /// Retorna a cor do código do bico
  int get colorValue {
    switch (this) {
      case NozzleColorCode.orange:
        return 0xFFFF9800;
      case NozzleColorCode.green:
        return 0xFF4CAF50;
      case NozzleColorCode.yellow:
        return 0xFFFFEB3B;
      case NozzleColorCode.blue:
        return 0xFF2196F3;
      case NozzleColorCode.red:
        return 0xFFF44336;
      case NozzleColorCode.brown:
        return 0xFF795548;
      case NozzleColorCode.gray:
        return 0xFF9E9E9E;
      case NozzleColorCode.white:
        return 0xFFFFFFFF;
      case NozzleColorCode.purple:
        return 0xFF9C27B0;
    }
  }

  /// Determina o código de cor com base na vazão
  static NozzleColorCode? fromFlow(double flowRate) {
    for (final code in NozzleColorCode.values) {
      if (flowRate >= code.minFlow && flowRate <= code.maxFlow) {
        return code;
      }
    }
    return null;
  }
}

/// Resultado do cálculo de vazão de bicos
class NozzleFlowCalculation extends Equatable {
  /// Taxa de aplicação (L/ha)
  final double applicationRate;

  /// Velocidade de trabalho (km/h)
  final double workingSpeed;

  /// Espaçamento entre bicos (cm)
  final double nozzleSpacing;

  /// Pressão de trabalho (bar)
  final double pressure;

  /// Tipo de bico
  final NozzleType nozzleType;

  /// Número de bicos na barra
  final int numberOfNozzles;

  /// Vazão requerida por bico (L/min)
  final double requiredFlow;

  /// Código de cor recomendado do bico
  final NozzleColorCode? recommendedNozzle;

  /// Vazão total da barra (L/min)
  final double totalFlow;

  /// Largura de trabalho da barra (metros)
  final double workingWidth;

  /// Volume de calda por hectare confirmado (L/ha)
  final double confirmedApplicationRate;

  /// Dicas de calibração
  final List<String> calibrationTips;

  const NozzleFlowCalculation({
    required this.applicationRate,
    required this.workingSpeed,
    required this.nozzleSpacing,
    required this.pressure,
    required this.nozzleType,
    required this.numberOfNozzles,
    required this.requiredFlow,
    this.recommendedNozzle,
    required this.totalFlow,
    required this.workingWidth,
    required this.confirmedApplicationRate,
    required this.calibrationTips,
  });

  /// Factory para criar cálculo vazio
  factory NozzleFlowCalculation.empty() => const NozzleFlowCalculation(
        applicationRate: 0,
        workingSpeed: 0,
        nozzleSpacing: 0,
        pressure: 0,
        nozzleType: NozzleType.fanJet,
        numberOfNozzles: 0,
        requiredFlow: 0,
        recommendedNozzle: null,
        totalFlow: 0,
        workingWidth: 0,
        confirmedApplicationRate: 0,
        calibrationTips: [],
      );

  @override
  List<Object?> get props => [
        applicationRate,
        workingSpeed,
        nozzleSpacing,
        pressure,
        nozzleType,
        numberOfNozzles,
        requiredFlow,
        recommendedNozzle,
        totalFlow,
        workingWidth,
        confirmedApplicationRate,
        calibrationTips,
      ];

  NozzleFlowCalculation copyWith({
    double? applicationRate,
    double? workingSpeed,
    double? nozzleSpacing,
    double? pressure,
    NozzleType? nozzleType,
    int? numberOfNozzles,
    double? requiredFlow,
    NozzleColorCode? recommendedNozzle,
    double? totalFlow,
    double? workingWidth,
    double? confirmedApplicationRate,
    List<String>? calibrationTips,
  }) {
    return NozzleFlowCalculation(
      applicationRate: applicationRate ?? this.applicationRate,
      workingSpeed: workingSpeed ?? this.workingSpeed,
      nozzleSpacing: nozzleSpacing ?? this.nozzleSpacing,
      pressure: pressure ?? this.pressure,
      nozzleType: nozzleType ?? this.nozzleType,
      numberOfNozzles: numberOfNozzles ?? this.numberOfNozzles,
      requiredFlow: requiredFlow ?? this.requiredFlow,
      recommendedNozzle: recommendedNozzle ?? this.recommendedNozzle,
      totalFlow: totalFlow ?? this.totalFlow,
      workingWidth: workingWidth ?? this.workingWidth,
      confirmedApplicationRate:
          confirmedApplicationRate ?? this.confirmedApplicationRate,
      calibrationTips: calibrationTips ?? this.calibrationTips,
    );
  }
}
