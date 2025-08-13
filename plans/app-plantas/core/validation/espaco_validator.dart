// Project imports:
import '../../database/espaco_model.dart';
import '../../shared/utils/string_comparison_utils.dart';
import 'result.dart';

/// Validador específico para EspacoModel
class EspacoValidator {
  static EspacoValidator? _instance;
  static EspacoValidator get instance => _instance ??= EspacoValidator._();

  EspacoValidator._();

  /// Constantes de validação
  static const int _minNomeLength = 1;
  static const int _maxNomeLength = 100;
  static const int _maxDescricaoLength = 500;

  /// Valida EspacoModel completo
  Result<EspacoModel> validate(EspacoModel espaco) {
    final validations = [
      _validateNome(espaco.nome),
      _validateDescricao(espaco.descricao),
      _validateDates(espaco.dataCriacao),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(espaco);
  }

  /// Valida dados para criação
  Result<EspacoModel> validateForCreate(EspacoModel espaco) {
    final validations = [
      _validateNome(espaco.nome),
      _validateDescricao(espaco.descricao),
      _validateDates(espaco.dataCriacao),
      _validateCreateSpecific(espaco),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(espaco);
  }

  /// Valida dados para atualização
  Result<EspacoModel> validateForUpdate(EspacoModel espaco) {
    final validations = [
      _validateNome(espaco.nome),
      _validateDescricao(espaco.descricao),
      _validateDates(espaco.dataCriacao),
      _validateUpdateSpecific(espaco),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(espaco);
  }

  /// Valida unicidade do nome
  Future<Result<void>> validateNomeUnique(
      String nome, Future<List<EspacoModel>> Function() getAllEspacos,
      {String? excludeId}) async {
    if (nome.trim().isEmpty) {
      return Result.error(const RequiredFieldError('nome'));
    }

    try {
      final espacos = await getAllEspacos();

      // FIXED: Usar comparação normalizada para caracteres acentuados
      final exists = espacos.any((espaco) =>
          StringComparisonUtils.equals(espaco.nome.trim(), nome.trim()) &&
          espaco.ativo &&
          (excludeId == null || espaco.id != excludeId));

      if (exists) {
        return Result.error(DuplicateValueError('nome', nome));
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(InvalidFormatError(
        'nome',
        'erro ao verificar unicidade: $e',
      ));
    }
  }

  /// Validações privadas

  Result<void> _validateNome(String nome) {
    if (nome.trim().isEmpty) {
      return Result.error(const RequiredFieldError('nome'));
    }

    final nomeLength = nome.trim().length;
    if (nomeLength < _minNomeLength || nomeLength > _maxNomeLength) {
      return Result.error(
          const InvalidLengthError('nome', _minNomeLength, _maxNomeLength));
    }

    // Validar caracteres especiais perigosos
    if (_containsInvalidCharacters(nome)) {
      return Result.error(const InvalidFormatError(
          'nome', 'apenas letras, números, espaços e caracteres básicos'));
    }

    return Result.success(null);
  }

  Result<void> _validateDescricao(String? descricao) {
    if (descricao == null) {
      return Result.success(null);
    }

    if (descricao.length > _maxDescricaoLength) {
      return Result.error(
          const InvalidLengthError('descricao', 0, _maxDescricaoLength));
    }

    // Validar caracteres especiais perigosos na descrição
    if (_containsInvalidCharacters(descricao)) {
      return Result.error(
          const InvalidFormatError('descricao', 'caracteres válidos apenas'));
    }

    return Result.success(null);
  }

  Result<void> _validateDates(DateTime? dataCriacao) {
    if (dataCriacao == null) {
      return Result.success(null);
    }

    final now = DateTime.now();

    // Data de criação não pode ser mais de 1 dia no futuro (tolerância para timezone)
    if (dataCriacao.isAfter(now.add(const Duration(days: 1)))) {
      return Result.error(
          const InvalidDateError('dataCriacao', 'não pode ser futura'));
    }

    // Data de criação não pode ser muito antiga (mais de 50 anos)
    if (dataCriacao.isBefore(now.subtract(const Duration(days: 365 * 50)))) {
      return Result.error(
          const InvalidDateError('dataCriacao', 'muito antiga'));
    }

    return Result.success(null);
  }

  Result<void> _validateCreateSpecific(EspacoModel espaco) {
    // Validações específicas para criação

    // ID deve estar vazio ou ser válido
    if (espaco.id.isNotEmpty && !_isValidId(espaco.id)) {
      return Result.error(
          const InvalidFormatError('id', 'formato UUID válido'));
    }

    // Data de criação deve ser fornecida ou será definida como agora
    if (espaco.dataCriacao == null) {
      // Isso é aceitável, será definido automaticamente
    }

    return Result.success(null);
  }

  Result<void> _validateUpdateSpecific(EspacoModel espaco) {
    // Validações específicas para atualização

    // ID deve ser fornecido e válido
    if (espaco.id.isEmpty) {
      return Result.error(const RequiredFieldError('id'));
    }

    if (!_isValidId(espaco.id)) {
      return Result.error(
          const InvalidFormatError('id', 'formato UUID válido'));
    }

    return Result.success(null);
  }

  /// Utilitários privados

  bool _containsInvalidCharacters(String text) {
    // Caracteres perigosos para prevenção de injection
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
    // Verificação básica de ID - pode ser melhorada conforme necessário
    if (id.isEmpty) return false;

    // Verificar se não contém caracteres perigosos
    if (_containsInvalidCharacters(id)) return false;

    // ID deve ter tamanho razoável
    if (id.length < 3 || id.length > 100) return false;

    return true;
  }

  /// Métodos de conveniência para validações específicas

  /// Valida apenas o nome
  Result<void> validateNomeOnly(String nome) {
    return _validateNome(nome);
  }

  /// Valida apenas a descrição
  Result<void> validateDescricaoOnly(String? descricao) {
    return _validateDescricao(descricao);
  }

  /// Valida se espaço pode ser ativado/desativado
  Result<void> validateStatusChange(EspacoModel espaco, bool novoStatus) {
    if (espaco.ativo == novoStatus) {
      return Result.error(InvalidStateError(
        'ativo',
        'status já está ${novoStatus ? 'ativo' : 'inativo'}',
      ));
    }

    return Result.success(null);
  }

  /// Valida se espaço pode ser duplicado
  Result<void> validateForDuplication(EspacoModel espaco) {
    final validations = [
      _validateNome(espaco.nome),
      _validateDescricao(espaco.descricao),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(null);
  }
}

/// Factory para criação de EspacoModel validado
class EspacoModelFactory {
  static EspacoModelFactory? _instance;
  static EspacoModelFactory get instance =>
      _instance ??= EspacoModelFactory._();

  EspacoModelFactory._();

  /// Cria EspacoModel com validação completa
  Result<EspacoModel> create({
    required String nome,
    String? descricao,
    bool ativo = true,
    DateTime? dataCriacao,
  }) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final espaco = EspacoModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      nome: nome.trim(),
      descricao: descricao?.trim(),
      ativo: ativo,
      dataCriacao: dataCriacao ?? now,
    );

    return EspacoValidator.instance.validateForCreate(espaco);
  }

  /// Atualiza EspacoModel existente com validação
  Result<EspacoModel> update(
    EspacoModel original, {
    String? nome,
    String? descricao,
    bool? ativo,
    DateTime? dataCriacao,
  }) {
    final espacoAtualizado = original.copyWith(
      nome: nome?.trim() ?? original.nome,
      descricao: descricao?.trim() ?? original.descricao,
      ativo: ativo ?? original.ativo,
      dataCriacao: dataCriacao ?? original.dataCriacao,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    espacoAtualizado.markAsModified();

    return EspacoValidator.instance.validateForUpdate(espacoAtualizado);
  }

  /// Cria cópia validada para duplicação
  Result<EspacoModel> duplicate(EspacoModel original, {String? suffixNome}) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final suffix = suffixNome ?? ' (cópia)';

    final validation =
        EspacoValidator.instance.validateForDuplication(original);
    if (validation.isError) {
      return Result.error(validation.error!);
    }

    final espacoDuplicado = EspacoModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      nome: '${original.nome}$suffix',
      descricao: original.descricao,
      ativo: true, // Cópias sempre começam ativas
      dataCriacao: now,
    );

    return EspacoValidator.instance.validateForCreate(espacoDuplicado);
  }
}
