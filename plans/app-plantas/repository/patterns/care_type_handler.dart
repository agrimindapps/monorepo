// Project imports:
import '../../constants/care_type_const.dart';
import '../../core/validation/result.dart';
import '../../database/planta_config_model.dart';

/// Strategy pattern para tipos de cuidado
///
/// Este sistema centraliza a lógica específica de cada tipo de cuidado,
/// eliminando switch cases longos e facilitando extensibilidade.
abstract class CareTypeHandler {
  /// Tipo de cuidado que este handler gerencia
  String get careType;

  /// Nome amigável do tipo de cuidado
  String get displayName;

  /// Intervalo padrão em dias para este tipo de cuidado
  int get defaultInterval;

  /// Ativar este tipo de cuidado na configuração
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval});

  /// Desativar este tipo de cuidado na configuração
  PlantaConfigModel deactivate(PlantaConfigModel config);

  /// Atualizar intervalo deste tipo de cuidado
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval);

  /// Verificar se este tipo de cuidado está ativo na configuração
  bool isActive(PlantaConfigModel config);

  /// Obter intervalo atual deste tipo de cuidado
  int? getCurrentInterval(PlantaConfigModel config);

  /// Validar intervalo para este tipo de cuidado
  Result<int> validateInterval(int interval) {
    if (interval < 1 || interval > 365) {
      return Result.error(OutOfRangeError(
        'interval',
        'Intervalo deve estar entre 1 e 365 dias (recebido: $interval)',
      ));
    }
    return Result.success(interval);
  }

  /// Obter próxima data de execução baseada na última execução e intervalo
  DateTime? getNextExecutionDate(
      DateTime? lastExecution, PlantaConfigModel config) {
    if (lastExecution == null) return null;
    final interval = getCurrentInterval(config);
    if (interval == null) return null;
    return lastExecution.add(Duration(days: interval));
  }
}

/// Factory para criar handlers específicos por tipo de cuidado
class CareTypeHandlerFactory {
  static final Map<String, CareTypeHandler> _handlers = {
    CareType.agua.value: WaterCareHandler(),
    CareType.adubo.value: FertilizerCareHandler(),
    CareType.banhoSol.value: SunBathCareHandler(),
    CareType.inspecaoPragas.value: PestInspectionCareHandler(),
    CareType.poda.value: PruningCareHandler(),
    CareType.replantio.value: ReplantingCareHandler(),
  };

  /// Obter handler para tipo de cuidado específico
  static CareTypeHandler? getHandler(String careType) => _handlers[careType];

  /// Obter todos os handlers disponíveis
  static List<CareTypeHandler> getAllHandlers() => _handlers.values.toList();

  /// Obter todos os tipos de cuidado válidos
  static List<String> getValidCareTypes() => _handlers.keys.toList();

  /// Verificar se tipo de cuidado é válido
  /// Usa CareType.isValidCareType para garantir consistência
  static bool isValidCareType(String careType) =>
      CareType.isValidCareType(careType);
}

/// Handler para cuidado com água
class WaterCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.agua.value;

  @override
  String get displayName => 'Rega';

  @override
  int get defaultInterval => 7; // Padrão: regar a cada 7 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      aguaAtiva: true,
      intervaloRegaDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      aguaAtiva: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloRegaDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.aguaAtiva;

  @override
  int? getCurrentInterval(PlantaConfigModel config) => config.intervaloRegaDias;
}

/// Handler para cuidado com adubo
class FertilizerCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.adubo.value;

  @override
  String get displayName => 'Adubação';

  @override
  int get defaultInterval => 30; // Padrão: adubar a cada 30 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      aduboAtivo: true,
      intervaloAdubacaoDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      aduboAtivo: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloAdubacaoDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.aduboAtivo;

  @override
  int? getCurrentInterval(PlantaConfigModel config) =>
      config.intervaloAdubacaoDias;
}

/// Handler para cuidado com banho de sol
class SunBathCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.banhoSol.value;

  @override
  String get displayName => 'Banho de Sol';

  @override
  int get defaultInterval => 3; // Padrão: banho de sol a cada 3 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      banhoSolAtivo: true,
      intervaloBanhoSolDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      banhoSolAtivo: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloBanhoSolDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.banhoSolAtivo;

  @override
  int? getCurrentInterval(PlantaConfigModel config) =>
      config.intervaloBanhoSolDias;
}

/// Handler para cuidado com inspeção de pragas
class PestInspectionCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.inspecaoPragas.value;

  @override
  String get displayName => 'Inspeção de Pragas';

  @override
  int get defaultInterval => 14; // Padrão: inspeção a cada 14 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      inspecaoPragasAtiva: true,
      intervaloInspecaoPragasDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      inspecaoPragasAtiva: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloInspecaoPragasDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.inspecaoPragasAtiva;

  @override
  int? getCurrentInterval(PlantaConfigModel config) =>
      config.intervaloInspecaoPragasDias;
}

/// Handler para cuidado com poda
class PruningCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.poda.value;

  @override
  String get displayName => 'Poda';

  @override
  int get defaultInterval => 60; // Padrão: poda a cada 60 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      podaAtiva: true,
      intervaloPodaDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      podaAtiva: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloPodaDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.podaAtiva;

  @override
  int? getCurrentInterval(PlantaConfigModel config) => config.intervaloPodaDias;
}

/// Handler para cuidado com replantio
class ReplantingCareHandler extends CareTypeHandler {
  @override
  String get careType => CareType.replantio.value;

  @override
  String get displayName => 'Replantio';

  @override
  int get defaultInterval => 180; // Padrão: replantio a cada 180 dias

  @override
  PlantaConfigModel activate(PlantaConfigModel config, {int? customInterval}) {
    return config.copyWith(
      replantarAtivo: true,
      intervaloReplantarDias: customInterval ?? defaultInterval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel deactivate(PlantaConfigModel config) {
    return config.copyWith(
      replantarAtivo: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  PlantaConfigModel updateInterval(PlantaConfigModel config, int interval) {
    return config.copyWith(
      intervaloReplantarDias: interval,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool isActive(PlantaConfigModel config) => config.replantarAtivo;

  @override
  int? getCurrentInterval(PlantaConfigModel config) =>
      config.intervaloReplantarDias;
}
