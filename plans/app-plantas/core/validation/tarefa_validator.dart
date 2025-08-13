// Project imports:
import '../../constants/care_type_const.dart';
import '../../database/tarefa_model.dart';
import 'result.dart';

/// Validador específico para TarefaModel
class TarefaValidator {
  static TarefaValidator? _instance;
  static TarefaValidator get instance => _instance ??= TarefaValidator._();

  TarefaValidator._();

  /// Constantes de validação
  static const int _maxObservacoesLength = 1000;

  /// Tipos de cuidado válidos
  /// Usa CareType.allValidStrings para garantir consistência
  static Set<String> get _validCareTypes => CareType.allValidStrings.toSet();

  /// Status válidos
  static const Set<bool> _validStatuses = {true, false};

  /// Valida TarefaModel completo
  Result<TarefaModel> validate(TarefaModel tarefa) {
    final validations = [
      _validatePlantaId(tarefa.plantaId),
      _validateTipoCuidado(tarefa.tipoCuidado),
      _validateDataExecucao(tarefa.dataExecucao),
      _validateConcluida(tarefa.concluida),
      _validateDataConclusao(tarefa.dataConclusao),
      _validateObservacoes(tarefa.observacoes),
      _validateConsistency(tarefa),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(tarefa);
  }

  /// Valida dados para criação
  Result<TarefaModel> validateForCreate(TarefaModel tarefa) {
    final validations = [
      _validatePlantaId(tarefa.plantaId),
      _validateTipoCuidado(tarefa.tipoCuidado),
      _validateDataExecucao(tarefa.dataExecucao),
      _validateConcluida(tarefa.concluida),
      _validateDataConclusao(tarefa.dataConclusao),
      _validateObservacoes(tarefa.observacoes),
      _validateConsistency(tarefa),
      _validateCreateSpecific(tarefa),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(tarefa);
  }

  /// Valida dados para atualização
  Result<TarefaModel> validateForUpdate(TarefaModel tarefa) {
    final validations = [
      _validatePlantaId(tarefa.plantaId),
      _validateTipoCuidado(tarefa.tipoCuidado),
      _validateDataExecucao(tarefa.dataExecucao),
      _validateConcluida(tarefa.concluida),
      _validateDataConclusao(tarefa.dataConclusao),
      _validateObservacoes(tarefa.observacoes),
      _validateConsistency(tarefa),
      _validateUpdateSpecific(tarefa),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(tarefa);
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

  Result<void> _validateTipoCuidado(String tipoCuidado) {
    if (tipoCuidado.trim().isEmpty) {
      return Result.error(const RequiredFieldError('tipoCuidado'));
    }

    if (!_validCareTypes.contains(tipoCuidado)) {
      return Result.error(
          InvalidStateError('tipoCuidado', _validCareTypes.join(', ')));
    }

    return Result.success(null);
  }

  Result<void> _validateDataExecucao(DateTime dataExecucao) {
    // Data de execução não pode ser muito antiga (mais de 10 anos)
    final now = DateTime.now();
    if (dataExecucao.isBefore(now.subtract(const Duration(days: 365 * 10)))) {
      return Result.error(
          const InvalidDateError('dataExecucao', 'muito antiga'));
    }

    // Data de execução não pode ser muito futura (mais de 5 anos)
    if (dataExecucao.isAfter(now.add(const Duration(days: 365 * 5)))) {
      return Result.error(
          const InvalidDateError('dataExecucao', 'muito futura'));
    }

    return Result.success(null);
  }

  Result<void> _validateConcluida(bool concluida) {
    if (!_validStatuses.contains(concluida)) {
      return Result.error(
          const InvalidStateError('concluida', 'true ou false'));
    }

    return Result.success(null);
  }

  Result<void> _validateDataConclusao(DateTime? dataConclusao) {
    if (dataConclusao == null) {
      return Result.success(null);
    }

    final now = DateTime.now();

    // Data de conclusão não pode ser futura
    if (dataConclusao.isAfter(now.add(const Duration(hours: 1)))) {
      return Result.error(
          const InvalidDateError('dataConclusao', 'não pode ser futura'));
    }

    // Data de conclusão não pode ser muito antiga (mais de 10 anos)
    if (dataConclusao.isBefore(now.subtract(const Duration(days: 365 * 10)))) {
      return Result.error(
          const InvalidDateError('dataConclusao', 'muito antiga'));
    }

    return Result.success(null);
  }

  Result<void> _validateObservacoes(String? observacoes) {
    if (observacoes == null) {
      return Result.success(null);
    }

    if (observacoes.length > _maxObservacoesLength) {
      return Result.error(
          const InvalidLengthError('observacoes', 0, _maxObservacoesLength));
    }

    if (_containsInvalidCharacters(observacoes)) {
      return Result.error(
          const InvalidFormatError('observacoes', 'caracteres válidos apenas'));
    }

    return Result.success(null);
  }

  Result<void> _validateConsistency(TarefaModel tarefa) {
    // Se tarefa está concluída, deve ter data de conclusão
    if (tarefa.concluida && tarefa.dataConclusao == null) {
      return Result.error(const DependencyNotMetError(
        'dataConclusao',
        'obrigatória quando tarefa está concluída',
      ));
    }

    // Se tarefa não está concluída, não deve ter data de conclusão
    if (!tarefa.concluida && tarefa.dataConclusao != null) {
      return Result.error(const InvalidStateError(
        'dataConclusao',
        'tarefa pendente não deve ter data de conclusão',
      ));
    }

    // Data de conclusão deve ser posterior ou igual à data de execução
    if (tarefa.dataConclusao != null) {
      final dataExecucaoOnly = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      final dataConclusaoOnly = DateTime(
        tarefa.dataConclusao!.year,
        tarefa.dataConclusao!.month,
        tarefa.dataConclusao!.day,
      );

      if (dataConclusaoOnly.isBefore(dataExecucaoOnly)) {
        return Result.error(const InvalidDateError(
          'dataConclusao',
          'deve ser posterior ou igual à data de execução',
        ));
      }
    }

    return Result.success(null);
  }

  Result<void> _validateCreateSpecific(TarefaModel tarefa) {
    // ID deve estar vazio ou ser válido
    if (tarefa.id.isNotEmpty && !_isValidId(tarefa.id)) {
      return Result.error(const InvalidFormatError('id', 'formato válido'));
    }

    // Nova tarefa não deve vir já concluída, exceto em casos especiais
    // (permite para migração de dados históricos)

    return Result.success(null);
  }

  Result<void> _validateUpdateSpecific(TarefaModel tarefa) {
    // ID deve ser fornecido e válido
    if (tarefa.id.isEmpty) {
      return Result.error(const RequiredFieldError('id'));
    }

    if (!_isValidId(tarefa.id)) {
      return Result.error(const InvalidFormatError('id', 'formato válido'));
    }

    return Result.success(null);
  }

  /// Utilitários privados

  bool _containsInvalidCharacters(String text) {
    const invalidPatterns = [
      '<script',
      '</script>',
      'javascript:',
      'data:text/html',
      'vbscript:',
      'onload=',
      'onerror=',
      'onclick=',
    ];

    final lowerText = text.toLowerCase();
    return invalidPatterns.any((pattern) => lowerText.contains(pattern));
  }

  bool _isValidId(String id) {
    if (id.isEmpty) return false;
    if (id.length < 3 || id.length > 100) return false;
    return true;
  }

  /// Métodos de conveniência

  /// Valida apenas o tipo de cuidado
  Result<void> validateTipoCuidadoOnly(String tipoCuidado) {
    return _validateTipoCuidado(tipoCuidado);
  }

  /// Valida apenas as datas
  Result<void> validateDatesOnly(
      DateTime dataExecucao, DateTime? dataConclusao) {
    final validations = [
      _validateDataExecucao(dataExecucao),
      _validateDataConclusao(dataConclusao),
    ];

    if (dataConclusao != null) {
      final dataExecucaoOnly = DateTime(
        dataExecucao.year,
        dataExecucao.month,
        dataExecucao.day,
      );
      final dataConclusaoOnly = DateTime(
        dataConclusao.year,
        dataConclusao.month,
        dataConclusao.day,
      );

      if (dataConclusaoOnly.isBefore(dataExecucaoOnly)) {
        validations.add(Result.error(const InvalidDateError(
          'dataConclusao',
          'deve ser posterior ou igual à data de execução',
        )));
      }
    }

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(null);
  }

  /// Valida conclusão de tarefa
  Result<TarefaModel> validateCompletion(
    TarefaModel tarefa,
    String? observacoes,
  ) {
    if (tarefa.concluida) {
      return Result.error(const InvalidStateError(
        'concluida',
        'tarefa já está concluída',
      ));
    }

    final tarefaConcluida = tarefa.marcarConcluida(observacoes: observacoes);
    return validateForUpdate(tarefaConcluida);
  }

  /// Valida reabertura de tarefa
  Result<TarefaModel> validateReopen(TarefaModel tarefa) {
    if (!tarefa.concluida) {
      return Result.error(const InvalidStateError(
        'concluida',
        'tarefa já está pendente',
      ));
    }

    final tarefaPendente = tarefa.marcarPendente();
    return validateForUpdate(tarefaPendente);
  }

  /// Valida reagendamento de tarefa
  Result<TarefaModel> validateReschedule(
    TarefaModel tarefa,
    DateTime novaDataExecucao,
  ) {
    if (tarefa.concluida) {
      return Result.error(const InvalidStateError(
        'dataExecucao',
        'tarefa concluída não pode ser reagendada',
      ));
    }

    final validationData = _validateDataExecucao(novaDataExecucao);
    if (validationData.isError) {
      return Result.error(validationData.error!);
    }

    final tarefaReagendada = tarefa.copyWith(
      dataExecucao: novaDataExecucao,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    tarefaReagendada.markAsModified();

    return validateForUpdate(tarefaReagendada);
  }
}

/// Factory para criação de TarefaModel validado
class TarefaModelFactory {
  static TarefaModelFactory? _instance;
  static TarefaModelFactory get instance =>
      _instance ??= TarefaModelFactory._();

  TarefaModelFactory._();

  /// Cria TarefaModel com validação completa
  Result<TarefaModel> create({
    required String plantaId,
    required String tipoCuidado,
    required DateTime dataExecucao,
    bool concluida = false,
    DateTime? dataConclusao,
    String? observacoes,
  }) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final tarefa = TarefaModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      plantaId: plantaId,
      tipoCuidado: tipoCuidado,
      dataExecucao: dataExecucao,
      concluida: concluida,
      dataConclusao: dataConclusao,
      observacoes: observacoes?.trim(),
    );

    return TarefaValidator.instance.validateForCreate(tarefa);
  }

  /// Cria tarefa para hoje
  Result<TarefaModel> createForToday({
    required String plantaId,
    required String tipoCuidado,
    String? observacoes,
  }) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return create(
      plantaId: plantaId,
      tipoCuidado: tipoCuidado,
      dataExecucao: todayOnly,
      observacoes: observacoes,
    );
  }

  /// Cria tarefa agendada
  Result<TarefaModel> createScheduled({
    required String plantaId,
    required String tipoCuidado,
    required DateTime dataExecucao,
    String? observacoes,
  }) {
    return create(
      plantaId: plantaId,
      tipoCuidado: tipoCuidado,
      dataExecucao: dataExecucao,
      observacoes: observacoes,
    );
  }

  /// Atualiza TarefaModel existente com validação
  Result<TarefaModel> update(
    TarefaModel original, {
    String? plantaId,
    String? tipoCuidado,
    DateTime? dataExecucao,
    bool? concluida,
    DateTime? dataConclusao,
    String? observacoes,
  }) {
    final tarefaAtualizada = original.copyWith(
      plantaId: plantaId ?? original.plantaId,
      tipoCuidado: tipoCuidado ?? original.tipoCuidado,
      dataExecucao: dataExecucao ?? original.dataExecucao,
      concluida: concluida ?? original.concluida,
      dataConclusao: dataConclusao ?? original.dataConclusao,
      observacoes: observacoes?.trim() ?? original.observacoes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    tarefaAtualizada.markAsModified();

    return TarefaValidator.instance.validateForUpdate(tarefaAtualizada);
  }

  /// Completa tarefa com validação
  Result<TarefaModel> complete(TarefaModel original, {String? observacoes}) {
    return TarefaValidator.instance.validateCompletion(original, observacoes);
  }

  /// Reabre tarefa com validação
  Result<TarefaModel> reopen(TarefaModel original) {
    return TarefaValidator.instance.validateReopen(original);
  }

  /// Reagenda tarefa com validação
  Result<TarefaModel> reschedule(
      TarefaModel original, DateTime novaDataExecucao) {
    return TarefaValidator.instance
        .validateReschedule(original, novaDataExecucao);
  }

  /// Cria próxima tarefa baseada em intervalo
  Result<TarefaModel> createNext(
    TarefaModel tarefaAtual,
    int intervaloDias,
  ) {
    if (!tarefaAtual.concluida) {
      return Result.error(const InvalidStateError(
        'concluida',
        'tarefa atual deve estar concluída para criar próxima',
      ));
    }

    final proximaData = (tarefaAtual.dataConclusao ?? tarefaAtual.dataExecucao)
        .add(Duration(days: intervaloDias));

    return create(
      plantaId: tarefaAtual.plantaId,
      tipoCuidado: tarefaAtual.tipoCuidado,
      dataExecucao: proximaData,
    );
  }
}
