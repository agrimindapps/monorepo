// Project imports:
import '../../core/validation/result.dart';
import '../../database/espaco_model.dart';
import '../../database/planta_config_model.dart';
import 'care_type_handler.dart';

/// Command pattern para operações de update
///
/// Este sistema encapsula operações de update complexas em objetos,
/// permitindo execução, logging, undo e parametrização flexível.
abstract class UpdateCommand<T> {
  /// Identificador único do comando
  String get commandId;

  /// Descrição do comando para logging
  String get description;

  /// Executar o comando
  Future<Result<T>> execute();

  /// Reverter o comando (opcional)
  Future<Result<T>>? undo() => null;

  /// Validar se o comando pode ser executado
  Result<void> validate() => Result.success(null);

  /// Timestamp da execução
  DateTime? _executedAt;
  DateTime? get executedAt => _executedAt;

  /// Marcar como executado
  void markAsExecuted() {
    _executedAt = DateTime.now();
  }
}

/// Command para ativação/desativação de tipos de cuidado
class ActivateCareTypeCommand extends UpdateCommand<PlantaConfigModel> {
  final PlantaConfigModel _config;
  final String _careType;
  final bool _activate;
  final int? _customInterval;
  final PlantaConfigModel? _originalConfig;

  ActivateCareTypeCommand({
    required PlantaConfigModel config,
    required String careType,
    required bool activate,
    int? customInterval,
  })  : _config = config,
        _careType = careType,
        _activate = activate,
        _customInterval = customInterval,
        _originalConfig = config.copyWith(); // Backup para undo

  @override
  String get commandId =>
      'activate_care_${_careType}_${_activate}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String get description =>
      '${_activate ? "Ativar" : "Desativar"} cuidado $_careType${_customInterval != null ? " com intervalo $_customInterval dias" : ""}';

  @override
  Result<void> validate() {
    final handler = CareTypeHandlerFactory.getHandler(_careType);
    if (handler == null) {
      return Result.error(InvalidFormatError(
        'careType',
        'Tipo de cuidado inválido: $_careType',
      ));
    }

    if (_activate && _customInterval != null) {
      final intervalValidation = handler.validateInterval(_customInterval);
      if (intervalValidation.isError) {
        return Result.error(intervalValidation.error!);
      }
    }

    return Result.success(null);
  }

  @override
  Future<Result<PlantaConfigModel>> execute() async {
    final validationResult = validate();
    if (validationResult.isError) {
      return Result.error(validationResult.error!);
    }

    final handler = CareTypeHandlerFactory.getHandler(_careType);
    if (handler == null) {
      return Result.error(InvalidStateError(
        'execute',
        'Handler não encontrado para $_careType',
      ));
    }

    try {
      final updatedConfig = _activate
          ? handler.activate(_config, customInterval: _customInterval)
          : handler.deactivate(_config);

      markAsExecuted();
      return Result.success(updatedConfig);
    } catch (e) {
      return Result.error(InvalidStateError(
        'execute',
        'Erro ao executar comando: $e',
      ));
    }
  }

  @override
  Future<Result<PlantaConfigModel>>? undo() {
    if (_originalConfig == null) {
      return null;
    }

    return Future.value(Result.success(_originalConfig));
  }
}

/// Command para atualização de intervalo de cuidado
class UpdateCareIntervalCommand extends UpdateCommand<PlantaConfigModel> {
  final PlantaConfigModel _config;
  final String _careType;
  final int _newInterval;
  final PlantaConfigModel? _originalConfig;

  UpdateCareIntervalCommand({
    required PlantaConfigModel config,
    required String careType,
    required int newInterval,
  })  : _config = config,
        _careType = careType,
        _newInterval = newInterval,
        _originalConfig = config.copyWith(); // Backup para undo

  @override
  String get commandId =>
      'update_interval_${_careType}_${_newInterval}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String get description =>
      'Atualizar intervalo de $_careType para $_newInterval dias';

  @override
  Result<void> validate() {
    final handler = CareTypeHandlerFactory.getHandler(_careType);
    if (handler == null) {
      return Result.error(InvalidFormatError(
        'careType',
        'Tipo de cuidado inválido: $_careType',
      ));
    }

    final intervalValidation = handler.validateInterval(_newInterval);
    if (intervalValidation.isError) {
      return Result.error(intervalValidation.error!);
    }

    // Verificar se o tipo de cuidado está ativo
    if (!handler.isActive(_config)) {
      return Result.error(InvalidStateError(
        'validate',
        'Não é possível atualizar intervalo de cuidado inativo: $_careType',
      ));
    }

    return Result.success(null);
  }

  @override
  Future<Result<PlantaConfigModel>> execute() async {
    final validationResult = validate();
    if (validationResult.isError) {
      return Result.error(validationResult.error!);
    }

    final handler = CareTypeHandlerFactory.getHandler(_careType);
    if (handler == null) {
      return Result.error(InvalidStateError(
        'execute',
        'Handler não encontrado para $_careType',
      ));
    }

    try {
      final updatedConfig = handler.updateInterval(_config, _newInterval);
      markAsExecuted();
      return Result.success(updatedConfig);
    } catch (e) {
      return Result.error(InvalidStateError(
        'execute',
        'Erro ao executar comando: $e',
      ));
    }
  }

  @override
  Future<Result<PlantaConfigModel>>? undo() {
    if (_originalConfig == null) {
      return null;
    }

    return Future.value(Result.success(_originalConfig));
  }
}

/// Command para atualização de espaço (simplifica lógica condicional)
class UpdateEspacoCommand extends UpdateCommand<EspacoModel> {
  final EspacoModel _currentEspaco;
  final EspacoUpdateParameters _updateParams;
  final EspacoModel? _originalEspaco;

  UpdateEspacoCommand({
    required EspacoModel currentEspaco,
    required EspacoUpdateParameters updateParams,
  })  : _currentEspaco = currentEspaco,
        _updateParams = updateParams,
        _originalEspaco = currentEspaco.copyWith(); // Backup para undo

  @override
  String get commandId =>
      'update_espaco_${_currentEspaco.id}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String get description => 'Atualizar espaço ${_currentEspaco.nome}';

  @override
  Result<void> validate() {
    // Validar nome se fornecido
    if (_updateParams.nome != null) {
      final nome = _updateParams.nome!.trim();
      if (nome.isEmpty || nome.length > 100) {
        return Result.error(InvalidFormatError(
          'nome',
          'Nome deve ter entre 1 e 100 caracteres (recebido: "${nome.length} chars")',
        ));
      }
    }

    // Validar descrição se fornecida
    if (_updateParams.descricao != null) {
      final descricao = _updateParams.descricao!.trim();
      if (descricao.length > 500) {
        return Result.error(OutOfRangeError(
          'descricao',
          'Descrição deve ter no máximo 500 caracteres (recebido: ${descricao.length} chars)',
        ));
      }
    }

    return Result.success(null);
  }

  @override
  Future<Result<EspacoModel>> execute() async {
    final validationResult = validate();
    if (validationResult.isError) {
      return Result.error(validationResult.error!);
    }

    try {
      // Aplicar apenas as mudanças fornecidas
      final updatedEspaco = _currentEspaco.copyWith(
        nome: _updateParams.nome ?? _currentEspaco.nome,
        descricao: _updateParams.descricao ?? _currentEspaco.descricao,
        ativo: _updateParams.ativo ?? _currentEspaco.ativo,
        dataCriacao: _updateParams.dataCriacao ?? _currentEspaco.dataCriacao,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      markAsExecuted();
      return Result.success(updatedEspaco);
    } catch (e) {
      return Result.error(InvalidStateError(
        'execute',
        'Erro ao executar comando: $e',
      ));
    }
  }

  @override
  Future<Result<EspacoModel>>? undo() {
    if (_originalEspaco == null) {
      return null;
    }

    return Future.value(Result.success(_originalEspaco));
  }
}

/// Command para criação de espaço (simplifica lógica condicional)
class CreateEspacoCommand extends UpdateCommand<EspacoModel> {
  final EspacoCreationParameters _creationParams;

  CreateEspacoCommand({
    required EspacoCreationParameters creationParams,
  }) : _creationParams = creationParams;

  @override
  String get commandId =>
      'create_espaco_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String get description => 'Criar espaço ${_creationParams.nome}';

  @override
  Result<void> validate() {
    // Validar nome
    final nome = _creationParams.nome.trim();
    if (nome.isEmpty || nome.length > 100) {
      return Result.error(InvalidFormatError(
        'nome',
        'Nome deve ter entre 1 e 100 caracteres (recebido: "${nome.length} chars")',
      ));
    }

    // Validar descrição
    if (_creationParams.descricao != null) {
      final descricao = _creationParams.descricao!.trim();
      if (descricao.length > 500) {
        return Result.error(OutOfRangeError(
          'descricao',
          'Descrição deve ter no máximo 500 caracteres (recebido: ${descricao.length} chars)',
        ));
      }
    }

    return Result.success(null);
  }

  @override
  Future<Result<EspacoModel>> execute() async {
    final validationResult = validate();
    if (validationResult.isError) {
      return Result.error(validationResult.error!);
    }

    try {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;

      final novoEspaco = EspacoModel(
        id: '', // Será definido pelo repository
        createdAt: nowMs,
        updatedAt: nowMs,
        nome: _creationParams.nome.trim(),
        descricao: _creationParams.descricao?.trim() ?? '',
        ativo: _creationParams.ativo,
        dataCriacao: _creationParams.dataCriacao ?? now,
      );

      markAsExecuted();
      return Result.success(novoEspaco);
    } catch (e) {
      return Result.error(InvalidStateError(
        'execute',
        'Erro ao executar comando: $e',
      ));
    }
  }

  @override
  Future<Result<EspacoModel>>? undo() {
    // Criação não pode ser desfeita automaticamente - requer delete manual
    return null;
  }
}

/// Executor de comandos com suporte a batch e logging
class CommandExecutor {
  static final List<UpdateCommand> _executedCommands = [];

  /// Executar comando único
  static Future<Result<T>> execute<T>(UpdateCommand<T> command) async {
    try {
      final result = await command.execute();
      if (result.isSuccess) {
        _executedCommands.add(command);
      }
      return result;
    } catch (e) {
      return Result.error(InvalidStateError(
        'execute',
        'Erro na execução do comando: $e',
      ));
    }
  }

  /// Executar múltiplos comandos em sequência
  static Future<List<Result>> executeBatch(List<UpdateCommand> commands) async {
    final results = <Result>[];

    for (final command in commands) {
      final result = await execute(command);
      results.add(result);

      // Se um comando falhar, parar execução
      if (result.isError) {
        break;
      }
    }

    return results;
  }

  /// Desfazer último comando executado
  static Future<Result?> undoLast() async {
    if (_executedCommands.isEmpty) return null;

    final lastCommand = _executedCommands.removeLast();
    final undoResult = lastCommand.undo();

    return undoResult;
  }

  /// Obter histórico de comandos executados
  static List<UpdateCommand> getExecutionHistory() =>
      List.from(_executedCommands);

  /// Limpar histórico
  static void clearHistory() => _executedCommands.clear();
}

/// Parameter objects para simplificar assinaturas de métodos

/// Parâmetros para atualização de espaço
class EspacoUpdateParameters {
  final String? nome;
  final String? descricao;
  final bool? ativo;
  final DateTime? dataCriacao;

  const EspacoUpdateParameters({
    this.nome,
    this.descricao,
    this.ativo,
    this.dataCriacao,
  });

  /// Verificar se pelo menos um parâmetro foi fornecido
  bool get hasUpdates =>
      nome != null || descricao != null || ativo != null || dataCriacao != null;

  /// Criar a partir de EspacoModel (extrai apenas campos alteráveis)
  factory EspacoUpdateParameters.fromModel(EspacoModel espaco) {
    return EspacoUpdateParameters(
      nome: espaco.nome,
      descricao: espaco.descricao,
      ativo: espaco.ativo,
      dataCriacao: espaco.dataCriacao,
    );
  }
}

/// Parâmetros para criação de espaço
class EspacoCreationParameters {
  final String nome;
  final String? descricao;
  final bool ativo;
  final DateTime? dataCriacao;

  const EspacoCreationParameters({
    required this.nome,
    this.descricao,
    this.ativo = true,
    this.dataCriacao,
  });

  /// Criar a partir de valores básicos
  factory EspacoCreationParameters.basic({
    required String nome,
    String? descricao,
    bool ativo = true,
  }) {
    return EspacoCreationParameters(
      nome: nome,
      descricao: descricao,
      ativo: ativo,
      dataCriacao: DateTime.now(),
    );
  }
}

/// Parâmetros para operações de cuidado
class CareOperationParameters {
  final String plantaId;
  final String careType;
  final bool? activate;
  final int? interval;
  final bool validatePlantaExists;

  const CareOperationParameters({
    required this.plantaId,
    required this.careType,
    this.activate,
    this.interval,
    this.validatePlantaExists = true,
  });

  /// Criar para ativação de cuidado
  factory CareOperationParameters.activate({
    required String plantaId,
    required String careType,
    int? customInterval,
    bool validatePlantaExists = true,
  }) {
    return CareOperationParameters(
      plantaId: plantaId,
      careType: careType,
      activate: true,
      interval: customInterval,
      validatePlantaExists: validatePlantaExists,
    );
  }

  /// Criar para desativação de cuidado
  factory CareOperationParameters.deactivate({
    required String plantaId,
    required String careType,
    bool validatePlantaExists = true,
  }) {
    return CareOperationParameters(
      plantaId: plantaId,
      careType: careType,
      activate: false,
      validatePlantaExists: validatePlantaExists,
    );
  }

  /// Criar para atualização de intervalo
  factory CareOperationParameters.updateInterval({
    required String plantaId,
    required String careType,
    required int newInterval,
    bool validatePlantaExists = true,
  }) {
    return CareOperationParameters(
      plantaId: plantaId,
      careType: careType,
      interval: newInterval,
      validatePlantaExists: validatePlantaExists,
    );
  }
}
