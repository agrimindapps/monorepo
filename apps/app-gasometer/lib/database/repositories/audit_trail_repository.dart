import 'dart:convert';
import '../../../core/drift_exports.dart';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../core/data/models/audit_trail_model.dart';
import '../gasometer_database.dart';

/// Repositório de Auditoria usando Drift
///
/// Gerencia todas as operações de CRUD e queries relacionadas ao audit trail
/// usando o banco de dados Drift.
class AuditTrailRepository {
  AuditTrailRepository(this._db);

  final GasometerDatabase? _db;

  /// Converte dados do Drift para domínio
  AuditTrailEntry fromData(AuditTrailData data) {
    return AuditTrailEntry(
      id: data.id.toString(),
      entityId: data.entityId,
      entityType: data.entityType,
      eventType: data.eventType,
      timestamp: data.timestamp,
      userId: data.userId,
      beforeState: _deserializeJson(data.beforeState),
      afterState: _deserializeJson(data.afterState),
      description: data.description,
      monetaryValue: data.monetaryValue,
      metadata: _deserializeJson(data.metadata),
      syncSource: data.syncSource,
    );
  }

  /// Converte dados do domínio para Drift
  Insertable<AuditTrailData> toCompanion(AuditTrailEntry entity) {
    final id = int.tryParse(entity.id);
    return AuditTrailCompanion(
      id: id != null ? Value(id) : const Value.absent(),
      entityId: Value(entity.entityId),
      entityType: Value(entity.entityType),
      eventType: Value(entity.eventType),
      timestamp: Value(entity.timestamp),
      userId: Value(entity.userId),
      beforeState: Value(_serializeJson(entity.beforeState)),
      afterState: Value(_serializeJson(entity.afterState)),
      description: Value(entity.description),
      monetaryValue: Value(entity.monetaryValue),
      metadata: Value(_serializeJson(entity.metadata)),
      syncSource: Value(entity.syncSource),
    );
  }

  /// Busca entradas de auditoria por entidade
  Future<List<AuditTrailEntry>> getByEntity(String entityId) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.auditTrail)
      ..where((t) => t.entityId.equals(entityId));
    final results = await query.get();
    return results.map(fromData).toList();
  }

  /// Busca entradas de auditoria por tipo de entidade
  Future<List<AuditTrailEntry>> getByEntityType(String entityType) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.auditTrail)
      ..where((t) => t.entityType.equals(entityType));
    final results = await query.get();
    return results.map(fromData).toList();
  }

  /// Busca entradas de auditoria por tipo de evento
  Future<List<AuditTrailEntry>> getByEventType(String eventType) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.auditTrail)
      ..where((t) => t.eventType.equals(eventType));
    final results = await query.get();
    return results.map(fromData).toList();
  }

  /// Busca entradas de auditoria por período
  Future<List<AuditTrailEntry>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.auditTrail)
      ..where((t) => t.timestamp.isBetweenValues(start, end));
    final results = await query.get();
    return results.map(fromData).toList();
  }

  /// Busca transações de alto valor
  Future<List<AuditTrailEntry>> getHighValueTransactions({
    double minValue = 1000.0,
    int days = 30,
  }) async {
    if (_db == null) return [];
    final startDate = DateTime.now().subtract(Duration(days: days));
    final query = _db!.select(_db!.auditTrail)
      ..where(
        (t) =>
            t.timestamp.isBiggerThanValue(startDate) &
            t.monetaryValue.isBiggerThanValue(minValue),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
    final results = await query.get();
    return results.map(fromData).toList();
  }

  /// Conta total de entradas de auditoria
  Future<int> countEntries() async {
    if (_db == null) return 0;
    final query = _db!.selectOnly(_db!.auditTrail)
      ..addColumns([_db!.auditTrail.id.count()]);
    final result = await query.getSingle();
    return result.read(_db!.auditTrail.id.count()) ?? 0;
  }

  /// Limpa entradas antigas (mais de X dias)
  Future<int> cleanOldEntries(int daysToKeep) async {
    if (_db == null) return 0;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await (_db!.delete(
      _db!.auditTrail,
    )..where((t) => t.timestamp.isSmallerThanValue(cutoffDate))).go();
  }

  /// Helper para serializar Map para JSON string
  String _serializeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return '{}';
    }
  }

  /// Helper para deserializar JSON string para Map
  Map<String, dynamic> _deserializeJson(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Insere uma nova entrada de auditoria
  Future<int> insert(AuditTrailEntry entry) async {
    if (_db == null) return 0;
    return await _db!.into(_db!.auditTrail).insert(toCompanion(entry));
  }
}
