import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Modelo de domínio para entrada de auditoria financeira
///
/// Representa uma entrada no audit trail que registra operações
/// financeiras para compliance e debugging.
class AuditTrailEntry extends Equatable {
  const AuditTrailEntry({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.eventType,
    required this.timestamp,
    this.userId,
    this.beforeState = const {},
    this.afterState = const {},
    this.description,
    this.monetaryValue,
    this.metadata = const {},
    this.syncSource,
  });

  /// Factory constructor para criar nova entrada
  factory AuditTrailEntry.create({
    required String entityId,
    required String entityType,
    required String eventType,
    String? userId,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? description,
    double? monetaryValue,
    Map<String, dynamic>? metadata,
    String? syncSource,
  }) {
    return AuditTrailEntry(
      id: const Uuid().v4(),
      entityId: entityId,
      entityType: entityType,
      eventType: eventType,
      timestamp: DateTime.now(),
      userId: userId,
      beforeState: beforeState ?? const {},
      afterState: afterState ?? const {},
      description: description,
      monetaryValue: monetaryValue,
      metadata: metadata ?? const {},
      syncSource: syncSource,
    );
  }

  /// Cria instância a partir de Map
  factory AuditTrailEntry.fromMap(Map<String, dynamic> map) {
    return AuditTrailEntry(
      id: map['id'] as String,
      entityId: map['entityId'] as String,
      entityType: map['entityType'] as String,
      eventType: map['eventType'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      userId: map['userId'] as String?,
      beforeState:
          (map['beforeState'] as Map<dynamic, dynamic>?)
              ?.cast<String, dynamic>() ??
          {},
      afterState:
          (map['afterState'] as Map<dynamic, dynamic>?)
              ?.cast<String, dynamic>() ??
          {},
      description: map['description'] as String?,
      monetaryValue: map['monetaryValue'] as double?,
      metadata:
          (map['metadata'] as Map<dynamic, dynamic>?)
              ?.cast<String, dynamic>() ??
          {},
      syncSource: map['syncSource'] as String?,
    );
  }

  /// ID único da entrada
  final String id;

  /// ID da entidade auditada (veículo, despesa, abastecimento, etc.)
  final String entityId;

  /// Tipo da entidade (vehicle, expense, fuel_supply, maintenance)
  final String entityType;

  /// Tipo do evento (CREATE, UPDATE, DELETE, SYNC, etc.)
  final String eventType;

  /// Timestamp do evento
  final DateTime timestamp;

  /// ID do usuário que realizou a operação
  final String? userId;

  /// Estado anterior da entidade
  final Map<String, dynamic> beforeState;

  /// Estado posterior da entidade
  final Map<String, dynamic> afterState;

  /// Descrição da operação
  final String? description;

  /// Valor monetário envolvido na operação
  final double? monetaryValue;

  /// Metadados adicionais
  final Map<String, dynamic> metadata;

  /// Fonte da sincronização (local, remote, conflict_resolution)
  final String? syncSource;

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityId': entityId,
      'entityType': entityType,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'beforeState': beforeState,
      'afterState': afterState,
      'description': description,
      'monetaryValue': monetaryValue,
      'metadata': metadata,
      'syncSource': syncSource,
    };
  }

  /// Cria cópia com campos modificados
  AuditTrailEntry copyWith({
    String? id,
    String? entityId,
    String? entityType,
    String? eventType,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? description,
    double? monetaryValue,
    Map<String, dynamic>? metadata,
    String? syncSource,
  }) {
    return AuditTrailEntry(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      beforeState: beforeState ?? this.beforeState,
      afterState: afterState ?? this.afterState,
      description: description ?? this.description,
      monetaryValue: monetaryValue ?? this.monetaryValue,
      metadata: metadata ?? this.metadata,
      syncSource: syncSource ?? this.syncSource,
    );
  }

  @override
  String toString() {
    final formattedValue = monetaryValue != null
        ? 'R\$ ${monetaryValue!.toStringAsFixed(2)}'
        : 'N/A';
    return 'AuditTrailEntry(entityId: $entityId, eventType: $eventType, monetaryValue: $formattedValue)';
  }

  @override
  List<Object?> get props => [
    id,
    entityId,
    entityType,
    eventType,
    timestamp,
    userId,
    beforeState,
    afterState,
    description,
    monetaryValue,
    metadata,
    syncSource,
  ];
}
