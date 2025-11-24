

import '../../domain/entities/defensivo_entity.dart';

/// Service responsible for querying and extracting metadata from defensivos.
///
/// This service encapsulates logic for extracting distinct values from defensivos,
/// such as classes, fabricantes, and modos de ação. Separating this from the
/// repository improves Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Extract distinct classes agronômicas
/// - Extract distinct fabricantes
/// - Extract distinct modos de ação
/// - Get recent defensivos
/// - Get defensive by ID with validation
abstract class IDefensivosQueryService {
  /// Extract all distinct classe agronômica values from defensivos
  List<String> getClassesAgronomicas(List<DefensivoEntity> defensivos);

  /// Extract all distinct fabricante values from defensivos
  List<String> getFabricantes(List<DefensivoEntity> defensivos);

  /// Extract all distinct modo de ação values from defensivos
  List<String> getModosAcao(List<DefensivoEntity> defensivos);

  /// Get the most recent defensivos (first N items)
  List<DefensivoEntity> getRecentes(
    List<DefensivoEntity> defensivos, {
    int limit = 10,
  });

  /// Check if a defensivo is active by checking if it exists
  bool isDefensivoActive(List<DefensivoEntity> defensivos, String defensivoId);
}

/// Default implementation of query service

class DefensivosQueryService implements IDefensivosQueryService {
  @override
  List<String> getClassesAgronomicas(List<DefensivoEntity> defensivos) {
    final classes = defensivos
        .map((defensivo) => defensivo.classeAgronomica)
        .where((classe) => classe != null && classe.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    classes.sort();
    return classes;
  }

  @override
  List<String> getFabricantes(List<DefensivoEntity> defensivos) {
    final fabricantes = defensivos
        .map((defensivo) => defensivo.fabricante)
        .where((fabricante) => fabricante != null && fabricante.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    fabricantes.sort();
    return fabricantes;
  }

  @override
  List<String> getModosAcao(List<DefensivoEntity> defensivos) {
    final modosAcao = defensivos
        .map((defensivo) => defensivo.modoAcao)
        .where((modo) => modo != null && modo.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    modosAcao.sort();
    return modosAcao;
  }

  @override
  List<DefensivoEntity> getRecentes(
    List<DefensivoEntity> defensivos, {
    int limit = 10,
  }) {
    return defensivos.take(limit).toList();
  }

  @override
  bool isDefensivoActive(List<DefensivoEntity> defensivos, String defensivoId) {
    return defensivos.any((d) => d.id == defensivoId);
  }
}
