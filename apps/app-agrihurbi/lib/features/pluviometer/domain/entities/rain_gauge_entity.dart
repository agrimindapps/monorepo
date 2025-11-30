import 'package:core/core.dart';

/// Entidade do domínio para Pluviômetro (Rain Gauge)
///
/// Representa um dispositivo de medição de chuva com localização GPS opcional
/// e capacidade de agrupamento.
class RainGaugeEntity extends Equatable {
  const RainGaugeEntity({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.description,
    required this.capacity,
    this.longitude,
    this.latitude,
    this.groupId,
    this.objectId,
  });

  /// ID único do pluviômetro (UUID)
  final String id;

  /// Data de criação do registro
  final DateTime? createdAt;

  /// Data da última atualização
  final DateTime? updatedAt;

  /// Flag de atividade (soft delete)
  final bool isActive;

  /// Descrição/nome do pluviômetro
  final String description;

  /// Capacidade do pluviômetro (em mm)
  final String capacity;

  /// Longitude GPS (opcional)
  final String? longitude;

  /// Latitude GPS (opcional)
  final String? latitude;

  /// FK para agrupamento opcional
  final String? groupId;

  /// Object ID do Firebase (para sincronização)
  final String? objectId;

  /// Verifica se tem localização GPS
  bool get hasLocation => longitude != null && latitude != null;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        isActive,
        description,
        capacity,
        longitude,
        latitude,
        groupId,
        objectId,
      ];

  /// Cria uma cópia da entidade com campos atualizados
  RainGaugeEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? description,
    String? capacity,
    String? longitude,
    String? latitude,
    String? groupId,
    String? objectId,
  }) {
    return RainGaugeEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      groupId: groupId ?? this.groupId,
      objectId: objectId ?? this.objectId,
    );
  }

  /// Factory para criar instância vazia para formulários
  factory RainGaugeEntity.empty() {
    return const RainGaugeEntity(
      id: '',
      isActive: true,
      description: '',
      capacity: '',
    );
  }

  @override
  String toString() {
    return 'RainGaugeEntity(id: $id, description: $description, capacity: $capacity, hasLocation: $hasLocation)';
  }
}
