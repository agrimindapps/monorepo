import 'package:core/core.dart';

import 'base_sync_model.dart';

part 'category_model.g.dart';

/// Category model with Firebase sync support
/// TypeId: 5 - New sequential numbering
@HiveType(typeId: 5)
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

  /// Create from Hive map
  factory CategoryModel.fromHiveMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncModel.parseBaseHiveFields(map);

    return CategoryModel(
      id: baseFields['id'] as String,
      createdAtMs: map['createdAt'] as int?,
      updatedAtMs: map['updatedAt'] as int?,
      lastSyncAtMs: map['lastSyncAt'] as int?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
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
  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromHiveMap(map);
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel.fromHiveMap(json);
  @override
  void removeFromHive() {
  }
  @HiveField(0)
  @override
  final String id;
  @HiveField(1)
  final int? createdAtMs;
  @HiveField(2)
  final int? updatedAtMs;
  @HiveField(3)
  final int? lastSyncAtMs;
  @HiveField(4)
  @override
  final bool isDirty;
  @HiveField(5)
  @override
  final bool isDeleted;
  @HiveField(6)
  @override
  final int version;
  @HiveField(7)
  @override
  final String? userId;
  @HiveField(8)
  @override
  final String? moduleName;
  @HiveField(10)
  final int categoria;
  @HiveField(11)
  final String descricao;

  @override
  String get collectionName => 'categories';

  /// Convert to Hive map
  @override
  Map<String, dynamic> toHiveMap() {
    return super.toHiveMap()
      ..addAll({'categoria': categoria, 'descricao': descricao});
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
  Map<String, dynamic> toMap() => toHiveMap();
  Map<String, dynamic> toJson() => toHiveMap();

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
