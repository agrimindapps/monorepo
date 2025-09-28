import 'package:core/core.dart';

/// Entity para resultado de busca seguindo princípios Clean Architecture
class BuscaResultEntity extends Equatable {
  final String id;
  final String tipo; // 'diagnostico', 'praga', 'defensivo', 'cultura'
  final String titulo;
  final String? subtitulo;
  final String? descricao;
  final String? imageUrl;
  final Map<String, dynamic> metadata;
  final double relevancia;

  const BuscaResultEntity({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo,
    this.descricao,
    this.imageUrl,
    this.metadata = const {},
    this.relevancia = 1.0,
  });

  @override
  List<Object?> get props => [
        id,
        tipo,
        titulo,
        subtitulo,
        descricao,
        imageUrl,
        metadata,
        relevancia,
      ];
}

/// Entity para filtros de busca
class BuscaFiltersEntity extends Equatable {
  final String? culturaId;
  final String? pragaId;
  final String? defensivoId;
  final String? query;
  final List<String> tipos;
  final Map<String, dynamic> advanced;

  const BuscaFiltersEntity({
    this.culturaId,
    this.pragaId,
    this.defensivoId,
    this.query,
    this.tipos = const [],
    this.advanced = const {},
  });

  bool get hasActiveFilters =>
      culturaId != null ||
      pragaId != null ||
      defensivoId != null ||
      (query?.isNotEmpty == true) ||
      tipos.isNotEmpty;

  int get activeFiltersCount {
    int count = 0;
    if (culturaId != null) count++;
    if (pragaId != null) count++;
    if (defensivoId != null) count++;
    if (query?.isNotEmpty == true) count++;
    if (tipos.isNotEmpty) count += tipos.length;
    return count;
  }

  BuscaFiltersEntity copyWith({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
    String? query,
    List<String>? tipos,
    Map<String, dynamic>? advanced,
  }) {
    return BuscaFiltersEntity(
      culturaId: culturaId ?? this.culturaId,
      pragaId: pragaId ?? this.pragaId,
      defensivoId: defensivoId ?? this.defensivoId,
      query: query ?? this.query,
      tipos: tipos ?? this.tipos,
      advanced: advanced ?? this.advanced,
    );
  }

  @override
  List<Object?> get props => [
        culturaId,
        pragaId,
        defensivoId,
        query,
        tipos,
        advanced,
      ];
}

/// Entity para metadados de busca (dropdowns)
class BuscaMetadataEntity extends Equatable {
  final List<DropdownItemEntity> culturas;
  final List<DropdownItemEntity> pragas;
  final List<DropdownItemEntity> defensivos;
  final List<String> tipos;

  const BuscaMetadataEntity({
    this.culturas = const [],
    this.pragas = const [],
    this.defensivos = const [],
    this.tipos = const [],
  });

  @override
  List<Object?> get props => [culturas, pragas, defensivos, tipos];
}

/// Entity para item de dropdown
class DropdownItemEntity extends Equatable {
  final String id;
  final String nome;
  final String? grupo;
  final bool isActive;

  const DropdownItemEntity({
    required this.id,
    required this.nome,
    this.grupo,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, nome, grupo, isActive];
}