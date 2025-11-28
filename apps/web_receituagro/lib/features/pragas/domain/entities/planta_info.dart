import 'package:equatable/equatable.dart';

/// PlantaInfo entity - Domain layer
/// Representa informações complementares para Plantas Daninhas (TBPLANTASINF)
/// Relacionamento 1:1 com Praga (quando tipoPraga == 'planta')
class PlantaInfo extends Equatable {
  final String id;
  final String pragaId; // FK to pragas (1:1 relationship)

  // Informações gerais da planta
  final String? ciclo; // Anual, Perene, Bienal
  final String? reproducao; // Sementes, Vegetativa, Ambas
  final String? habitat; // Onde ocorre
  final String? adaptacoes; // Adaptações especiais
  final String? altura; // Altura da planta

  // Características morfológicas - Folhas
  final String? filotaxia; // Disposição das folhas (Alterna, Oposta, Verticilada)
  final String? formaLimbo; // Forma da folha
  final String? superficie; // Textura da superfície
  final String? consistencia; // Membranácea, Coriácea
  final String? nervacao; // Tipo de nervuras
  final String? nervacaoComprimento; // Comprimento das nervuras

  // Características reprodutivas
  final String? inflorescencia; // Tipo de inflorescência
  final String? perianto; // Estrutura floral
  final String? tipologiaFruto; // Tipo de fruto

  // Observações
  final String? observacoes; // Observações gerais

  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantaInfo({
    required this.id,
    required this.pragaId,
    this.ciclo,
    this.reproducao,
    this.habitat,
    this.adaptacoes,
    this.altura,
    this.filotaxia,
    this.formaLimbo,
    this.superficie,
    this.consistencia,
    this.nervacao,
    this.nervacaoComprimento,
    this.inflorescencia,
    this.perianto,
    this.tipologiaFruto,
    this.observacoes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        pragaId,
        ciclo,
        reproducao,
        habitat,
        adaptacoes,
        altura,
        filotaxia,
        formaLimbo,
        superficie,
        consistencia,
        nervacao,
        nervacaoComprimento,
        inflorescencia,
        perianto,
        tipologiaFruto,
        observacoes,
        createdAt,
        updatedAt,
      ];

  PlantaInfo copyWith({
    String? id,
    String? pragaId,
    String? ciclo,
    String? reproducao,
    String? habitat,
    String? adaptacoes,
    String? altura,
    String? filotaxia,
    String? formaLimbo,
    String? superficie,
    String? consistencia,
    String? nervacao,
    String? nervacaoComprimento,
    String? inflorescencia,
    String? perianto,
    String? tipologiaFruto,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantaInfo(
      id: id ?? this.id,
      pragaId: pragaId ?? this.pragaId,
      ciclo: ciclo ?? this.ciclo,
      reproducao: reproducao ?? this.reproducao,
      habitat: habitat ?? this.habitat,
      adaptacoes: adaptacoes ?? this.adaptacoes,
      altura: altura ?? this.altura,
      filotaxia: filotaxia ?? this.filotaxia,
      formaLimbo: formaLimbo ?? this.formaLimbo,
      superficie: superficie ?? this.superficie,
      consistencia: consistencia ?? this.consistencia,
      nervacao: nervacao ?? this.nervacao,
      nervacaoComprimento: nervacaoComprimento ?? this.nervacaoComprimento,
      inflorescencia: inflorescencia ?? this.inflorescencia,
      perianto: perianto ?? this.perianto,
      tipologiaFruto: tipologiaFruto ?? this.tipologiaFruto,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create an empty PlantaInfo for a given pragaId
  factory PlantaInfo.empty(String pragaId) {
    final now = DateTime.now();
    return PlantaInfo(
      id: '',
      pragaId: pragaId,
      createdAt: now,
      updatedAt: now,
    );
  }
}
