import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Configuração de criptografia para uma box
class BoxEncryptionConfig extends Equatable {
  /// Chave de criptografia (deve ter 32 bytes para AES-256)
  final List<int> key;

  /// Algoritmo de criptografia usado
  final String algorithm;

  const BoxEncryptionConfig({required this.key, this.algorithm = 'AES-256'});

  @override
  List<Object?> get props => [key, algorithm];
}

/// Configuração para uma box do Hive
/// Value object que define as propriedades de uma box
/// incluindo metadados de proprietário para isolamento entre apps
class BoxConfiguration extends Equatable {
  /// Nome da box (deve ser único no sistema)
  final String name;

  /// Identificador do app proprietário desta box
  /// Usado para isolamento e controle de acesso
  final String appId;

  /// Adapters customizados para tipos específicos desta box
  /// Registrados automaticamente quando a box é aberta
  final List<TypeAdapter>? customAdapters;

  /// Se a box deve ser persistente ou apenas em memória
  /// Por padrão, todas as boxes são persistentes
  final bool persistent;

  /// Configuração de criptografia (opcional)
  /// Se fornecida, a box será criptografada
  final BoxEncryptionConfig? encryption;

  /// Pasta customizada para armazenar a box
  /// Se não fornecida, usa a pasta padrão do Hive
  final String? customPath;

  /// Se deve fazer lazy loading dos dados
  /// Melhora performance para boxes grandes
  final bool lazy;

  /// Versão da estrutura de dados desta box
  /// Usado para migração de dados quando necessário
  final int version;

  /// Metadados adicionais da box
  /// Podem ser usados para informações específicas do app
  final Map<String, dynamic>? metadata;

  const BoxConfiguration({
    required this.name,
    required this.appId,
    this.customAdapters,
    this.persistent = true,
    this.encryption,
    this.customPath,
    this.lazy = false,
    this.version = 1,
    this.metadata,
  });

  /// Factory para criar configuração básica
  /// Para uso comum sem configurações avançadas
  factory BoxConfiguration.basic({
    required String name,
    required String appId,
  }) {
    return BoxConfiguration(name: name, appId: appId);
  }

  /// Factory para criar configuração com criptografia
  factory BoxConfiguration.encrypted({
    required String name,
    required String appId,
    required List<int> encryptionKey,
  }) {
    return BoxConfiguration(
      name: name,
      appId: appId,
      encryption: BoxEncryptionConfig(key: encryptionKey),
    );
  }

  /// Factory para criar configuração em memória (não persistente)
  factory BoxConfiguration.inMemory({
    required String name,
    required String appId,
  }) {
    return BoxConfiguration(name: name, appId: appId, persistent: false);
  }

  /// Cria uma cópia da configuração com modificações
  BoxConfiguration copyWith({
    String? name,
    String? appId,
    List<TypeAdapter>? customAdapters,
    bool? persistent,
    BoxEncryptionConfig? encryption,
    String? customPath,
    bool? lazy,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return BoxConfiguration(
      name: name ?? this.name,
      appId: appId ?? this.appId,
      customAdapters: customAdapters ?? this.customAdapters,
      persistent: persistent ?? this.persistent,
      encryption: encryption ?? this.encryption,
      customPath: customPath ?? this.customPath,
      lazy: lazy ?? this.lazy,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converte para Map para serialização/debug
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'appId': appId,
      'persistent': persistent,
      'lazy': lazy,
      'version': version,
      'hasCustomAdapters': customAdapters?.isNotEmpty ?? false,
      'hasEncryption': encryption != null,
      'hasCustomPath': customPath != null,
      'metadata': metadata,
    };
  }

  /// Cria instância a partir de Map
  factory BoxConfiguration.fromMap(Map<String, dynamic> map) {
    return BoxConfiguration(
      name: map['name'] as String,
      appId: map['appId'] as String,
      persistent: map['persistent'] as bool? ?? true,
      lazy: map['lazy'] as bool? ?? false,
      version: map['version'] as int? ?? 1,
      metadata: map['metadata'] as Map<String, dynamic>?,
      // Note: customAdapters e encryption não podem ser recriados a partir do Map
      // pois contêm objetos complexos. Estes campos devem ser definidos durante
      // a criação da configuração, não durante desserialização
    );
  }

  @override
  List<Object?> get props => [
    name,
    appId,
    customAdapters,
    persistent,
    encryption,
    customPath,
    lazy,
    version,
    metadata,
  ];

  @override
  String toString() {
    return 'BoxConfiguration('
        'name: $name, '
        'appId: $appId, '
        'persistent: $persistent, '
        'encrypted: ${encryption != null}, '
        'version: $version'
        ')';
  }
}
