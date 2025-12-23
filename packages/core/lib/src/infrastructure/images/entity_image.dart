import 'dart:typed_data';

/// Entidade que representa uma imagem armazenada no sistema
///
/// Usada para armazenar imagens de qualquer entidade do monorepo
/// (plantas, veículos, pets, recibos, etc.)
class EntityImage {
  /// ID único local (auto-increment do Drift)
  final int? id;

  /// ID do Firebase para sincronização
  final String? firebaseId;

  /// ID do usuário proprietário
  final String? userId;

  /// Nome do módulo/app ('plantis', 'gasometer', 'petiveti', etc.)
  final String moduleName;

  /// Tipo da entidade dona da imagem ('plant', 'vehicle', 'pet', 'receipt')
  final String entityType;

  /// ID da entidade dona (Firebase ID)
  final String entityId;

  /// Imagem em Base64 com prefixo data URI
  final String imageBase64;

  /// MIME type da imagem
  final String mimeType;

  /// Tamanho em bytes
  final int sizeBytes;

  /// Largura em pixels
  final int? width;

  /// Altura em pixels
  final int? height;

  /// Nome original do arquivo
  final String? fileName;

  /// Se é a imagem principal da entidade
  final bool isPrimary;

  /// Ordem de exibição
  final int sortOrder;

  /// Data de criação
  final DateTime createdAt;

  /// Data de atualização
  final DateTime updatedAt;

  /// Data da última sincronização
  final DateTime? lastSyncAt;

  /// Se foi modificado localmente e precisa sync
  final bool isDirty;

  /// Se foi deletado (soft delete)
  final bool isDeleted;

  /// Versão para controle de conflitos
  final int version;

  const EntityImage({
    this.id,
    this.firebaseId,
    this.userId,
    required this.moduleName,
    required this.entityType,
    required this.entityId,
    required this.imageBase64,
    this.mimeType = 'image/jpeg',
    required this.sizeBytes,
    this.width,
    this.height,
    this.fileName,
    this.isPrimary = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    this.isDirty = true,
    this.isDeleted = false,
    this.version = 1,
  });

  /// Cria uma nova instância com campos atualizados
  EntityImage copyWith({
    int? id,
    String? firebaseId,
    String? userId,
    String? moduleName,
    String? entityType,
    String? entityId,
    String? imageBase64,
    String? mimeType,
    int? sizeBytes,
    int? width,
    int? height,
    String? fileName,
    bool? isPrimary,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
  }) {
    return EntityImage(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      imageBase64: imageBase64 ?? this.imageBase64,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      fileName: fileName ?? this.fileName,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (firebaseId != null) 'firebaseId': firebaseId,
      if (userId != null) 'userId': userId,
      'moduleName': moduleName,
      'entityType': entityType,
      'entityId': entityId,
      'imageBase64': imageBase64,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (fileName != null) 'fileName': fileName,
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
      'version': version,
    };
  }

  /// Cria instância a partir de Map
  factory EntityImage.fromMap(Map<String, dynamic> map) {
    return EntityImage(
      id: map['id'] as int?,
      firebaseId: map['firebaseId'] as String?,
      userId: map['userId'] as String?,
      moduleName: map['moduleName'] as String,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      imageBase64: map['imageBase64'] as String,
      mimeType: map['mimeType'] as String? ?? 'image/jpeg',
      sizeBytes: map['sizeBytes'] as int,
      width: map['width'] as int?,
      height: map['height'] as int?,
      fileName: map['fileName'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.parse(map['updatedAt'] as String),
      lastSyncAt: map['lastSyncAt'] != null
          ? (map['lastSyncAt'] is DateTime
              ? map['lastSyncAt'] as DateTime
              : DateTime.parse(map['lastSyncAt'] as String))
          : null,
      isDirty: map['isDirty'] as bool? ?? true,
      isDeleted: map['isDeleted'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
    );
  }

  /// Converte para Map otimizado para Firestore (sem campos locais)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'moduleName': moduleName,
      'entityType': entityType,
      'entityId': entityId,
      'imageBase64': imageBase64,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (fileName != null) 'fileName': fileName,
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'version': version,
    };
  }

  @override
  String toString() {
    return 'EntityImage(id: $id, entityType: $entityType, entityId: $entityId, '
        'isPrimary: $isPrimary, sizeBytes: $sizeBytes, isDirty: $isDirty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityImage &&
        other.id == id &&
        other.firebaseId == firebaseId &&
        other.entityId == entityId;
  }

  @override
  int get hashCode => Object.hash(id, firebaseId, entityId);
}

/// Tipos de entidade suportados para imagens
enum EntityImageType {
  plant('plant'),
  vehicle('vehicle'),
  pet('pet'),
  receipt('receipt'),
  expense('expense'),
  profile('profile'),
  space('space'),
  task('task');

  const EntityImageType(this.value);
  final String value;

  static EntityImageType fromString(String value) {
    return EntityImageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EntityImageType.plant,
    );
  }
}

/// Status de upload da imagem
enum ImageUploadStatus {
  pending('pending'),
  uploading('uploading'),
  completed('completed'),
  failed('failed');

  const ImageUploadStatus(this.value);
  final String value;

  static ImageUploadStatus fromString(String value) {
    return ImageUploadStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ImageUploadStatus.pending,
    );
  }
}
