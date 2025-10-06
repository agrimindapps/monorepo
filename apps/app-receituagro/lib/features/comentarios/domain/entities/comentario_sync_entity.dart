import 'package:core/core.dart';

/// Entidade de sincronização para comentários
/// Extends BaseSyncEntity do core package para compatibilidade
class ComentarioSyncEntity extends BaseSyncEntity {
  final String idReg;
  final String titulo;
  final String conteudo;
  final String ferramenta;
  final String pkIdentificador;
  final bool status;

  const ComentarioSyncEntity({
    required super.id,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
    required this.status,
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
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
      'status': status,
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

  static ComentarioSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return ComentarioSyncEntity(
      id: baseFields['id'] as String,
      idReg: map['idReg'] as String,
      titulo: map['titulo'] as String,
      conteudo: map['conteudo'] as String,
      ferramenta: map['ferramenta'] as String,
      pkIdentificador: map['pkIdentificador'] as String,
      status: map['status'] as bool,
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

  factory ComentarioSyncEntity.fromMap(Map<String, dynamic> map) {
    return ComentarioSyncEntity(
      id: map['id'] as String,
      idReg: map['idReg'] as String,
      titulo: map['titulo'] as String,
      conteudo: map['conteudo'] as String,
      ferramenta: map['ferramenta'] as String,
      pkIdentificador: map['pkIdentificador'] as String,
      status: map['status'] as bool,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      lastSyncAt: map['lastSyncAt'] != null ? DateTime.parse(map['lastSyncAt'] as String) : null,
      isDirty: map['isDirty'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String?,
    );
  }

  @override
  ComentarioSyncEntity copyWith({
    String? id,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return ComentarioSyncEntity(
      id: id ?? this.id,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
      status: status ?? this.status,
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
  ComentarioSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ComentarioSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  ComentarioSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ComentarioSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ComentarioSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  ComentarioSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  @override
  List<Object?> get props => [
        ...super.props,
        idReg,
        titulo,
        conteudo,
        ferramenta,
        pkIdentificador,
        status,
      ];
}
