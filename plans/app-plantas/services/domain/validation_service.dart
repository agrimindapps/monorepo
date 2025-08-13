// Project imports:
import '../../core/validation/espaco_validator.dart';
import '../../core/validation/planta_config_validator.dart';
import '../../core/validation/planta_validator.dart';
import '../../core/validation/result.dart';
import '../../core/validation/tarefa_validator.dart';
import '../../database/espaco_model.dart';
import '../../database/planta_config_model.dart';
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import 'business_rules_service.dart';

/// Serviço centralizado para todas as validações
/// Responsabilidade: Centralizar validação de dados antes de operações CRUD
class ValidationService {
  static ValidationService? _instance;
  static ValidationService get instance => _instance ??= ValidationService._();

  final EspacoValidator _espacoValidator = EspacoValidator.instance;
  final PlantaValidator _plantaValidator = PlantaValidator.instance;
  final PlantaConfigValidator _plantaConfigValidator =
      PlantaConfigValidator.instance;
  final TarefaValidator _tarefaValidator = TarefaValidator.instance;
  final BusinessRulesService _businessRules = BusinessRulesService.instance;

  ValidationService._();

  /// Validar espaço completo (dados + regras de negócio)
  Future<Result<EspacoModel>> validateEspacoComplete(EspacoModel espaco,
      {bool isUpdate = false}) async {
    // Validação estrutural
    final structuralResult = _espacoValidator.validate(espaco);
    if (structuralResult.isError) {
      return structuralResult;
    }

    // Validação de regras de negócio
    final existeNome = await _businessRules.existeEspacoComNome(
      espaco.nome,
      excluirId: isUpdate ? espaco.id : null,
    );

    if (existeNome) {
      return Result.error(
          ValidationError.duplicateEntry('Já existe espaço com este nome'));
    }

    return Result.success(espaco);
  }

  /// Validar planta completo (dados + regras de negócio)
  Future<Result<PlantaModel>> validatePlantaComplete(PlantaModel planta,
      {bool isUpdate = false}) async {
    // Validação estrutural
    final structuralResult = _plantaValidator.validate(planta);
    if (structuralResult.isError) {
      return structuralResult;
    }

    // Validação de regras de negócio
    final existeNome = await _businessRules.existePlantaComNome(
      planta.nome!,
      planta.espacoId!,
      excluirId: isUpdate ? planta.id : null,
    );

    if (existeNome) {
      return Result.error(ValidationError.duplicateEntry(
          'Já existe planta com este nome neste espaço'));
    }

    return Result.success(planta);
  }

  /// Validar configuração de planta completo
  Future<Result<PlantaConfigModel>> validatePlantaConfigComplete(
      PlantaConfigModel config,
      {bool isUpdate = false}) async {
    // Validação estrutural
    final structuralResult = _plantaConfigValidator.validate(config);
    if (structuralResult.isError) {
      return structuralResult;
    }

    // Validação de regras de negócio
    final podeConfigurar =
        await _businessRules.podeConfigurarPlanta(config.plantaId);
    if (!podeConfigurar) {
      return Result.error(ValidationError.invalidState(
          'Não é possível configurar planta em espaço inativo'));
    }

    return Result.success(config);
  }

  /// Validar tarefa completo (dados + regras de negócio)
  Future<Result<TarefaModel>> validateTarefaComplete(TarefaModel tarefa,
      {bool isUpdate = false}) async {
    // Validação estrutural
    final structuralResult = _tarefaValidator.validate(tarefa);
    if (structuralResult.isError) {
      return structuralResult;
    }

    // Validação de regras de negócio
    if (!_businessRules.ehTipoCuidadoValido(tarefa.tipoCuidado)) {
      return Result.error(ValidationError.invalidFormat(
          'tipoCuidado', 'Tipo de cuidado inválido: ${tarefa.tipoCuidado}'));
    }

    // Verificar se pode configurar a planta
    final podeConfigurar =
        await _businessRules.podeConfigurarPlanta(tarefa.plantaId);
    if (!podeConfigurar) {
      return Result.error(ValidationError.invalidState(
          'Não é possível criar tarefa para planta em espaço inativo'));
    }

    return Result.success(tarefa);
  }

  /// Validar operação de exclusão de espaço
  Future<Result<void>> validateEspacoDeletion(String espacoId) async {
    final podeExcluir = await _businessRules.podeExcluirEspaco(espacoId);
    if (!podeExcluir) {
      return Result.error(ValidationError.invalidState(
          'Não é possível excluir espaço com plantas'));
    }
    return Result.success(null);
  }

  /// Validar operação de exclusão de planta
  Future<Result<void>> validatePlantaDeletion(String plantaId) async {
    final podeExcluir = await _businessRules.podeExcluirPlanta(plantaId);
    if (!podeExcluir) {
      return Result.error(ValidationError.invalidState(
          'Não é possível excluir planta com tarefas pendentes'));
    }
    return Result.success(null);
  }

  /// Validar operação de desativação de espaço
  Future<Result<void>> validateEspacoDeactivation(String espacoId) async {
    final podeDesativar = await _businessRules.podeDesativarEspaco(espacoId);
    if (!podeDesativar) {
      return Result.error(ValidationError.invalidState(
          'Não é possível desativar espaço com tarefas pendentes'));
    }
    return Result.success(null);
  }

  /// Validar criação automática de tarefa
  Future<Result<void>> validateAutomaticTaskCreation(
      String plantaId, String tipoCuidado) async {
    final devecriar =
        await _businessRules.devecriarTarefaAutomatica(plantaId, tipoCuidado);
    if (!devecriar) {
      return Result.error(ValidationError.invalidState(
          'Não é necessário criar tarefa automática neste momento'));
    }
    return Result.success(null);
  }

  /// Validar lista de entidades (batch validation)
  Future<Result<List<T>>> validateBatch<T>(
    List<T> entities,
    Future<Result<T>> Function(T entity) validator,
  ) async {
    final validatedEntities = <T>[];
    final errors = <ValidationError>[];

    for (final entity in entities) {
      final result = await validator(entity);
      if (result.isSuccess) {
        validatedEntities.add(result.value);
      } else {
        errors.add(result.error!);
      }
    }

    if (errors.isNotEmpty) {
      return Result.error(errors.first); // Retorna o primeiro erro
    }

    return Result.success(validatedEntities);
  }

  /// Validar dados antes de sincronização com Firebase
  Future<Result<void>> validateBeforeSync(
      String entityType, Map<String, dynamic> data) async {
    // Validações básicas de dados
    if (data.isEmpty) {
      return Result.error(
          ValidationError.requiredField('Dados não podem estar vazios'));
    }

    // Validações específicas por tipo
    switch (entityType) {
      case 'espaco':
        if (!data.containsKey('nome') || (data['nome'] as String).isEmpty) {
          return Result.error(
              ValidationError.requiredField('Nome é obrigatório'));
        }
        break;
      case 'planta':
        if (!data.containsKey('nome') || (data['nome'] as String).isEmpty) {
          return Result.error(
              ValidationError.requiredField('Nome é obrigatório'));
        }
        if (!data.containsKey('espacoId') ||
            (data['espacoId'] as String).isEmpty) {
          return Result.error(
              ValidationError.requiredField('EspacoId é obrigatório'));
        }
        break;
      case 'tarefa':
        if (!data.containsKey('plantaId') ||
            (data['plantaId'] as String).isEmpty) {
          return Result.error(
              ValidationError.requiredField('PlantaId é obrigatório'));
        }
        if (!data.containsKey('tipoCuidado') ||
            (data['tipoCuidado'] as String).isEmpty) {
          return Result.error(
              ValidationError.requiredField('TipoCuidado é obrigatório'));
        }
        break;
    }

    return Result.success(null);
  }

  /// Validar integridade referencial
  Future<Result<void>> validateReferentialIntegrity() async {
    // Aqui podemos implementar validações de integridade entre entidades
    // Por exemplo, verificar se todas as plantas têm espaços válidos
    // ou se todas as tarefas têm plantas válidas

    // Por enquanto, retorna sucesso, mas pode ser expandido
    return Result.success(null);
  }
}
