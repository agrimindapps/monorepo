import 'package:core/core.dart';

import 'base_sync_model.dart';

/// Category model with Firebase sync support
class CategoryModel extends BaseSyncModel {
  CategoryModel({
    required this.id,
    this.createdAtMs,
    this.updatedAtMs,
    this.lastSyncAtMs,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName = 'gasometer',
    this.categoria = 0,
    this.descricao = '',
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

  /// Factory constructor for creating new category
  factory CategoryModel.create({
    String? id,
    String? userId,
    required int categoria,
    required String descricao,
  }) {
    final now = DateTime.now();
    final categoryId = id ?? now.millisecondsSinceEpoch.toString();

    return CategoryModel(
      id: categoryId,
      createdAtMs: now.millisecondsSinceEpoch,
      updatedAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      userId: userId,
      categoria: categoria,
      descricao: descricao,
    );
  }

  /// Create from map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: map['isDirty'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String?,
      categoria: (map['categoria'] as num?)?.toInt() ?? 0,
      descricao: map['descricao']?.toString() ?? '',
    );
  }

  /// Create from Firebase map
  factory CategoryModel.fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseFirebaseFields(map);
    final timestamps = BaseSyncModel.parseFirebaseTimestamps(map);

    return CategoryModel(
      id: baseFields['id'] as String,
      createdAtMs: timestamps['createdAt']?.millisecondsSinceEpoch,
      updatedAtMs: timestamps['updatedAt']?.millisecondsSinceEpoch,
      lastSyncAtMs: timestamps['lastSyncAt']?.millisecondsSinceEpoch,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      categoria: (map['categoria'] as num?)?.toInt() ?? 0,
      descricao: map['descricao']?.toString() ?? '',
    );
  }
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel.fromMap(json);

  @override
  final String id;
  final int? createdAtMs;
  final int? updatedAtMs;
  final int? lastSyncAtMs;
  @override
  final bool isDirty;
  @override
  final bool isDeleted;
  @override
  final int version;
  @override
  final String? userId;
  @override
  final String? moduleName;
  final int categoria;
  final String descricao;

  @override
  String get collectionName => 'categories';

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAtMs,
      'updatedAt': updatedAtMs,
      'lastSyncAt': lastSyncAtMs,
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
      'userId': userId,
      'moduleName': moduleName,
      'categoria': categoria,
      'descricao': descricao,
    };
  }

  /// Convert to Firebase map
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      ...firebaseTimestampFields,
      'categoria': categoria,
      'descricao': descricao,
    };
  }

  /// copyWith method for immutability
  @override
  CategoryModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    int? categoria,
    String? descricao,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      createdAtMs: createdAt?.millisecondsSinceEpoch ?? createdAtMs,
      updatedAtMs: updatedAt?.millisecondsSinceEpoch ?? updatedAtMs,
      lastSyncAtMs: lastSyncAt?.millisecondsSinceEpoch ?? lastSyncAtMs,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel(id: $id, categoria: $categoria, descricao: $descricao)';
  }
}
