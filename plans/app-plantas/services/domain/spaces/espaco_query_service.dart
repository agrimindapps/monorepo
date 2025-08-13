// Dart imports:
import 'dart:async';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../shared/utils/string_comparison_utils.dart';

/// Serviço para consultas complexas e streams de Espaços
/// Responsabilidade: Consultas avançadas e streams otimizadas
class EspacoQueryService {
  static EspacoQueryService? _instance;
  static EspacoQueryService get instance =>
      _instance ??= EspacoQueryService._();

  final EspacoRepository _repository = EspacoRepository.instance;

  EspacoQueryService._();

  /// Stream de espaços ativos otimizada
  Stream<List<EspacoModel>> get activeSpacessStream {
    return _repository.espacosStream
        .map((espacos) => espacos.where((espaco) => espaco.ativo).toList());
  }

  /// Stream de espaços inativos otimizada
  Stream<List<EspacoModel>> get inactiveSpacessStream {
    return _repository.espacosStream
        .map((espacos) => espacos.where((espaco) => !espaco.ativo).toList());
  }

  /// Buscar espaços por nome com filtro otimizado
  /// FIXED: Usa comparação normalizada para caracteres acentuados
  Future<List<EspacoModel>> searchByName(String query) async {
    if (query.trim().isEmpty) return await _repository.findAtivos();

    final espacos = await _repository.findAtivos();

    return espacos
        .where((espaco) =>
            StringComparisonUtils.contains(espaco.nome, query.trim()))
        .toList();
  }

  /// Verificar se existe espaço com nome (normalizado para acentos)
  /// FIXED: Usa comparação normalizada para caracteres acentuados
  Future<bool> existsWithName(String name, {String? excludeId}) async {
    final espacos = await _repository.findAll();

    return espacos.any((espaco) =>
        StringComparisonUtils.equals(espaco.nome.trim(), name.trim()) &&
        espaco.ativo &&
        (excludeId == null || espaco.id != excludeId));
  }

  /// Buscar espaços com paginação
  Future<List<EspacoModel>> findPaginated({
    int page = 0,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    final allEspacos = activeOnly
        ? await _repository.findAtivos()
        : await _repository.findAll();

    final startIndex = page * limit;
    final endIndex = (startIndex + limit).clamp(0, allEspacos.length);

    if (startIndex >= allEspacos.length) return <EspacoModel>[];

    return allEspacos.sublist(startIndex, endIndex);
  }

  /// Buscar espaços ordenados por nome
  /// FIXED: Usa comparação internacional para ordenação correta
  Future<List<EspacoModel>> findSortedByName({bool ascending = true}) async {
    final espacos = await _repository.findAtivos();
    espacos.sort((a, b) => ascending
        ? StringComparisonUtils.compare(a.nome, b.nome)
        : StringComparisonUtils.compare(b.nome, a.nome));
    return espacos;
  }

  /// Buscar espaços criados em período
  Future<List<EspacoModel>> findCreatedInPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final espacos = await _repository.findAll();
    return espacos.where((espaco) {
      final createdAt = espaco.dataCriacao;
      return createdAt != null &&
          createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
