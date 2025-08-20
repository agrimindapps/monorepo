enum BackupOperation {
  backup('backup', 'Backup'),
  restore('restore', 'Restaurar'),
  delete('delete', 'Limpar');

  const BackupOperation(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum BackupStatus {
  idle('idle', 'Aguardando'),
  loading('loading', 'Processando'),
  success('success', 'Sucesso'),
  error('error', 'Erro'),
  cancelled('cancelled', 'Cancelado');

  const BackupStatus(this.id, this.displayName);
  final String id;
  final String displayName;
}

class BackupData {
  final DateTime? lastBackupDate;
  final int totalRecords;
  final Map<String, int> recordCounts;
  final String? lastBackupPath;
  final bool hasBackupAvailable;

  const BackupData({
    this.lastBackupDate,
    this.totalRecords = 0,
    this.recordCounts = const {},
    this.lastBackupPath,
    this.hasBackupAvailable = false,
  });

  BackupData copyWith({
    DateTime? lastBackupDate,
    int? totalRecords,
    Map<String, int>? recordCounts,
    String? lastBackupPath,
    bool? hasBackupAvailable,
  }) {
    return BackupData(
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      totalRecords: totalRecords ?? this.totalRecords,
      recordCounts: recordCounts ?? this.recordCounts,
      lastBackupPath: lastBackupPath ?? this.lastBackupPath,
      hasBackupAvailable: hasBackupAvailable ?? this.hasBackupAvailable,
    );
  }

  String get formattedLastBackup {
    if (lastBackupDate == null) return 'Nunca';
    
    final now = DateTime.now();
    final difference = now.difference(lastBackupDate!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  bool get needsBackup {
    if (lastBackupDate == null) return true;
    return DateTime.now().difference(lastBackupDate!).inDays >= 7;
  }

  Map<String, dynamic> toJson() {
    return {
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'totalRecords': totalRecords,
      'recordCounts': recordCounts,
      'lastBackupPath': lastBackupPath,
      'hasBackupAvailable': hasBackupAvailable,
    };
  }

  static BackupData fromJson(Map<String, dynamic> json) {
    return BackupData(
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'])
          : null,
      totalRecords: json['totalRecords'] ?? 0,
      recordCounts: Map<String, int>.from(json['recordCounts'] ?? {}),
      lastBackupPath: json['lastBackupPath'],
      hasBackupAvailable: json['hasBackupAvailable'] ?? false,
    );
  }
}

class BackupOperationResult {
  final BackupOperation operation;
  final BackupStatus status;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const BackupOperationResult({
    required this.operation,
    required this.status,
    this.message,
    required this.timestamp,
    this.data,
  });

  bool get isSuccess => status == BackupStatus.success;
  bool get isError => status == BackupStatus.error;
  bool get isLoading => status == BackupStatus.loading;

  static BackupOperationResult success({
    required BackupOperation operation,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return BackupOperationResult(
      operation: operation,
      status: BackupStatus.success,
      message: message,
      timestamp: DateTime.now(),
      data: data,
    );
  }

  static BackupOperationResult error({
    required BackupOperation operation,
    required String message,
  }) {
    return BackupOperationResult(
      operation: operation,
      status: BackupStatus.error,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  static BackupOperationResult loading({
    required BackupOperation operation,
    String? message,
  }) {
    return BackupOperationResult(
      operation: operation,
      status: BackupStatus.loading,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BackupOperationResult(operation: ${operation.displayName}, status: ${status.displayName}, message: $message)';
  }
}

class DatabaseStats {
  final Map<String, int> tableCounts;
  final int totalRecords;
  final double totalSizeKB;
  final DateTime lastModified;

  const DatabaseStats({
    required this.tableCounts,
    required this.totalRecords,
    required this.totalSizeKB,
    required this.lastModified,
  });

  String get formattedSize {
    if (totalSizeKB < 1024) {
      return '${totalSizeKB.toStringAsFixed(1)} KB';
    } else {
      final sizeInMB = totalSizeKB / 1024;
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  String get formattedLastModified {
    final now = DateTime.now();
    final difference = now.difference(lastModified);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  static DatabaseStats empty() {
    return DatabaseStats(
      tableCounts: const {},
      totalRecords: 0,
      totalSizeKB: 0.0,
      lastModified: DateTime.now(),
    );
  }
}

class BackupRepository {
  static const Map<String, String> _tableDisplayNames = {
    'box_vet_animais': 'Animais',
    'box_vet_pesos': 'Pesos',
    'box_vet_vacinas': 'Vacinas',
    'box_vet_lembrete': 'Lembretes',
    'box_vet_medicamentos': 'Medicamentos',
    'box_vet_despesas': 'Despesas',
  };

  static List<String> get supportedTables => _tableDisplayNames.keys.toList();

  static String getTableDisplayName(String tableName) {
    return _tableDisplayNames[tableName] ?? tableName;
  }

  static Map<String, String> getTableDisplayNames() {
    return Map.from(_tableDisplayNames);
  }

  static String getOperationDisplayName(BackupOperation operation) {
    return operation.displayName;
  }

  static String getStatusDisplayName(BackupStatus status) {
    return status.displayName;
  }

  static String getBackupFileName() {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'petiveti_backup_$timestamp.json';
  }

  static bool isValidBackupFile(String? filePath) {
    if (filePath == null || filePath.isEmpty) return false;
    return filePath.endsWith('.json') && filePath.contains('petiveti_backup');
  }

  static Map<String, dynamic> createBackupMetadata({
    required DateTime timestamp,
    required Map<String, int> recordCounts,
    required String appVersion,
  }) {
    return {
      'metadata': {
        'timestamp': timestamp.toIso8601String(),
        'appVersion': appVersion,
        'totalRecords': recordCounts.values.fold(0, (sum, count) => sum + count),
        'recordCounts': recordCounts,
        'backupVersion': '1.0',
      },
    };
  }

  static bool validateBackupData(Map<String, dynamic> backupData) {
    try {
      final metadata = backupData['metadata'] as Map<String, dynamic>?;
      if (metadata == null) return false;
      
      final timestamp = metadata['timestamp'] as String?;
      final recordCounts = metadata['recordCounts'] as Map<String, dynamic>?;
      
      return timestamp != null && recordCounts != null;
    } catch (e) {
      return false;
    }
  }

  static String formatBackupSummary(BackupData data) {
    if (data.totalRecords == 0) {
      return 'Nenhum dado para backup';
    }
    
    final recordsText = '${data.totalRecords} registro${data.totalRecords > 1 ? 's' : ''}';
    final tablesText = '${data.recordCounts.length} tabela${data.recordCounts.length > 1 ? 's' : ''}';
    
    return '$recordsText em $tablesText';
  }

  static List<String> getBackupWarnings(DatabaseStats stats) {
    final warnings = <String>[];
    
    if (stats.totalRecords == 0) {
      warnings.add('Nenhum dado encontrado para backup');
    }
    
    if (stats.totalSizeKB > 10000) { // 10MB
      warnings.add('Banco de dados muito grande (${stats.formattedSize})');
    }
    
    final oldTables = stats.tableCounts.entries
        .where((entry) => entry.value == 0)
        .map((entry) => getTableDisplayName(entry.key))
        .toList();
    
    if (oldTables.isNotEmpty) {
      warnings.add('Tabelas vazias: ${oldTables.join(', ')}');
    }
    
    return warnings;
  }

  static Duration estimateBackupTime(DatabaseStats stats) {
    // Estimar tempo baseado no número de registros
    const baseTimeMs = 1000; // 1 segundo base
    final recordTimeMs = stats.totalRecords * 10; // 10ms por registro
    final totalMs = baseTimeMs + recordTimeMs;
    
    return Duration(milliseconds: totalMs);
  }
}