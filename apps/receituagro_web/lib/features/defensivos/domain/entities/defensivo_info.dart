import 'package:equatable/equatable.dart';

/// DefensivoInfo entity - Domain layer
/// Representa informações complementares de texto longo sobre o defensivo
/// Relacionamento 1:1 com Defensivo
class DefensivoInfo extends Equatable {
  final String id;
  final String defensivoId; // FK to defensivos (1:1 relationship)

  // Informações de aplicação (HTML encoded no sistema antigo)
  final String? embalagens; // Embalagens e armazenamento
  final String? tecnologia; // Tecnologia de aplicação
  final String? pHumanas; // Precauções para saúde humana
  final String? pAmbiental; // Precauções ambientais
  final String? manejoResistencia; // Manejo de resistência
  final String? compatibilidade; // Compatibilidade com outros produtos
  final String? manejoIntegrado; // Manejo integrado de pragas

  final DateTime createdAt;
  final DateTime updatedAt;

  const DefensivoInfo({
    required this.id,
    required this.defensivoId,
    this.embalagens,
    this.tecnologia,
    this.pHumanas,
    this.pAmbiental,
    this.manejoResistencia,
    this.compatibilidade,
    this.manejoIntegrado,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        defensivoId,
        embalagens,
        tecnologia,
        pHumanas,
        pAmbiental,
        manejoResistencia,
        compatibilidade,
        manejoIntegrado,
        createdAt,
        updatedAt,
      ];

  DefensivoInfo copyWith({
    String? id,
    String? defensivoId,
    String? embalagens,
    String? tecnologia,
    String? pHumanas,
    String? pAmbiental,
    String? manejoResistencia,
    String? compatibilidade,
    String? manejoIntegrado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoInfo(
      id: id ?? this.id,
      defensivoId: defensivoId ?? this.defensivoId,
      embalagens: embalagens ?? this.embalagens,
      tecnologia: tecnologia ?? this.tecnologia,
      pHumanas: pHumanas ?? this.pHumanas,
      pAmbiental: pAmbiental ?? this.pAmbiental,
      manejoResistencia: manejoResistencia ?? this.manejoResistencia,
      compatibilidade: compatibilidade ?? this.compatibilidade,
      manejoIntegrado: manejoIntegrado ?? this.manejoIntegrado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
