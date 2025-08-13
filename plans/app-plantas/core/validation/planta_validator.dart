// Project imports:
import '../../database/planta_model.dart';
import 'result.dart';

/// Validador específico para PlantaModel
class PlantaValidator {
  static PlantaValidator? _instance;
  static PlantaValidator get instance => _instance ??= PlantaValidator._();

  PlantaValidator._();

  /// Constantes de validação
  static const int _minNomeLength = 1;
  static const int _maxNomeLength = 100;
  static const int _maxEspecieLength = 100;
  static const int _maxObservacoesLength = 1000;
  static const int _maxImagePaths = 10;
  static const int _maxFotoBase64Length = 5 * 1024 * 1024; // 5MB em base64

  /// Valida PlantaModel completo
  Result<PlantaModel> validate(PlantaModel planta) {
    final validations = [
      _validateNome(planta.nome),
      _validateEspecie(planta.especie),
      _validateEspacoId(planta.espacoId),
      _validateImagePaths(planta.imagePaths),
      _validateObservacoes(planta.observacoes),
      _validateDataCadastro(planta.dataCadastro),
      _validateFotoBase64(planta.fotoBase64),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(planta);
  }

  /// Valida dados para criação
  Result<PlantaModel> validateForCreate(PlantaModel planta) {
    final validations = [
      _validateNome(planta.nome),
      _validateEspecie(planta.especie),
      _validateEspacoId(planta.espacoId),
      _validateImagePaths(planta.imagePaths),
      _validateObservacoes(planta.observacoes),
      _validateDataCadastro(planta.dataCadastro),
      _validateFotoBase64(planta.fotoBase64),
      _validateCreateSpecific(planta),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(planta);
  }

  /// Valida dados para atualização
  Result<PlantaModel> validateForUpdate(PlantaModel planta) {
    final validations = [
      _validateNome(planta.nome),
      _validateEspecie(planta.especie),
      _validateEspacoId(planta.espacoId),
      _validateImagePaths(planta.imagePaths),
      _validateObservacoes(planta.observacoes),
      _validateDataCadastro(planta.dataCadastro),
      _validateFotoBase64(planta.fotoBase64),
      _validateUpdateSpecific(planta),
    ];

    final errors = ResultUtils.collectErrors(validations);
    if (errors.isNotEmpty) {
      return Result.error(errors.first);
    }

    return Result.success(planta);
  }

  /// Valida se espaço existe
  Future<Result<void>> validateEspacoExists(
    String? espacoId,
    Future<bool> Function(String) espacoExistsFunction,
  ) async {
    if (espacoId == null || espacoId.isEmpty) {
      return Result.error(const RequiredFieldError('espacoId'));
    }

    try {
      final exists = await espacoExistsFunction(espacoId);
      if (!exists) {
        return Result.error(const InvalidReferenceError('espacoId', 'Espaco'));
      }
      return Result.success(null);
    } catch (e) {
      return Result.error(InvalidFormatError(
        'espacoId',
        'erro ao verificar existência do espaço: $e',
      ));
    }
  }

  /// Validações privadas

  Result<void> _validateNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return Result.error(const RequiredFieldError('nome'));
    }

    final nomeLength = nome.trim().length;
    if (nomeLength < _minNomeLength || nomeLength > _maxNomeLength) {
      return Result.error(
          const InvalidLengthError('nome', _minNomeLength, _maxNomeLength));
    }

    if (_containsInvalidCharacters(nome)) {
      return Result.error(const InvalidFormatError(
          'nome', 'apenas letras, números, espaços e caracteres básicos'));
    }

    return Result.success(null);
  }

  Result<void> _validateEspecie(String? especie) {
    if (especie == null) {
      return Result.success(null); // Espécie é opcional
    }

    if (especie.length > _maxEspecieLength) {
      return Result.error(
          const InvalidLengthError('especie', 0, _maxEspecieLength));
    }

    if (_containsInvalidCharacters(especie)) {
      return Result.error(const InvalidFormatError(
          'especie', 'apenas letras, números, espaços e caracteres básicos'));
    }

    return Result.success(null);
  }

  Result<void> _validateEspacoId(String? espacoId) {
    if (espacoId == null || espacoId.trim().isEmpty) {
      return Result.error(const RequiredFieldError('espacoId'));
    }

    if (!_isValidId(espacoId)) {
      return Result.error(const InvalidFormatError('espacoId', 'ID válido'));
    }

    return Result.success(null);
  }

  Result<void> _validateImagePaths(List<String>? imagePaths) {
    if (imagePaths == null) {
      return Result.success(null);
    }

    if (imagePaths.length > _maxImagePaths) {
      return Result.error(
          const OutOfRangeError('imagePaths', 'máximo $_maxImagePaths imagens'));
    }

    for (int i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      if (path.isEmpty) {
        return Result.error(
            InvalidFormatError('imagePaths[$i]', 'caminho não pode ser vazio'));
      }

      // Validar se é um path válido (básico)
      if (_containsInvalidCharacters(path)) {
        return Result.error(
            InvalidFormatError('imagePaths[$i]', 'caminho de imagem válido'));
      }
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

  Result<void> _validateDataCadastro(DateTime? dataCadastro) {
    if (dataCadastro == null) {
      return Result.success(null);
    }

    final now = DateTime.now();

    // Data de cadastro não pode ser mais de 1 dia no futuro
    if (dataCadastro.isAfter(now.add(const Duration(days: 1)))) {
      return Result.error(
          const InvalidDateError('dataCadastro', 'não pode ser futura'));
    }

    // Data de cadastro não pode ser muito antiga (mais de 100 anos)
    if (dataCadastro.isBefore(now.subtract(const Duration(days: 365 * 100)))) {
      return Result.error(
          const InvalidDateError('dataCadastro', 'muito antiga'));
    }

    return Result.success(null);
  }

  Result<void> _validateFotoBase64(String? fotoBase64) {
    if (fotoBase64 == null) {
      return Result.success(null);
    }

    if (fotoBase64.length > _maxFotoBase64Length) {
      return Result.error(const OutOfRangeError(
          'fotoBase64', 'máximo ${_maxFotoBase64Length ~/ (1024 * 1024)}MB'));
    }

    // Validação básica de base64
    if (!_isValidBase64(fotoBase64)) {
      return Result.error(
          const InvalidFormatError('fotoBase64', 'formato base64 válido'));
    }

    return Result.success(null);
  }

  Result<void> _validateCreateSpecific(PlantaModel planta) {
    // ID deve estar vazio ou ser válido
    if (planta.id.isNotEmpty && !_isValidId(planta.id)) {
      return Result.error(const InvalidFormatError('id', 'formato válido'));
    }

    return Result.success(null);
  }

  Result<void> _validateUpdateSpecific(PlantaModel planta) {
    // ID deve ser fornecido e válido
    if (planta.id.isEmpty) {
      return Result.error(const RequiredFieldError('id'));
    }

    if (!_isValidId(planta.id)) {
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
    if (_containsInvalidCharacters(id)) return false;
    if (id.length < 3 || id.length > 100) return false;
    return true;
  }

  bool _isValidBase64(String base64String) {
    try {
      // Validação básica - regex para base64
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return base64Regex.hasMatch(base64String) && base64String.length % 4 == 0;
    } catch (e) {
      return false;
    }
  }

  /// Métodos de conveniência

  Result<void> validateNomeOnly(String? nome) {
    return _validateNome(nome);
  }

  Result<void> validateEspecieOnly(String? especie) {
    return _validateEspecie(especie);
  }

  Result<void> validateEspacoIdOnly(String? espacoId) {
    return _validateEspacoId(espacoId);
  }

  /// Valida se planta pode ser movida para outro espaço
  Future<Result<void>> validateMoveToEspaco(
    PlantaModel planta,
    String novoEspacoId,
    Future<bool> Function(String) espacoExistsFunction,
  ) async {
    if (planta.espacoId == novoEspacoId) {
      return Result.error(const InvalidStateError(
        'espacoId',
        'planta já está neste espaço',
      ));
    }

    return await validateEspacoExists(novoEspacoId, espacoExistsFunction);
  }
}

/// Factory para criação de PlantaModel validado
class PlantaModelFactory {
  static PlantaModelFactory? _instance;
  static PlantaModelFactory get instance =>
      _instance ??= PlantaModelFactory._();

  PlantaModelFactory._();

  /// Cria PlantaModel com validação completa
  Result<PlantaModel> create({
    required String nome,
    required String espacoId,
    String? especie,
    List<String>? imagePaths,
    String? observacoes,
    DateTime? dataCadastro,
    String? fotoBase64,
  }) {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    final planta = PlantaModel(
      id: '', // Será gerado pelo repository
      createdAt: nowMs,
      updatedAt: nowMs,
      nome: nome.trim(),
      especie: especie?.trim(),
      espacoId: espacoId.trim(),
      imagePaths: imagePaths,
      observacoes: observacoes?.trim(),
      comentarios: [], // Lista vazia inicialmente
      dataCadastro: dataCadastro ?? now,
      fotoBase64: fotoBase64,
    );

    return PlantaValidator.instance.validateForCreate(planta);
  }

  /// Atualiza PlantaModel existente com validação
  Result<PlantaModel> update(
    PlantaModel original, {
    String? nome,
    String? especie,
    String? espacoId,
    List<String>? imagePaths,
    String? observacoes,
    DateTime? dataCadastro,
    String? fotoBase64,
  }) {
    final plantaAtualizada = original.copyWith(
      nome: nome?.trim() ?? original.nome,
      especie: especie?.trim() ?? original.especie,
      espacoId: espacoId?.trim() ?? original.espacoId,
      imagePaths: imagePaths ?? original.imagePaths,
      observacoes: observacoes?.trim() ?? original.observacoes,
      dataCadastro: dataCadastro ?? original.dataCadastro,
      fotoBase64: fotoBase64 ?? original.fotoBase64,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    plantaAtualizada.markAsModified();

    return PlantaValidator.instance.validateForUpdate(plantaAtualizada);
  }

  /// Move planta para outro espaço com validação
  Result<PlantaModel> moveToEspaco(PlantaModel original, String novoEspacoId) {
    if (original.espacoId == novoEspacoId) {
      return Result.error(const InvalidStateError(
        'espacoId',
        'planta já está neste espaço',
      ));
    }

    return update(original, espacoId: novoEspacoId);
  }

  /// Adiciona imagem com validação
  Result<PlantaModel> addImage(PlantaModel original, String imagePath) {
    if (imagePath.trim().isEmpty) {
      return Result.error(const RequiredFieldError('imagePath'));
    }

    final currentPaths = original.imagePaths ?? [];
    if (currentPaths.contains(imagePath)) {
      return Result.error(DuplicateValueError('imagePath', imagePath));
    }

    final newPaths = [...currentPaths, imagePath.trim()];
    return update(original, imagePaths: newPaths);
  }

  /// Remove imagem com validação
  Result<PlantaModel> removeImage(PlantaModel original, String imagePath) {
    final currentPaths = original.imagePaths ?? [];
    if (!currentPaths.contains(imagePath)) {
      return Result.error(const InvalidReferenceError(
        'imagePath',
        'Imagem',
      ));
    }

    final newPaths = currentPaths.where((path) => path != imagePath).toList();
    return update(original, imagePaths: newPaths);
  }
}
