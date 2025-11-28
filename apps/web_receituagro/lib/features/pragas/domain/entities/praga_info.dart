import 'package:equatable/equatable.dart';

/// PragaInfo entity - Domain layer
/// Representa informações complementares para Insetos e Doenças (TBPRAGASINF)
/// Relacionamento 1:1 com Praga
class PragaInfo extends Equatable {
  final String id;
  final String pragaId; // FK to pragas (1:1 relationship)

  // Informações de pragas (insetos/doenças)
  final String? descricao; // Descrição geral
  final String? sintomas; // Sintomas na planta
  final String? bioecologia; // Ciclo de vida, comportamento
  final String? controle; // Métodos de controle

  final DateTime createdAt;
  final DateTime updatedAt;

  const PragaInfo({
    required this.id,
    required this.pragaId,
    this.descricao,
    this.sintomas,
    this.bioecologia,
    this.controle,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        pragaId,
        descricao,
        sintomas,
        bioecologia,
        controle,
        createdAt,
        updatedAt,
      ];

  PragaInfo copyWith({
    String? id,
    String? pragaId,
    String? descricao,
    String? sintomas,
    String? bioecologia,
    String? controle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PragaInfo(
      id: id ?? this.id,
      pragaId: pragaId ?? this.pragaId,
      descricao: descricao ?? this.descricao,
      sintomas: sintomas ?? this.sintomas,
      bioecologia: bioecologia ?? this.bioecologia,
      controle: controle ?? this.controle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create an empty PragaInfo for a given pragaId
  factory PragaInfo.empty(String pragaId) {
    final now = DateTime.now();
    return PragaInfo(
      id: '',
      pragaId: pragaId,
      createdAt: now,
      updatedAt: now,
    );
  }
}
