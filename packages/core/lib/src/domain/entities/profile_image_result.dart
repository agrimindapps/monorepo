class ProfileImageResult {
  final String downloadUrl;
  final String fileName;
  final String userId;
  final DateTime uploadedAt;
  final int fileSizeInBytes;
  final String contentType;

  const ProfileImageResult({
    required this.downloadUrl,
    required this.fileName,
    required this.userId,
    required this.uploadedAt,
    required this.fileSizeInBytes,
    required this.contentType,
  });

  /// Factory para criar resultado de upload bem-sucedido
  factory ProfileImageResult.fromUploadResult({
    required String downloadUrl,
    required String fileName,
    required String userId,
    required int fileSizeInBytes,
    required String contentType,
  }) {
    return ProfileImageResult(
      downloadUrl: downloadUrl,
      fileName: fileName,
      userId: userId,
      uploadedAt: DateTime.now(),
      fileSizeInBytes: fileSizeInBytes,
      contentType: contentType,
    );
  }

  /// Converter para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'downloadUrl': downloadUrl,
      'fileName': fileName,
      'userId': userId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'fileSizeInBytes': fileSizeInBytes,
      'contentType': contentType,
    };
  }

  /// Factory para criar a partir de Map
  factory ProfileImageResult.fromMap(Map<String, dynamic> map) {
    return ProfileImageResult(
      downloadUrl: map['downloadUrl'] as String,
      fileName: map['fileName'] as String,
      userId: map['userId'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      fileSizeInBytes: map['fileSizeInBytes'] as int,
      contentType: map['contentType'] as String,
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() => toMap();

  /// Factory para criar a partir de JSON
  factory ProfileImageResult.fromJson(Map<String, dynamic> json) =>
      ProfileImageResult.fromMap(json);

  /// CopyWith method
  ProfileImageResult copyWith({
    String? downloadUrl,
    String? fileName,
    String? userId,
    DateTime? uploadedAt,
    int? fileSizeInBytes,
    String? contentType,
  }) {
    return ProfileImageResult(
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileName: fileName ?? this.fileName,
      userId: userId ?? this.userId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      fileSizeInBytes: fileSizeInBytes ?? this.fileSizeInBytes,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileImageResult &&
          runtimeType == other.runtimeType &&
          downloadUrl == other.downloadUrl &&
          fileName == other.fileName &&
          userId == other.userId;

  @override
  int get hashCode =>
      downloadUrl.hashCode ^ fileName.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'ProfileImageResult('
        'downloadUrl: $downloadUrl, '
        'fileName: $fileName, '
        'userId: $userId, '
        'uploadedAt: $uploadedAt, '
        'fileSizeInBytes: $fileSizeInBytes, '
        'contentType: $contentType'
        ')';
  }
}

/// Configuração para upload de imagem de perfil
class ProfileImageConfig {
  final int maxWidth;
  final int maxHeight;
  final int imageQuality;
  final int maxFileSizeInMB;
  final List<String> allowedFormats;
  final String storagePath;

  const ProfileImageConfig({
    this.maxWidth = 512,
    this.maxHeight = 512,
    this.imageQuality = 85,
    this.maxFileSizeInMB = 5,
    this.allowedFormats = const ['.jpg', '.jpeg', '.png'],
    this.storagePath = 'users/{userId}/profile',
  });

  /// Configuração padrão para avatares
  static const ProfileImageConfig defaultAvatar = ProfileImageConfig(
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 85,
    maxFileSizeInMB: 5,
    allowedFormats: ['.jpg', '.jpeg', '.png'],
    storagePath: 'users/{userId}/profile',
  );

  /// Configuração de alta qualidade
  static const ProfileImageConfig highQuality = ProfileImageConfig(
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 95,
    maxFileSizeInMB: 10,
    allowedFormats: ['.jpg', '.jpeg', '.png'],
    storagePath: 'users/{userId}/profile',
  );

  /// Configuração otimizada para mobile
  static const ProfileImageConfig optimized = ProfileImageConfig(
    maxWidth: 256,
    maxHeight: 256,
    imageQuality: 75,
    maxFileSizeInMB: 2,
    allowedFormats: ['.jpg', '.jpeg', '.png'],
    storagePath: 'users/{userId}/profile',
  );

  /// Obter path de storage personalizado para um usuário
  String getStoragePathForUser(String userId) {
    return storagePath.replaceAll('{userId}', userId);
  }

  ProfileImageConfig copyWith({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? maxFileSizeInMB,
    List<String>? allowedFormats,
    String? storagePath,
  }) {
    return ProfileImageConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      imageQuality: imageQuality ?? this.imageQuality,
      maxFileSizeInMB: maxFileSizeInMB ?? this.maxFileSizeInMB,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      storagePath: storagePath ?? this.storagePath,
    );
  }
}
