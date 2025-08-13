// Project imports:
import '../../constants/care_type_const.dart';
import '../../database/planta_config_model.dart';
import 'result.dart';

/// Validador específico para PlantaConfigModel
class PlantaConfigValidator {
  static PlantaConfigValidator? _instance;
  static PlantaConfigValidator get instance =>
      _instance ??= PlantaConfigValidator._();

  PlantaConfigValidator._();

  /// Constantes de validação
  static const int _minIntervaloDias = 1;
  static const int _maxIntervaloDias = 365;

  /// Tipos de cuidado válidos
  /// Usa CareType.allValidStrings para garantir consistência
  static Set<String> get _validCareTypes => CareType.allValidStrings.toSet();

  /// Valida PlantaConfigModel completo
  Result<PlantaConfigModel> validate(PlantaConfigModel config) {
    final validations = [
      _validatePlantaId(config.plantaId),
      _validateIntervalos(config),
      _validateConsistency(config),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(config);
  }

  /// Valida dados para criação
  Result<PlantaConfigModel> validateForCreate(PlantaConfigModel config) {
    final validations = [
      _validatePlantaId(config.plantaId),
      _validateIntervalos(config),
      _validateConsistency(config),
      _validateCreateSpecific(config),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(config);
  }

  /// Valida dados para atualização
  Result<PlantaConfigModel> validateForUpdate(PlantaConfigModel config) {
    final validations = [
      _validatePlantaId(config.plantaId),
      _validateIntervalos(config),
      _validateConsistency(config),
      _validateUpdateSpecific(config),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(config);
  }

  /// Valida se planta existe
  Future<Result<void>> validatePlantaExists(
    String plantaId,
    Future<bool> Function(String) plantaExistsFunction,
  ) async {
    if (plantaId.trim().isEmpty) {
      return Result.error(const RequiredFieldError('plantaId'));
    }

    try {
      final exists = await plantaExistsFunction(plantaId);
      if (!exists) {
        return Result.error(const InvalidReferenceError('plantaId', 'Planta'));
      }
      return Result.success(null);
    } catch (e) {
      return Result.error(InvalidFormatError(
        'plantaId',
        'erro ao verificar existência da planta: $e',
      ));
    }
  }

  /// Valida tipo de cuidado
  Result<void> validateCareType(String tipoCuidado) {
    if (tipoCuidado.trim().isEmpty) {
      return Result.error(const RequiredFieldError('tipoCuidado'));
    }

    if (!_validCareTypes.contains(tipoCuidado)) {
      return Result.error(
          InvalidStateError('tipoCuidado', _validCareTypes.join(', ')));
    }

    return Result.success(null);
  }

  /// Valida intervalo de cuidado
  Result<void> validateCareInterval(int intervaloDias, String tipoCuidado) {
    if (intervaloDias < _minIntervaloDias ||
        intervaloDias > _maxIntervaloDias) {
      return Result.error(OutOfRangeError(
        'intervalo$tipoCuidado',
        '$_minIntervaloDias a $_maxIntervaloDias dias',
      ));
    }

    return Result.success(null);
  }

  /// Validações privadas

  Result<void> _validatePlantaId(String plantaId) {
    if (plantaId.trim().isEmpty) {
      return Result.error(const RequiredFieldError('plantaId'));
    }

    if (!_isValidId(plantaId)) {
      return Result.error(const InvalidFormatError('plantaId', 'ID válido'));
    }

    return Result.success(null);
  }

  Result<void> _validateIntervalos(PlantaConfigModel config) {
    final intervalos = [
      (CareType.agua.value, config.intervaloRegaDias, config.aguaAtiva),
      (CareType.adubo.value, config.intervaloAdubacaoDias, config.aduboAtivo),
      (
        CareType.banhoSol.value,
        config.intervaloBanhoSolDias,
        config.banhoSolAtivo
      ),
      (
        CareType.inspecaoPragas.value,
        config.intervaloInspecaoPragasDias,
        config.inspecaoPragasAtiva
      ),
      (CareType.poda.value, config.intervaloPodaDias, config.podaAtiva),
      (
        CareType.replantio.value,
        config.intervaloReplantarDias,
        config.replantarAtivo
      ),
    ];

    for (final (tipo, intervalo, ativo) in intervalos) {
      if (ativo) {
        final validation = validateCareInterval(intervalo, tipo);
        if (validation.isError) {
          return validation;
        }
      }
    }

    return Result.success(null);
  }

  Result<void> _validateConsistency(PlantaConfigModel config) {
    // Verificar se pelo menos um cuidado está ativo
    final hasAnyCareActive = config.aguaAtiva ||
        config.aduboAtivo ||
        config.banhoSolAtivo ||
        config.inspecaoPragasAtiva ||
        config.podaAtiva ||
        config.replantarAtivo;

    if (!hasAnyCareActive) {
      return Result.error(const InvalidStateError(
        'cuidados',
        'pelo menos um tipo de cuidado deve estar ativo',
      ));
    }

    // Verificar consistência entre status ativo e intervalo
    final inconsistencies = <String>[];

    if (config.aguaAtiva && config.intervaloRegaDias <= 0) {
      inconsistencies.add(CareType.agua.value);
    }
    if (config.aduboAtivo && config.intervaloAdubacaoDias <= 0) {
      inconsistencies.add(CareType.adubo.value);
    }
    if (config.banhoSolAtivo && config.intervaloBanhoSolDias <= 0) {
      inconsistencies.add(CareType.banhoSol.value);
    }
    if (config.inspecaoPragasAtiva && config.intervaloInspecaoPragasDias <= 0) {
      inconsistencies.add('inspecao_pragas');
    }
    if (config.podaAtiva && config.intervaloPodaDias <= 0) {
      inconsistencies.add('poda');
    }
    if (config.replantarAtivo && config.intervaloReplantarDias <= 0) {
      inconsistencies.add('replantar');
    }

    if (inconsistencies.isNotEmpty) {
      return Result.error(InvalidStateError(
        'intervalos',
        'cuidados ativos devem ter intervalo válido: ${inconsistencies.join(', ')}',
      ));
    }

    return Result.success(null);
  }

  Result<void> _validateCreateSpecific(PlantaConfigModel config) {
    // ID deve estar vazio ou ser válido
    if (config.id.isNotEmpty && !_isValidId(config.id)) {
      return Result.error(const InvalidFormatError('id', 'formato válido'));
    }

    return Result.success(null);
  }

  Result<void> _validateUpdateSpecific(PlantaConfigModel config) {
    // ID deve ser fornecido e válido
    if (config.id.isEmpty) {
      return Result.error(const RequiredFieldError('id'));
    }

    if (!_isValidId(config.id)) {
      return Result.error(const InvalidFormatError('id', 'formato válido'));
    }

    return Result.success(null);
  }

  /// Utilitários privados

  bool _isValidId(String id) {
    if (id.isEmpty) return false;
    if (id.length < 3 || id.length > 100) return false;
    return true;
  }

  /// Métodos de conveniência

  /// Valida ativação de tipo de cuidado
  Result<PlantaConfigModel> validateActivateCareType(
    PlantaConfigModel config,
    String tipoCuidado,
    int? intervalo,
  ) {
    final careTypeValidation = validateCareType(tipoCuidado);
    if (careTypeValidation.isError) {
      return Result.error(careTypeValidation.error!);
    }

    if (intervalo != null) {
      final intervalValidation = validateCareInterval(intervalo, tipoCuidado);
      if (intervalValidation.isError) {
        return Result.error(intervalValidation.error!);
      }
    }

    PlantaConfigModel updatedConfig;
    switch (tipoCuidado) {
      case 'agua':
        updatedConfig = config.copyWith(
          aguaAtiva: true,
          intervaloRegaDias: intervalo ?? config.intervaloRegaDias,
        );
        break;
      case 'adubo':
        updatedConfig = config.copyWith(
          aduboAtivo: true,
          intervaloAdubacaoDias: intervalo ?? config.intervaloAdubacaoDias,
        );
        break;
      case 'banho_sol':
        updatedConfig = config.copyWith(
          banhoSolAtivo: true,
          intervaloBanhoSolDias: intervalo ?? config.intervaloBanhoSolDias,
        );
        break;
      case 'inspecao_pragas':
        updatedConfig = config.copyWith(
          inspecaoPragasAtiva: true,
          intervaloInspecaoPragasDias:
              intervalo ?? config.intervaloInspecaoPragasDias,
        );
        break;
      case 'poda':
        updatedConfig = config.copyWith(
          podaAtiva: true,
          intervaloPodaDias: intervalo ?? config.intervaloPodaDias,
        );
        break;
      case 'replantar':
        updatedConfig = config.copyWith(
          replantarAtivo: true,
          intervaloReplantarDias: intervalo ?? config.intervaloReplantarDias,
        );
        break;
      default:
        return Result.error(
            InvalidStateError('tipoCuidado', _validCareTypes.join(', ')));
    }

    updatedConfig = updatedConfig.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    updatedConfig.markAsModified();

    return validateForUpdate(updatedConfig);
  }

  /// Valida desativação de tipo de cuidado
  Result<PlantaConfigModel> validateDeactivateCareType(
    PlantaConfigModel config,
    String tipoCuidado,
  ) {
    final careTypeValidation = validateCareType(tipoCuidado);
    if (careTypeValidation.isError) {
      return Result.error(careTypeValidation.error!);
    }

    PlantaConfigModel updatedConfig;
    switch (tipoCuidado) {
      case 'agua':
        updatedConfig = config.copyWith(aguaAtiva: false);
        break;
      case 'adubo':
        updatedConfig = config.copyWith(aduboAtivo: false);
        break;
      case 'banho_sol':
        updatedConfig = config.copyWith(banhoSolAtivo: false);
        break;
      case 'inspecao_pragas':
        updatedConfig = config.copyWith(inspecaoPragasAtiva: false);
        break;
      case 'poda':
        updatedConfig = config.copyWith(podaAtiva: false);
        break;
      case 'replantar':
        updatedConfig = config.copyWith(replantarAtivo: false);
        break;
      default:
        return Result.error(
            InvalidStateError('tipoCuidado', _validCareTypes.join(', ')));
    }

    updatedConfig = updatedConfig.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    updatedConfig.markAsModified();

    // Validar se ainda há pelo menos um cuidado ativo
    final validation = _validateConsistency(updatedConfig);
    if (validation.isError) {
      return Result.error(validation.error!);
    }

    return Result.success(updatedConfig);
  }

  /// Valida atualização de intervalo
  Result<PlantaConfigModel> validateUpdateInterval(
    PlantaConfigModel config,
    String tipoCuidado,
    int novoIntervalo,
  ) {
    final careTypeValidation = validateCareType(tipoCuidado);
    if (careTypeValidation.isError) {
      return Result.error(careTypeValidation.error!);
    }

    final intervalValidation = validateCareInterval(novoIntervalo, tipoCuidado);
    if (intervalValidation.isError) {
      return Result.error(intervalValidation.error!);
    }

    PlantaConfigModel updatedConfig;
    switch (tipoCuidado) {
      case 'agua':
        updatedConfig = config.copyWith(intervaloRegaDias: novoIntervalo);
        break;
      case 'adubo':
        updatedConfig = config.copyWith(intervaloAdubacaoDias: novoIntervalo);
        break;
      case 'banho_sol':
        updatedConfig = config.copyWith(intervaloBanhoSolDias: novoIntervalo);
        break;
      case 'inspecao_pragas':
        updatedConfig =
            config.copyWith(intervaloInspecaoPragasDias: novoIntervalo);
        break;
      case 'poda':
        updatedConfig = config.copyWith(intervaloPodaDias: novoIntervalo);
        break;
      case 'replantar':
        updatedConfig = config.copyWith(intervaloReplantarDias: novoIntervalo);
        break;
      default:
        return Result.error(
            InvalidStateError('tipoCuidado', _validCareTypes.join(', ')));
    }

    updatedConfig = updatedConfig.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    updatedConfig.markAsModified();

    return validateForUpdate(updatedConfig);
  }
}

/// Factory para criação de PlantaConfigModel validado
class PlantaConfigModelFactory {
  static PlantaConfigModelFactory? _instance;
  static PlantaConfigModelFactory get instance =>
      _instance ??= PlantaConfigModelFactory._();

  PlantaConfigModelFactory._();

  /// Cria PlantaConfigModel com configuração padrão e validação
  Result<PlantaConfigModel> createDefault(String plantaId) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final config = PlantaConfigModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      plantaId: plantaId,
      // Configurações padrão sensatas
      aguaAtiva: true,
      intervaloRegaDias: 7, // Regar a cada 7 dias
      aduboAtivo: true,
      intervaloAdubacaoDias: 30, // Adubar a cada 30 dias
      banhoSolAtivo: false,
      intervaloBanhoSolDias: 3,
      inspecaoPragasAtiva: true,
      intervaloInspecaoPragasDias: 14, // Inspecionar a cada 14 dias
      podaAtiva: false,
      intervaloPodaDias: 90,
      replantarAtivo: false,
      intervaloReplantarDias: 365,
    );

    return PlantaConfigValidator.instance.validateForCreate(config);
  }

  /// Cria PlantaConfigModel customizado com validação
  Result<PlantaConfigModel> create({
    required String plantaId,
    bool aguaAtiva = true,
    int intervaloRegaDias = 7,
    bool aduboAtivo = true,
    int intervaloAdubacaoDias = 30,
    bool banhoSolAtivo = false,
    int intervaloBanhoSolDias = 3,
    bool inspecaoPragasAtiva = true,
    int intervaloInspecaoPragasDias = 14,
    bool podaAtiva = false,
    int intervaloPodaDias = 90,
    bool replantarAtivo = false,
    int intervaloReplantarDias = 365,
  }) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final config = PlantaConfigModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      plantaId: plantaId,
      aguaAtiva: aguaAtiva,
      intervaloRegaDias: intervaloRegaDias,
      aduboAtivo: aduboAtivo,
      intervaloAdubacaoDias: intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo,
      intervaloBanhoSolDias: intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva,
      intervaloInspecaoPragasDias: intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva,
      intervaloPodaDias: intervaloPodaDias,
      replantarAtivo: replantarAtivo,
      intervaloReplantarDias: intervaloReplantarDias,
    );

    return PlantaConfigValidator.instance.validateForCreate(config);
  }

  /// Atualiza PlantaConfigModel existente com validação
  Result<PlantaConfigModel> update(
    PlantaConfigModel original, {
    bool? aguaAtiva,
    int? intervaloRegaDias,
    bool? aduboAtivo,
    int? intervaloAdubacaoDias,
    bool? banhoSolAtivo,
    int? intervaloBanhoSolDias,
    bool? inspecaoPragasAtiva,
    int? intervaloInspecaoPragasDias,
    bool? podaAtiva,
    int? intervaloPodaDias,
    bool? replantarAtivo,
    int? intervaloReplantarDias,
  }) {
    final configAtualizada = original.copyWith(
      aguaAtiva: aguaAtiva ?? original.aguaAtiva,
      intervaloRegaDias: intervaloRegaDias ?? original.intervaloRegaDias,
      aduboAtivo: aduboAtivo ?? original.aduboAtivo,
      intervaloAdubacaoDias:
          intervaloAdubacaoDias ?? original.intervaloAdubacaoDias,
      banhoSolAtivo: banhoSolAtivo ?? original.banhoSolAtivo,
      intervaloBanhoSolDias:
          intervaloBanhoSolDias ?? original.intervaloBanhoSolDias,
      inspecaoPragasAtiva: inspecaoPragasAtiva ?? original.inspecaoPragasAtiva,
      intervaloInspecaoPragasDias:
          intervaloInspecaoPragasDias ?? original.intervaloInspecaoPragasDias,
      podaAtiva: podaAtiva ?? original.podaAtiva,
      intervaloPodaDias: intervaloPodaDias ?? original.intervaloPodaDias,
      replantarAtivo: replantarAtivo ?? original.replantarAtivo,
      intervaloReplantarDias:
          intervaloReplantarDias ?? original.intervaloReplantarDias,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    configAtualizada.markAsModified();

    return PlantaConfigValidator.instance.validateForUpdate(configAtualizada);
  }
}
