import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../shared/utils/failure.dart';

/// Interface para serviços de armazenamento criptografado
/// Define contratos para operações seguras com dados sensíveis
abstract class IEncryptedStorageRepository {
  /// Inicializa o serviço de criptografia
  Future<Either<Failure, void>> initialize();

  /// Obtém uma box criptografada com o nome especificado
  Future<Either<Failure, Box<String>>> getEncryptedBox(String boxName);

  /// Armazena dados criptografados em uma box específica
  Future<Either<Failure, void>> storeEncrypted<T extends Object>(
    String key,
    T data,
    String boxName, {
    Map<String, dynamic> Function(T)? toJson,
  });

  /// Recupera dados criptografados de uma box específica
  Future<Either<Failure, T?>> getEncrypted<T extends Object>(
    String key,
    String boxName, {
    T Function(Map<String, dynamic>)? fromJson,
  });

  /// Remove um item específico de uma box criptografada
  Future<Either<Failure, void>> deleteEncrypted(String key, String boxName);

  /// Limpa todos os dados de uma box específica
  Future<Either<Failure, void>> clearEncryptedBox(String boxName);

  /// Limpa todos os dados criptografados
  Future<Either<Failure, void>> clearAllEncrypted();

  /// Obtém status da criptografia para monitoramento
  Map<String, dynamic> getEncryptionStatus();

  /// Verifica se uma box específica está aberta
  bool isBoxOpen(String boxName);

  /// Lista todas as chaves em uma box específica
  Future<Either<Failure, List<String>>> getKeysFromBox(String boxName);

  /// Obtém o tamanho de uma box específica
  Future<Either<Failure, int>> getBoxSize(String boxName);
}

/// Configurações para armazenamento criptografado
class EncryptedStorageConfig {
  /// Nome da box padrão para dados sensíveis
  final String sensitiveDataBoxName;
  
  /// Nome da box padrão para dados PII
  final String piiDataBoxName;
  
  /// Nome da box padrão para dados de localização
  final String locationDataBoxName;
  
  /// Se deve fazer backup automático das chaves
  final bool enableKeyBackup;
  
  /// Se deve validar a integridade dos dados
  final bool enableIntegrityCheck;

  const EncryptedStorageConfig({
    this.sensitiveDataBoxName = 'sensitive_data_encrypted',
    this.piiDataBoxName = 'pii_data_encrypted',
    this.locationDataBoxName = 'location_data_encrypted',
    this.enableKeyBackup = true,
    this.enableIntegrityCheck = true,
  });
}

/// Tipos de dados sensíveis para categorização
enum SensitiveDataType {
  /// Dados pessoais identificáveis (PII)
  personallyIdentifiable,
  
  /// Dados de localização
  location,
  
  /// Notas e comentários pessoais
  personalNotes,
  
  /// Configurações sensíveis
  sensitiveSettings,
  
  /// Dados financeiros
  financial,
  
  /// Dados de saúde
  health,
  
  /// Outros dados sensíveis
  other,
}

/// Metadados para dados criptografados
class EncryptedDataMetadata {
  /// Tipo de dados sensíveis
  final SensitiveDataType dataType;
  
  /// Timestamp de criação
  final DateTime createdAt;
  
  /// Timestamp da última atualização
  final DateTime? updatedAt;
  
  /// Versão dos dados para migração
  final int version;
  
  /// Tags adicionais para categorização
  final List<String> tags;
  
  /// Se os dados expiram
  final DateTime? expiresAt;

  const EncryptedDataMetadata({
    required this.dataType,
    required this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.tags = const [],
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
    'dataType': dataType.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'version': version,
    'tags': tags,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory EncryptedDataMetadata.fromJson(Map<String, dynamic> json) =>
      EncryptedDataMetadata(
        dataType: SensitiveDataType.values.firstWhere(
          (e) => e.name == json['dataType'],
          orElse: () => SensitiveDataType.other,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        version: json['version'] as int? ?? 1,
        tags: List<String>.from(json['tags'] as List? ?? []),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}

/// Wrapper para dados criptografados com metadados
class EncryptedDataWrapper<T> {
  /// Os dados propriamente ditos
  final T data;
  
  /// Metadados associados
  final EncryptedDataMetadata metadata;

  const EncryptedDataWrapper({
    required this.data,
    required this.metadata,
  });

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) => {
    'data': dataToJson(data),
    'metadata': metadata.toJson(),
  };

  factory EncryptedDataWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) =>
      EncryptedDataWrapper(
        data: dataFromJson(json['data'] as Map<String, dynamic>),
        metadata: EncryptedDataMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>,
        ),
      );
}

/// Interface para estratégias de rotação de chaves
abstract class IEncryptionKeyRotationStrategy {
  /// Verifica se é necessário rotacionar a chave
  bool shouldRotateKey(DateTime lastRotation);
  
  /// Gera uma nova chave de criptografia
  Future<Either<Failure, List<int>>> generateNewKey();
  
  /// Migra dados para nova chave
  Future<Either<Failure, void>> migrateDataToNewKey(
    String boxName,
    List<int> oldKey,
    List<int> newKey,
  );
}

/// Interface para validação de integridade
abstract class IDataIntegrityValidator {
  /// Calcula hash de integridade para os dados
  String calculateIntegrityHash<T>(T data);
  
  /// Valida a integridade dos dados
  bool validateIntegrity<T>(T data, String expectedHash);
  
  /// Gera checksum para uma box inteira
  Future<Either<Failure, String>> generateBoxChecksum(String boxName);
}
