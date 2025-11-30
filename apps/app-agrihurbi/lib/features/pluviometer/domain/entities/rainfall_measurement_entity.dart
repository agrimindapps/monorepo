import 'package:core/core.dart';

/// Entidade do domínio para Medição Pluviométrica (Rainfall Measurement)
///
/// Representa uma medição de chuva registrada em um pluviômetro específico,
/// com timestamp e quantidade em milímetros.
class RainfallMeasurementEntity extends Equatable {
  const RainfallMeasurementEntity({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.rainGaugeId,
    required this.measurementDate,
    required this.amount,
    this.observations,
    this.objectId,
  });

  /// ID único da medição (UUID)
  final String id;

  /// Data de criação do registro
  final DateTime? createdAt;

  /// Data da última atualização
  final DateTime? updatedAt;

  /// Flag de atividade (soft delete)
  final bool isActive;

  /// FK para o pluviômetro
  final String rainGaugeId;

  /// Data/hora da medição
  final DateTime measurementDate;

  /// Quantidade de chuva em mm
  final double amount;

  /// Observações opcionais
  final String? observations;

  /// Object ID do Firebase (para sincronização)
  final String? objectId;

  /// Verifica se é uma medição significativa (> 0.1mm)
  bool get isSignificant => amount > 0.1;

  /// Retorna a quantidade formatada com unidade
  String get formattedAmount => '${amount.toStringAsFixed(1)} mm';

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        isActive,
        rainGaugeId,
        measurementDate,
        amount,
        observations,
        objectId,
      ];

  /// Cria uma cópia da entidade com campos atualizados
  RainfallMeasurementEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? rainGaugeId,
    DateTime? measurementDate,
    double? amount,
    String? observations,
    String? objectId,
  }) {
    return RainfallMeasurementEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rainGaugeId: rainGaugeId ?? this.rainGaugeId,
      measurementDate: measurementDate ?? this.measurementDate,
      amount: amount ?? this.amount,
      observations: observations ?? this.observations,
      objectId: objectId ?? this.objectId,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory RainfallMeasurementEntity.empty({String? rainGaugeId}) {
    return RainfallMeasurementEntity(
      id: '',
      isActive: true,
      rainGaugeId: rainGaugeId ?? '',
      measurementDate: DateTime.now(),
      amount: 0.0,
    );
  }

  @override
  String toString() {
    return 'RainfallMeasurementEntity(id: $id, rainGaugeId: $rainGaugeId, date: $measurementDate, amount: $formattedAmount)';
  }
}
