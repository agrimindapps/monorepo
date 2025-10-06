import 'package:core/core.dart';

import 'defensivo_entity.dart';

/// Entity que representa um grupo de defensivos para drill-down navigation
/// Seguindo princípios Clean Architecture
class DefensivoGroupEntity extends Equatable {
  final String id;
  final String nome;
  final String tipoAgrupamento;
  final int quantidadeItens;
  final List<DefensivoEntity> itens;
  final String? descricao;
  final DateTime? lastUpdated;

  const DefensivoGroupEntity({
    required this.id,
    required this.nome,
    required this.tipoAgrupamento,
    required this.quantidadeItens,
    required this.itens,
    this.descricao,
    this.lastUpdated,
  });

  /// Nome para exibição do grupo
  String get displayName => nome.isNotEmpty ? nome : 'Grupo sem nome';

  /// Descrição para exibição
  String get displayDescricao => descricao ?? '';

  /// Contador formatado para exibição
  String get displayCount => '$quantidadeItens defensivo${quantidadeItens != 1 ? 's' : ''}';

  /// Verifica se o grupo tem itens
  bool get hasItems => quantidadeItens > 0 && itens.isNotEmpty;

  /// Verifica se o grupo está vazio
  bool get isEmpty => quantidadeItens == 0 || itens.isEmpty;

  /// Factory para criar grupo a partir de lista de defensivos
  factory DefensivoGroupEntity.fromDefensivos({
    required String tipoAgrupamento,
    required String nomeGrupo,
    required List<DefensivoEntity> defensivos,
    String? descricao,
  }) {
    return DefensivoGroupEntity(
      id: '${tipoAgrupamento}_${nomeGrupo.toLowerCase().replaceAll(' ', '_')}',
      nome: nomeGrupo,
      tipoAgrupamento: tipoAgrupamento,
      quantidadeItens: defensivos.length,
      itens: List<DefensivoEntity>.from(defensivos),
      descricao: descricao,
      lastUpdated: DateTime.now(),
    );
  }

  /// Factory para criar grupo vazio
  factory DefensivoGroupEntity.empty({
    required String tipoAgrupamento,
    required String nomeGrupo,
  }) {
    return DefensivoGroupEntity(
      id: '${tipoAgrupamento}_${nomeGrupo.toLowerCase().replaceAll(' ', '_')}',
      nome: nomeGrupo,
      tipoAgrupamento: tipoAgrupamento,
      quantidadeItens: 0,
      itens: const <DefensivoEntity>[],
      lastUpdated: DateTime.now(),
    );
  }

  /// CopyWith method para atualizações
  DefensivoGroupEntity copyWith({
    String? id,
    String? nome,
    String? tipoAgrupamento,
    int? quantidadeItens,
    List<DefensivoEntity>? itens,
    String? descricao,
    DateTime? lastUpdated,
  }) {
    return DefensivoGroupEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipoAgrupamento: tipoAgrupamento ?? this.tipoAgrupamento,
      quantidadeItens: quantidadeItens ?? this.quantidadeItens,
      itens: itens ?? this.itens,
      descricao: descricao ?? this.descricao,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Filtra itens do grupo por texto
  DefensivoGroupEntity filtrarItens(String filtroTexto) {
    if (filtroTexto.isEmpty) return this;

    final filtroLower = filtroTexto.toLowerCase();
    final itensFiltrados = itens.where((defensivo) {
      return defensivo.displayName.toLowerCase().contains(filtroLower) ||
             defensivo.displayIngredient.toLowerCase().contains(filtroLower) ||
             defensivo.displayFabricante.toLowerCase().contains(filtroLower) ||
             defensivo.displayClass.toLowerCase().contains(filtroLower);
    }).toList();

    return copyWith(
      quantidadeItens: itensFiltrados.length,
      itens: itensFiltrados,
    );
  }

  /// Ordena itens do grupo
  DefensivoGroupEntity ordenarItens({required bool ascending}) {
    final itensOrdenados = List<DefensivoEntity>.from(itens);
    itensOrdenados.sort((a, b) {
      final comparison = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      return ascending ? comparison : -comparison;
    });

    return copyWith(itens: itensOrdenados);
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        tipoAgrupamento,
        quantidadeItens,
        itens,
        descricao,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'DefensivoGroupEntity(id: $id, nome: $nome, tipoAgrupamento: $tipoAgrupamento, quantidadeItens: $quantidadeItens)';
  }
}
