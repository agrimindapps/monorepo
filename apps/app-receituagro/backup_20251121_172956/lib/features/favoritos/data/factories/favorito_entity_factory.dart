import '../../domain/entities/favorito_entity.dart';

/// Abstract factory for creating FavoritoEntity based on type.
/// This eliminates the switch case from FavoritosService (OCP violation fix).
///
/// Strategy Pattern: Each tipo has its own factory implementation
/// Benefit: Adding new tipos doesn't require modifying existing code
abstract class IFavoritoEntityFactory {
  /// Create entity from data map
  FavoritoEntity create({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Check if this factory handles the given type
  bool canHandle(String tipo);
}

/// Factory for Defensivo favoritos
class FavoritoDefensivoEntityFactory implements IFavoritoEntityFactory {
  @override
  FavoritoEntity create({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoDefensivoEntity(
      id: id,
      nomeComum: data['nomeComum'] as String? ?? '',
      ingredienteAtivo: data['ingredienteAtivo'] as String? ?? '',
      fabricante: data['fabricante'] as String?,
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  bool canHandle(String tipo) => tipo == 'defensivo';
}

/// Factory for Praga favoritos
class FavoritoPragaEntityFactory implements IFavoritoEntityFactory {
  @override
  FavoritoEntity create({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoPragaEntity(
      id: id,
      nomeComum: data['nomeComum'] as String? ?? '',
      nomeCientifico: data['nomeCientifico'] as String? ?? '',
      tipoPraga: data['tipoPraga'] as String? ?? '1',
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  bool canHandle(String tipo) => tipo == 'praga';
}

/// Factory for Diagnostico favoritos
class FavoritoDiagnosticoEntityFactory implements IFavoritoEntityFactory {
  @override
  FavoritoEntity create({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoDiagnosticoEntity(
      id: id,
      nomePraga: data['nomePraga'] as String? ?? '',
      nomeDefensivo: data['nomeDefensivo'] as String? ?? '',
      cultura: data['cultura'] as String? ?? '',
      dosagem: data['dosagem'] as String? ?? '',
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  bool canHandle(String tipo) => tipo == 'diagnostico';
}

/// Factory for Cultura favoritos
class FavoritoCulturaEntityFactory implements IFavoritoEntityFactory {
  @override
  FavoritoEntity create({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FavoritoCulturaEntity(
      id: id,
      nomeCultura: data['nomeCultura'] as String? ?? '',
      descricao: data['descricao'] as String?,
      adicionadoEm: DateTime.now(),
    );
  }

  @override
  bool canHandle(String tipo) => tipo == 'cultura';
}
