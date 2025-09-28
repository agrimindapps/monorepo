import 'dart:convert';

/// Model que representa um backup completo do usuário
class BackupModel {
  final String? id;
  final String version;
  final DateTime timestamp;
  final String userId;
  final BackupMetadata metadata;
  final BackupData data;

  const BackupModel({
    this.id,
    required this.version,
    required this.timestamp,
    required this.userId,
    required this.metadata,
    required this.data,
  });

  /// Cria backup a partir de JSON
  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      id: json['id'] as String?,
      version: json['version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      metadata: BackupMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      data: BackupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Converte backup para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata.toJson(),
      'data': data.toJson(),
    };
  }

  /// Converte para JSON string comprimida
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Cria backup a partir de string JSON
  factory BackupModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return BackupModel.fromJson(json);
  }

  /// Calcula tamanho estimado do backup em bytes
  int get sizeInBytes {
    return utf8.encode(toJsonString()).length;
  }

  /// Formata tamanho para exibição (KB, MB)
  String get formattedSize {
    final bytes = sizeInBytes;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Nome do arquivo de backup
  String get fileName {
    final dateStr = timestamp.toIso8601String().split('T')[0];
    final timeStr = timestamp
        .toIso8601String()
        .split('T')[1]
        .split('.')[0]
        .replaceAll(':', '-');
    return 'plantis_backup_${dateStr}_$timeStr.json';
  }

  /// Verifica se o backup é compatível com a versão atual
  bool get isCompatible {
    // Por enquanto, apenas versão 1.0 é suportada
    return version == '1.0';
  }

  @override
  String toString() {
    return 'BackupModel(version: $version, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupModel &&
        other.id == id &&
        other.version == version &&
        other.timestamp == timestamp &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, version, timestamp, userId);
  }
}

/// Metadados do backup
class BackupMetadata {
  final int plantsCount;
  final int tasksCount;
  final int spacesCount;
  final int totalItems;
  final String appVersion;
  final String platform;
  final Map<String, dynamic> additionalInfo;

  const BackupMetadata({
    required this.plantsCount,
    required this.tasksCount,
    required this.spacesCount,
    required this.appVersion,
    required this.platform,
    this.additionalInfo = const {},
  }) : totalItems = plantsCount + tasksCount + spacesCount;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      plantsCount: json['plantsCount'] as int,
      tasksCount: json['tasksCount'] as int,
      spacesCount: json['spacesCount'] as int,
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      additionalInfo: Map<String, dynamic>.from(
        (json['additionalInfo'] as Map<dynamic, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantsCount': plantsCount,
      'tasksCount': tasksCount,
      'spacesCount': spacesCount,
      'totalItems': totalItems,
      'appVersion': appVersion,
      'platform': platform,
      'additionalInfo': additionalInfo,
    };
  }

  @override
  String toString() {
    return 'BackupMetadata(plants: $plantsCount, tasks: $tasksCount, spaces: $spacesCount)';
  }
}

/// Dados do backup
class BackupData {
  final List<Map<String, dynamic>> plants;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> spaces;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> userPreferences;

  const BackupData({
    required this.plants,
    required this.tasks,
    required this.spaces,
    required this.settings,
    required this.userPreferences,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      plants: List<Map<String, dynamic>>.from(
        (json['plants'] as Iterable<dynamic>?) ?? [],
      ),
      tasks: List<Map<String, dynamic>>.from(
        (json['tasks'] as Iterable<dynamic>?) ?? [],
      ),
      spaces: List<Map<String, dynamic>>.from(
        (json['spaces'] as Iterable<dynamic>?) ?? [],
      ),
      settings: Map<String, dynamic>.from(
        (json['settings'] as Map<dynamic, dynamic>?) ?? {},
      ),
      userPreferences: Map<String, dynamic>.from(
        (json['userPreferences'] as Map<dynamic, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plants': plants,
      'tasks': tasks,
      'spaces': spaces,
      'settings': settings,
      'userPreferences': userPreferences,
    };
  }

  /// Verifica se o backup contém dados
  bool get hasData {
    return plants.isNotEmpty || tasks.isNotEmpty || spaces.isNotEmpty;
  }
}

/// Informações de um backup disponível na nuvem
class BackupInfo {
  final String id;
  final String fileName;
  final DateTime timestamp;
  final BackupMetadata metadata;
  final String downloadUrl;
  final int sizeInBytes;

  const BackupInfo({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.metadata,
    required this.downloadUrl,
    required this.sizeInBytes,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: BackupMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      downloadUrl: json['downloadUrl'] as String,
      sizeInBytes: json['sizeInBytes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata.toJson(),
      'downloadUrl': downloadUrl,
      'sizeInBytes': sizeInBytes,
    };
  }

  /// Formata tamanho para exibição
  String get formattedSize {
    if (sizeInBytes < 1024) return '${sizeInBytes}B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Data formatada para exibição
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Hoje às ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  String toString() {
    return 'BackupInfo(id: $id, fileName: $fileName, timestamp: $timestamp)';
  }
}

/// Resultado de uma operação de backup
class BackupResult {
  final bool success;
  final String? backupId;
  final String? fileName;
  final int? sizeInBytes;
  final String? errorMessage;
  final DateTime timestamp;

  const BackupResult({
    required this.success,
    this.backupId,
    this.fileName,
    this.sizeInBytes,
    this.errorMessage,
    required this.timestamp,
  });

  factory BackupResult.success({
    required String backupId,
    required String fileName,
    required int sizeInBytes,
  }) {
    return BackupResult(
      success: true,
      backupId: backupId,
      fileName: fileName,
      sizeInBytes: sizeInBytes,
      timestamp: DateTime.now(),
    );
  }

  factory BackupResult.error(String errorMessage) {
    return BackupResult(
      success: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }
}
