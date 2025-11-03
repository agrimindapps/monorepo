import 'package:hive/hive.dart';

part 'pending_image_upload.g.dart';

/// Modelo para armazenar uploads de imagens pendentes
/// Usado quando o usuário adiciona uma imagem offline
/// TypeId: 50 - Gasometer range para evitar conflitos
@HiveType(typeId: 50)
class PendingImageUpload {
  /// ID único do upload pendente
  @HiveField(0)
  final String id;

  /// Caminho local da imagem a ser enviada
  @HiveField(1)
  final String localPath;

  /// ID do usuário que criou a imagem
  @HiveField(2)
  final String userId;

  /// ID do registro ao qual a imagem pertence
  @HiveField(3)
  final String recordId;

  /// Categoria do registro (fuel, maintenance, expenses)
  @HiveField(4)
  final String category;

  /// Caminho da coleção no Firestore para atualizar após upload
  /// Ex: 'fuel_supplies', 'maintenance_records', 'expenses'
  @HiveField(5)
  final String collectionPath;

  /// Quando o upload foi adicionado à fila
  @HiveField(6)
  final int createdAtMs;

  /// Número de tentativas de upload já realizadas
  @HiveField(7)
  int retryCount;

  /// Última mensagem de erro (se houver)
  @HiveField(8)
  String? lastError;

  /// Timestamp da última tentativa
  @HiveField(9)
  int? lastAttemptMs;

  PendingImageUpload({
    required this.id,
    required this.localPath,
    required this.userId,
    required this.recordId,
    required this.category,
    required this.collectionPath,
    required this.createdAtMs,
    this.retryCount = 0,
    this.lastError,
    this.lastAttemptMs,
  });

  /// Factory para criar novo upload pendente
  factory PendingImageUpload.create({
    required String id,
    required String localPath,
    required String userId,
    required String recordId,
    required String category,
    required String collectionPath,
  }) {
    return PendingImageUpload(
      id: id,
      localPath: localPath,
      userId: userId,
      recordId: recordId,
      category: category,
      collectionPath: collectionPath,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      retryCount: 0,
    );
  }

  /// Incrementa contador de retry e atualiza erro
  PendingImageUpload withRetry(String error) {
    return PendingImageUpload(
      id: id,
      localPath: localPath,
      userId: userId,
      recordId: recordId,
      category: category,
      collectionPath: collectionPath,
      createdAtMs: createdAtMs,
      retryCount: retryCount + 1,
      lastError: error,
      lastAttemptMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Helpers para datas
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);
  DateTime? get lastAttempt => lastAttemptMs != null
      ? DateTime.fromMillisecondsSinceEpoch(lastAttemptMs!)
      : null;

  /// Verifica se atingiu o máximo de tentativas
  bool get hasMaxedRetries => retryCount >= 3;

  /// Verifica se deve aguardar antes de tentar novamente (backoff)
  bool get shouldWaitBeforeRetry {
    if (lastAttemptMs == null) return false;

    // Backoff exponencial: 1min, 5min, 15min
    final waitMinutes = [1, 5, 15][retryCount.clamp(0, 2)];
    final waitDuration = Duration(minutes: waitMinutes);
    final elapsed = DateTime.now().difference(lastAttempt!);

    return elapsed < waitDuration;
  }

  @override
  String toString() {
    return 'PendingImageUpload(id: $id, recordId: $recordId, category: $category, retryCount: $retryCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PendingImageUpload && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
