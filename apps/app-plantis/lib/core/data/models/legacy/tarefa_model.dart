// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../base_sync_model.dart';

part 'tarefa_model.g.dart';

/// Tarefa model with Firebase sync support
/// TypeId: 3 - Sequential numbering
@HiveType(typeId: 3)
// ignore: must_be_immutable
class TarefaModel extends BaseSyncModel {
  // Sync fields from BaseSyncModel (stored as milliseconds for Hive)
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int? createdAtMs;
  @HiveField(2)
  final int? updatedAtMs;
  @HiveField(3)
  final int? lastSyncAtMs;
  @override
  @HiveField(4)
  final bool isDirty;
  @override
  @HiveField(5)
  final bool isDeleted;
  @override
  @HiveField(6)
  final int version;
  @override
  @HiveField(7)
  final String? userId;
  @override
  @HiveField(8)
  final String? moduleName;

  // Tarefa specific fields
  @HiveField(10)
  final String plantaId;
  @HiveField(11)
  final String tipoCuidado;
  @HiveField(12)
  final DateTime dataExecucao;
  @HiveField(13)
  final bool concluida;
  @HiveField(14)
  final String? observacoes;
  @HiveField(15)
  final DateTime? dataConclusao;

  TarefaModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'plantis',
    required this.plantaId,
    required this.tipoCuidado,
    required this.dataExecucao,
    this.concluida = false,
    this.observacoes,
    this.dataConclusao,
  }) : super(
         id: id,
         createdAt:
             createdAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
                 : null,
         updatedAt:
             updatedAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
                 : null,
         lastSyncAt:
             lastSyncAtMs != null
                 ? DateTime.fromMillisecondsSinceEpoch(lastSyncAtMs)
                 : null,
         isDirty: isDirty,
         isDeleted: isDeleted,
         version: version,
         userId: userId,
         moduleName: moduleName,
       );

  @override
  String get collectionName => 'tarefas';

  /// Factory constructor for creating new tarefa
  factory TarefaModel.create({
    String? id,
    String? userId,
    required String plantaId,
    required String tipoCuidado,
    required DateTime dataExecucao,
    bool concluida = false,
    String? observacoes,
    DateTime? dataConclusao,
  }) {
    final now = DateTime.now();
    final tarefaId = id ?? now.millisecondsSinceEpoch.toString();

    return TarefaModel(
      id: tarefaId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      plantaId: plantaId,
      tipoCuidado: tipoCuidado,
      dataExecucao: dataExecucao,
      concluida: concluida,
      observacoes: observacoes,
      dataConclusao: dataConclusao,
    );
  }

  /// Create from Hive map
  factory TarefaModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return TarefaModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantaId: map['plantaId']?.toString() ?? '',
      tipoCuidado: map['tipoCuidado']?.toString() ?? '',
      dataExecucao: DateTime.parse(map['dataExecucao'] as String),
      concluida: (map['concluida'] as bool?) ?? false,
      observacoes: map['observacoes']?.toString(),
      dataConclusao:
          map['dataConclusao'] != null
              ? DateTime.parse(map['dataConclusao'] as String)
              : null,
    );
  }

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()..addAll({
      'plantaId': plantaId,
      'tipoCuidado': tipoCuidado,
      'dataExecucao': dataExecucao.toIso8601String(),
      'concluida': concluida,
      'observacoes': observacoes,
      'dataConclusao': dataConclusao?.toIso8601String(),
    });
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'planta_id': plantaId,
      'tipo_cuidado': tipoCuidado,
      'data_execucao': dataExecucao.toIso8601String(),
      'concluida': concluida,
      'observacoes': observacoes,
      'data_conclusao': dataConclusao?.toIso8601String(),
    };
  }

  /// Create from Firebase map
  factory TarefaModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return TarefaModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantaId: map['planta_id']?.toString() ?? '',
      tipoCuidado: map['tipo_cuidado']?.toString() ?? '',
      dataExecucao: DateTime.parse(map['data_execucao'] as String),
      concluida: (map['concluida'] as bool?) ?? false,
      observacoes: map['observacoes']?.toString(),
      dataConclusao:
          map['data_conclusao'] != null
              ? DateTime.parse(map['data_conclusao'] as String)
              : null,
    );
  }

  /// copyWith method for immutability
  @override
  TarefaModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? plantaId,
    String? tipoCuidado,
    DateTime? dataExecucao,
    bool? concluida,
    String? observacoes,
    DateTime? dataConclusao,
  }) {
    return TarefaModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      plantaId: plantaId ?? this.plantaId,
      tipoCuidado: tipoCuidado ?? this.tipoCuidado,
      dataExecucao: dataExecucao ?? this.dataExecucao,
      concluida: concluida ?? this.concluida,
      observacoes: observacoes ?? this.observacoes,
      dataConclusao: dataConclusao ?? this.dataConclusao,
    );
  }

  // Legacy compatibility methods
  Map<String, dynamic> toMap() => toHiveMap();
  @override
  Map<String, dynamic> toJson() => toHiveMap();
  factory TarefaModel.fromMap(Map<String, dynamic> map) =>
      TarefaModel.fromHiveMap(map);
  factory TarefaModel.fromJson(Map<String, dynamic> json) =>
      TarefaModel.fromHiveMap(json);

  /// Marca a tarefa como concluída
  TarefaModel marcarConcluida({String? observacoes}) {
    return copyWith(
      concluida: true,
      dataConclusao: DateTime.now(),
      observacoes: observacoes ?? observacoes,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca a tarefa como pendente
  TarefaModel marcarPendente() {
    return copyWith(
      concluida: false,
      dataConclusao: null,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica se a tarefa está atrasada
  bool get isAtrasada {
    if (concluida) return false;
    final hoje = DateTime.now();
    final dataExecucaoDate = DateTime(
      dataExecucao.year,
      dataExecucao.month,
      dataExecucao.day,
    );
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isBefore(hojeDate);
  }

  /// Verifica se a tarefa é para hoje
  bool get isParaHoje {
    final hoje = DateTime.now();
    final dataExecucaoDate = DateTime(
      dataExecucao.year,
      dataExecucao.month,
      dataExecucao.day,
    );
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isAtSameMomentAs(hojeDate);
  }

  /// Verifica se a tarefa é para o futuro
  bool get isParaFuturo {
    final hoje = DateTime.now();
    final dataExecucaoDate = DateTime(
      dataExecucao.year,
      dataExecucao.month,
      dataExecucao.day,
    );
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isAfter(hojeDate);
  }

  /// Calcula quantos dias está atrasada (retorna 0 se não estiver atrasada)
  int get diasAtrasada {
    if (!isAtrasada) return 0;
    final hoje = DateTime.now();
    final dataExecucaoDate = DateTime(
      dataExecucao.year,
      dataExecucao.month,
      dataExecucao.day,
    );
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return hojeDate.difference(dataExecucaoDate).inDays;
  }

  /// Retorna o status em texto
  String get statusTexto {
    if (concluida) return 'Concluída';
    if (isAtrasada) return 'Atrasada';
    if (isParaHoje) return 'Para hoje';
    return 'Agendada';
  }

  /// Retorna o nome amigável do tipo de cuidado
  String get tipoCuidadoNome {
    switch (tipoCuidado) {
      case 'agua':
        return 'Regar';
      case 'adubo':
        return 'Adubar';
      case 'banho_sol':
        return 'Banho de sol';
      case 'inspecao_pragas':
        return 'Inspeção de pragas';
      case 'poda':
        return 'Podar';
      case 'replantar':
        return 'Replantar';
      default:
        return tipoCuidado;
    }
  }

  /// Lista de tipos de cuidado válidos
  static const List<String> tiposCuidadoValidos = [
    'agua',
    'adubo',
    'banho_sol',
    'inspecao_pragas',
    'poda',
    'replantar',
  ];

  /// Verifica se o tipo de cuidado é válido
  bool get tipoValido => tiposCuidadoValidos.contains(tipoCuidado);

  /// Verifica se a tarefa está pendente (não concluída)
  bool get pendente => !concluida;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TarefaModel &&
        other.id == id &&
        other.plantaId == plantaId &&
        other.tipoCuidado == tipoCuidado &&
        other.dataExecucao == dataExecucao &&
        other.concluida == concluida &&
        other.observacoes == observacoes &&
        other.dataConclusao == dataConclusao;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      plantaId,
      tipoCuidado,
      dataExecucao,
      concluida,
      observacoes,
      dataConclusao,
    );
  }

  @override
  String toString() {
    return 'TarefaModel(id: $id, plantaId: $plantaId, tipoCuidado: $tipoCuidado, dataExecucao: $dataExecucao, concluida: $concluida)';
  }
}
