// Package imports:
import 'package:get/get.dart';
import 'package:synchronized/synchronized.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_repository.dart';
import '../../../shared/utils/string_comparison_utils.dart';
import '../interfaces/espacos_repository_interface.dart';
import '../interfaces/plantas_repository_interface.dart';

class EspacosService {
  // Lock para prevenir race conditions na validação
  static final _validationLock = Lock();

  final IEspacosRepository _espacosRepository;
  final IPlantasRepository _plantasRepository;

  EspacosService({
    IEspacosRepository? espacosRepository,
    IPlantasRepository? plantasRepository,
  })  : _espacosRepository = espacosRepository ?? _EspacosRepositoryAdapter(),
        _plantasRepository = plantasRepository ?? _PlantasRepositoryAdapter();

  /// Valida os dados do espaço
  ValidationResult validateEspaco(String nome,
      {String? excludeId, List<EspacoModel>? existingEspacos}) {
    final errors = <String, String>{};

    // Validação do nome
    final nomeTrimmed = nome.trim();
    if (nomeTrimmed.isEmpty) {
      errors['nome'] = 'espacos.nome_obrigatorio_validacao'.tr;
    } else if (nomeTrimmed.length < 2) {
      errors['nome'] = 'espacos.nome_minimo'.tr;
    } else if (nomeTrimmed.length > 30) {
      errors['nome'] = 'espacos.nome_maximo'.tr;
    }

    // Verificação de duplicatas usando normalização consistente
    if (existingEspacos != null && errors.isEmpty) {
      // FIXED: Usa comparação normalizada para caracteres acentuados
      final hasNameConflict = existingEspacos.any((espaco) {
        if (excludeId != null && espaco.id == excludeId) {
          return false;
        }
        return StringComparisonUtils.equals(espaco.nome, nomeTrimmed);
      });

      if (hasNameConflict) {
        errors['nome'] = 'espacos.nome_duplicado'.tr;
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Normaliza nome do espaço para comparação
  /// FIXED: Usa normalização robusta para caracteres especiais
  String _normalizeSpaceName(String name) {
    return StringComparisonUtils.normalize(name)
        .replaceAll(RegExp(r'\s+'), ' '); // Remove espaços múltiplos
  }

  /// Validação assíncrona para verificar duplicatas no repository
  Future<ValidationResult> validateEspacoAsync(String nome,
      {String? excludeId}) async {
    final errors = <String, String>{};

    // Validação básica do nome
    final basicValidation = validateEspaco(nome, excludeId: excludeId);
    if (!basicValidation.isValid) {
      return basicValidation;
    }

    // Verificação assíncrona no repository com lock para prevenir race conditions
    await _validationLock.synchronized(() async {
      final exists =
          await _espacosRepository.existeComNome(nome, excluirId: null);
      if (exists) {
        errors['nome'] = 'espacos.nome_duplicado'.tr;
      }
    });

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Cria um novo espaço
  EspacoModel createEspaco(String nome) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return EspacoModel(
      id: _generateId(),
      createdAt: now,
      updatedAt: now,
      nome: nome.trim(),
      descricao: null,
      dataCriacao: DateTime.now(),
      ativo: true,
    );
  }

  /// Atualiza um espaço existente
  EspacoModel updateEspaco(EspacoModel espaco, {String? nome}) {
    return EspacoModel(
      id: espaco.id,
      createdAt: espaco.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      nome: nome?.trim() ?? espaco.nome,
      descricao: espaco.descricao,
      dataCriacao: espaco.dataCriacao,
      ativo: espaco.ativo,
    );
  }

  /// Gera um ID único
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Ordena espaços por nome
  /// FIXED: Usa comparação internacional para ordenação correta
  List<EspacoModel> sortEspacos(List<EspacoModel> espacos,
      {bool ascending = true}) {
    final sorted = List<EspacoModel>.from(espacos);
    sorted.sort((a, b) {
      final comparison = StringComparisonUtils.compare(a.nome, b.nome);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Filtra espaços por nome
  /// FIXED: Usa busca normalizada para caracteres acentuados
  List<EspacoModel> filterEspacos(
      List<EspacoModel> espacos, String searchText) {
    if (searchText.isEmpty) return espacos;

    final searchTerm = searchText.trim();
    return espacos.where((espaco) {
      return StringComparisonUtils.contains(espaco.nome, searchTerm) ||
          (espaco.descricao != null &&
              StringComparisonUtils.contains(espaco.descricao!, searchTerm));
    }).toList();
  }

  /// Verifica se espaço pode ser removido (sem plantas)
  Future<bool> canRemoveEspaco(EspacoModel espaco) async {
    final plantas = await _plantasRepository.findByEspaco(espaco.id);
    return plantas.isEmpty;
  }

  /// Conta plantas por espaço
  Future<int> countPlantasInEspaco(String espacoId) async {
    final plantas = await _plantasRepository.findByEspaco(espacoId);
    return plantas.length;
  }

  /// Formata nome do espaço
  String formatEspacoName(String nome) {
    return nome
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const {},
  });

  String? getError(String field) => errors[field];
  bool hasError(String field) => errors.containsKey(field);
}

// Adapters para implementar as interfaces usando os repositories existentes
class _EspacosRepositoryAdapter implements IEspacosRepository {
  final EspacoRepository _repository = EspacoRepository.instance;

  @override
  Future<void> initialize() => _repository.initialize();

  @override
  Future<List<EspacoModel>> findAll() => _repository.findAll();

  @override
  Future<EspacoModel?> findById(String id) => _repository.findById(id);

  @override
  Future<String> create(EspacoModel espaco) => _repository.createLegacy(espaco);

  @override
  Future<void> update(String id, EspacoModel espaco) =>
      _repository.updateLegacy(id, espaco);

  @override
  Future<void> delete(String id) => _repository.delete(id);

  @override
  Future<String> salvar(EspacoModel espaco) => _repository.salvarLegacy(espaco);

  @override
  Future<bool> existeComNome(String nome, {String? excluirId}) =>
      _repository.existeComNome(nome, excludeId: excluirId);

  @override
  Stream<List<EspacoModel>> get espacosStream => _repository.espacosStream;
}

class _PlantasRepositoryAdapter implements IPlantasRepository {
  final PlantaRepository _repository = PlantaRepository.instance;

  @override
  Future<void> initialize() => _repository.initialize();

  @override
  Future<List<dynamic>> findByEspaco(String espacoId) =>
      _repository.findByEspaco(espacoId);
}
