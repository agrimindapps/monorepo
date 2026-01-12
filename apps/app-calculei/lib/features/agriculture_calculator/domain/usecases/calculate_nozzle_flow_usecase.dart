/// Use case para cálculo de vazão de bicos pulverizadores
library;

import 'package:core/core.dart';

import '../entities/nozzle_flow_calculation.dart';

/// Parâmetros para o cálculo de vazão
class CalculateNozzleFlowParams {
  /// Taxa de aplicação desejada (L/ha)
  final double applicationRate;

  /// Velocidade de trabalho (km/h)
  final double workingSpeed;

  /// Espaçamento entre bicos na barra (cm)
  final double nozzleSpacing;

  /// Pressão de trabalho (bar)
  final double pressure;

  /// Tipo de bico
  final NozzleType nozzleType;

  /// Número de bicos na barra
  final int numberOfNozzles;

  const CalculateNozzleFlowParams({
    required this.applicationRate,
    required this.workingSpeed,
    required this.nozzleSpacing,
    required this.pressure,
    required this.nozzleType,
    required this.numberOfNozzles,
  });
}

/// Use case para calcular vazão de bicos pulverizadores
///
/// Segue o princípio Single Responsibility (SRP):
/// - Responsável apenas pela lógica de cálculo de vazão de bicos
///
/// Regras de Negócio:
/// 1. Vazão (L/min) = (Taxa × Velocidade × Espaçamento) / 60000
/// 2. Códigos de cor por faixa de vazão (ISO):
///    - Laranja: 0.4-0.6 L/min
///    - Verde: 0.6-0.8 L/min
///    - Amarelo: 0.8-1.2 L/min
///    - Azul: 1.2-1.6 L/min
///    - Vermelho: 1.6-2.0 L/min
///    - Marrom: 2.0-2.5 L/min
///    - Cinza: 2.5-3.2 L/min
///    - Branco: 3.2-4.0 L/min
///    - Roxo: 4.0-5.0 L/min
/// 3. Fator de ajuste de pressão (simplificado)
class CalculateNozzleFlowUseCase {
  /// Executa o cálculo de vazão
  ///
  /// Retorna:
  /// - Right(NozzleFlowCalculation) se o cálculo for bem-sucedido
  /// - Left(ValidationFailure) se houver erro de validação
  Future<Either<Failure, NozzleFlowCalculation>> call(
    CalculateNozzleFlowParams params,
  ) async {
    // 1. VALIDAÇÃO
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    // 2. CÁLCULO
    try {
      final calculation = _performCalculation(params);
      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo de vazão: $e'));
    }
  }

  /// Valida os parâmetros de entrada
  ValidationFailure? _validate(CalculateNozzleFlowParams params) {
    // Validação da taxa de aplicação
    if (params.applicationRate <= 0) {
      return const ValidationFailure(
        'Taxa de aplicação deve ser maior que zero',
      );
    }

    if (params.applicationRate > 1000) {
      return const ValidationFailure(
        'Taxa de aplicação não pode exceder 1000 L/ha',
      );
    }

    // Validação da velocidade
    if (params.workingSpeed <= 0) {
      return const ValidationFailure(
        'Velocidade de trabalho deve ser maior que zero',
      );
    }

    if (params.workingSpeed > 30) {
      return const ValidationFailure(
        'Velocidade de trabalho não pode exceder 30 km/h',
      );
    }

    // Validação do espaçamento
    if (params.nozzleSpacing <= 0) {
      return const ValidationFailure(
        'Espaçamento entre bicos deve ser maior que zero',
      );
    }

    if (params.nozzleSpacing > 200) {
      return const ValidationFailure(
        'Espaçamento entre bicos não pode exceder 200 cm',
      );
    }

    // Validação da pressão
    if (params.pressure <= 0) {
      return const ValidationFailure(
        'Pressão de trabalho deve ser maior que zero',
      );
    }

    if (params.pressure > 10) {
      return const ValidationFailure(
        'Pressão de trabalho não pode exceder 10 bar',
      );
    }

    // Validação do número de bicos
    if (params.numberOfNozzles <= 0) {
      return const ValidationFailure(
        'Número de bicos deve ser maior que zero',
      );
    }

    if (params.numberOfNozzles > 100) {
      return const ValidationFailure(
        'Número de bicos não pode exceder 100',
      );
    }

    return null;
  }

  /// Executa o cálculo de vazão
  NozzleFlowCalculation _performCalculation(CalculateNozzleFlowParams params) {
    // Fórmula: Vazão (L/min) = (Taxa × Velocidade × Espaçamento) / 60000
    // onde:
    // - Taxa = L/ha
    // - Velocidade = km/h
    // - Espaçamento = cm
    // - 60000 = fator de conversão
    
    final requiredFlow = (params.applicationRate * 
                         params.workingSpeed * 
                         params.nozzleSpacing) / 60000;

    // Ajuste de pressão (simplificado)
    // Pressão ideal varia por tipo de bico:
    // - Leque: 2-4 bar
    // - Cone Vazio: 3-5 bar
    // - Cone Cheio: 3-5 bar
    // - Jato Plano: 2-3 bar
    final pressureAdjustment = _calculatePressureAdjustment(
      params.pressure,
      params.nozzleType,
    );

    final adjustedFlow = requiredFlow * pressureAdjustment;

    // Determina o código de cor recomendado
    final recommendedNozzle = NozzleColorCode.fromFlow(adjustedFlow);

    // Calcula vazão total da barra
    final totalFlow = adjustedFlow * params.numberOfNozzles;

    // Calcula largura de trabalho (metros)
    final workingWidth = (params.nozzleSpacing * params.numberOfNozzles) / 100;

    // Calcula taxa de aplicação confirmada
    final confirmedApplicationRate = 
        (adjustedFlow * 60000) / (params.workingSpeed * params.nozzleSpacing);

    // Gera dicas de calibração
    final tips = _generateCalibrationTips(
      params,
      adjustedFlow,
      recommendedNozzle,
      pressureAdjustment,
    );

    return NozzleFlowCalculation(
      applicationRate: params.applicationRate,
      workingSpeed: params.workingSpeed,
      nozzleSpacing: params.nozzleSpacing,
      pressure: params.pressure,
      nozzleType: params.nozzleType,
      numberOfNozzles: params.numberOfNozzles,
      requiredFlow: adjustedFlow,
      recommendedNozzle: recommendedNozzle,
      totalFlow: totalFlow,
      workingWidth: workingWidth,
      confirmedApplicationRate: confirmedApplicationRate,
      calibrationTips: tips,
    );
  }

  /// Calcula fator de ajuste baseado na pressão
  double _calculatePressureAdjustment(double pressure, NozzleType nozzleType) {
    // Pressões ideais por tipo de bico
    final idealPressures = <NozzleType, double>{
      NozzleType.fanJet: 3.0,
      NozzleType.hollowCone: 4.0,
      NozzleType.fullCone: 4.0,
      NozzleType.flatJet: 2.5,
    };

    final idealPressure = idealPressures[nozzleType]!;
    
    // Fator de ajuste baseado na relação entre pressão real e ideal
    // Vazão é proporcional à raiz quadrada da pressão
    return (pressure / idealPressure).clamp(0.5, 1.5);
  }

  /// Gera dicas de calibração personalizadas
  List<String> _generateCalibrationTips(
    CalculateNozzleFlowParams params,
    double adjustedFlow,
    NozzleColorCode? recommendedNozzle,
    double pressureAdjustment,
  ) {
    final tips = <String>[];

    // Dica sobre código de cor
    if (recommendedNozzle != null) {
      tips.add(
        'Utilize bico de cor ${recommendedNozzle.displayName} '
        '(${recommendedNozzle.minFlow.toStringAsFixed(1)}-'
        '${recommendedNozzle.maxFlow.toStringAsFixed(1)} L/min)',
      );
    } else {
      tips.add(
        'Vazão de ${adjustedFlow.toStringAsFixed(2)} L/min fora do padrão ISO. '
        'Verifique os parâmetros.',
      );
    }

    // Dica sobre pressão
    final pressureRanges = <NozzleType, String>{
      NozzleType.fanJet: '2-4 bar',
      NozzleType.hollowCone: '3-5 bar',
      NozzleType.fullCone: '3-5 bar',
      NozzleType.flatJet: '2-3 bar',
    };

    final idealRange = pressureRanges[params.nozzleType]!;
    
    if (pressureAdjustment < 0.9 || pressureAdjustment > 1.1) {
      tips.add(
        'Pressão de trabalho ideal para bico ${params.nozzleType.displayName}: $idealRange',
      );
    }

    // Dica sobre velocidade
    if (params.workingSpeed < 4) {
      tips.add('Velocidade baixa pode melhorar a cobertura');
    } else if (params.workingSpeed > 10) {
      tips.add('Velocidade alta pode reduzir a qualidade da aplicação');
    }

    // Dica sobre espaçamento
    if (params.nozzleSpacing < 40) {
      tips.add('Espaçamento pequeno aumenta a sobreposição');
    } else if (params.nozzleSpacing > 60) {
      tips.add('Espaçamento grande pode reduzir a uniformidade');
    }

    // Dica sobre calibração
    tips.add(
      'Realize calibração periódica verificando a vazão de cada bico',
    );

    // Dica sobre volume total
    if (params.applicationRate < 100) {
      tips.add('Volume baixo: ideal para produtos sistêmicos');
    } else if (params.applicationRate > 300) {
      tips.add('Volume alto: maior cobertura, ideal para herbicidas de contato');
    }

    return tips;
  }
}
