import 'package:core/core.dart' hide Column;

/// Entidade de sincronização para favoritos
/// Extends BaseSyncEntity do core package para compatibilidade
class FavoritoSyncEntity extends BaseSyncEntity {
  final String tipo;
  final String itemId;
  final Map<String, dynamic> itemData;
  final DateTime adicionadoEm;

  const FavoritoSyncEntity({
    required super.id,
    required this.tipo,
    required this.itemId,
    required this.itemData,
    required this.adicionadoEm,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
  });

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'tipo': tipo,
      'itemId': itemId,
      'itemData': itemData,
      'adicionadoEm': adicionadoEm.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'itemId': itemId,
      'itemData': itemData,
      'adicionadoEm': adicionadoEm.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
    };
  }

  static FavoritoSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return FavoritoSyncEntity(
      id: baseFields['id'] as String,
      tipo: map['tipo'] as String,
      itemId: map['itemId'] as String,
      itemData: Map<String, dynamic>.from(map['itemData'] as Map),
      adicionadoEm: _parseDateTime(map['adicionadoEm']) ?? DateTime.now(),
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  factory FavoritoSyncEntity.fromMap(Map<String, dynamic> map) {
    return FavoritoSyncEntity(
      id: map['id'] as String,
      tipo: map['tipo'] as String,
      itemId: map['itemId'] as String,
      itemData: Map<String, dynamic>.from(map['itemData'] as Map),
      adicionadoEm: _parseDateTime(map['adicionadoEm']) ?? DateTime.now(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      lastSyncAt: _parseDateTime(map['lastSyncAt']),
      isDirty: map['isDirty'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String?,
    );
  }

  /// Helper para converter Timestamp ou String para DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Handle Firestore Timestamp
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  FavoritoSyncEntity copyWith({
    String? id,
    String? tipo,
    String? itemId,
    Map<String, dynamic>? itemData,
    DateTime? adicionadoEm,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return FavoritoSyncEntity(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      itemId: itemId ?? this.itemId,
      itemData: itemData ?? this.itemData,
      adicionadoEm: adicionadoEm ?? this.adicionadoEm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  FavoritoSyncEntity markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  FavoritoSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  FavoritoSyncEntity markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  FavoritoSyncEntity incrementVersion() {
    return copyWith(version: version + 1, updatedAt: DateTime.now());
  }

  @override
  FavoritoSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  FavoritoSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  @override
  List<Object?> get props => [
    ...super.props,
    tipo,
    itemId,
    itemData,
    adicionadoEm,
  ];
}
