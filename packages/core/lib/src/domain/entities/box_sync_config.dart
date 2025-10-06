/// Configuração de sincronização para boxes do Hive
class BoxSyncConfig {
  const BoxSyncConfig({
    required this.boxName,
    required this.shouldSync,
    this.syncStrategy = BoxSyncStrategy.automatic,
    this.localOnly = false,
    this.description,
  });

  /// Nome da box
  final String boxName;

  /// Se a box deve sincronizar com Firebase
  final bool shouldSync;

  /// Estratégia de sincronização
  final BoxSyncStrategy syncStrategy;

  /// Se é somente local (nunca sincroniza)
  final bool localOnly;

  /// Descrição da finalidade da box
  final String? description;

  /// Box configurada como somente local
  factory BoxSyncConfig.localOnly({
    required String boxName,
    String? description,
  }) {
    return BoxSyncConfig(
      boxName: boxName,
      shouldSync: false,
      localOnly: true,
      description: description,
    );
  }

  /// Box configurada para sincronização automática
  factory BoxSyncConfig.syncable({
    required String boxName,
    BoxSyncStrategy strategy = BoxSyncStrategy.automatic,
    String? description,
  }) {
    return BoxSyncConfig(
      boxName: boxName,
      shouldSync: true,
      syncStrategy: strategy,
      description: description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxSyncConfig &&
          runtimeType == other.runtimeType &&
          boxName == other.boxName;

  @override
  int get hashCode => boxName.hashCode;

  @override
  String toString() {
    return 'BoxSyncConfig{boxName: $boxName, shouldSync: $shouldSync, localOnly: $localOnly}';
  }
}

/// Estratégias de sincronização
enum BoxSyncStrategy {
  /// Sincronização automática em tempo real
  automatic,
  
  /// Sincronização manual/sob demanda
  manual,
  
  /// Sincronização periódica (agendada)
  periodic,
  
  /// Sincronização apenas quando online
  onlineOnly,
}

/// Configurações pré-definidas para boxes comuns
class DefaultBoxConfigs {
  /// Boxes que NUNCA devem sincronizar (conteúdo estático do app)
  static final List<BoxSyncConfig> staticContentBoxes = [
    BoxSyncConfig.localOnly(
      boxName: 'static_pragas',
      description: 'Dados estáticos de pragas incluídos na versão do app',
    ),
    BoxSyncConfig.localOnly(
      boxName: 'static_defensivos',
      description: 'Dados estáticos de defensivos incluídos na versão do app',
    ),
    BoxSyncConfig.localOnly(
      boxName: 'static_diagnosticos',
      description: 'Dados estáticos de diagnósticos incluídos na versão do app',
    ),
    BoxSyncConfig.localOnly(
      boxName: 'static_culturas',
      description: 'Dados estáticos de culturas incluídos na versão do app',
    ),
    BoxSyncConfig.localOnly(
      boxName: 'app_content',
      description: 'Conteúdo estático versionado do aplicativo',
    ),
  ];

  /// Boxes que devem sincronizar (dados do usuário)
  static final List<BoxSyncConfig> userDataBoxes = [
    BoxSyncConfig.syncable(
      boxName: 'user_favorites',
      description: 'Favoritos do usuário',
    ),
    BoxSyncConfig.syncable(
      boxName: 'user_comments',
      description: 'Comentários do usuário',
    ),
    BoxSyncConfig.syncable(
      boxName: 'user_settings',
      strategy: BoxSyncStrategy.periodic,
      description: 'Configurações personalizadas do usuário',
    ),
    BoxSyncConfig.syncable(
      boxName: 'user_history',
      description: 'Histórico de ações do usuário',
    ),
  ];

  /// Boxes de cache (sincronização condicional)
  static final List<BoxSyncConfig> cacheBoxes = [
    BoxSyncConfig.syncable(
      boxName: 'cache',
      strategy: BoxSyncStrategy.onlineOnly,
      description: 'Cache temporário de dados',
    ),
    BoxSyncConfig.localOnly(
      boxName: 'temp_cache',
      description: 'Cache temporário local',
    ),
  ];

  /// Todas as configurações padrão
  static List<BoxSyncConfig> get all => [
        ...staticContentBoxes,
        ...userDataBoxes,
        ...cacheBoxes,
      ];
}
