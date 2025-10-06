import 'package:core/core.dart';

/// Entidade de sincronização para histórico do usuário
/// Tracks user interactions with agricultural diagnostics
class UserHistorySyncEntity extends BaseSyncEntity {
  final String tipoItem; // 'praga', 'defensivo', 'diagnostico', 'cultura'
  final String itemId;
  final String nomeItem;
  final String acaoTipo; // 'view', 'favorite', 'unfavorite', 'comment', 'search'
  final DateTime dataAcao;
  final Map<String, dynamic> metadados; // Additional context data
  final String? categoria;
  final String? cultura;
  final int? tempoVisualizacaoSegundos;

  const UserHistorySyncEntity({
    required super.id,
    required this.tipoItem,
    required this.itemId,
    required this.nomeItem,
    required this.acaoTipo,
    required this.dataAcao,
    required this.metadados,
    this.categoria,
    this.cultura,
    this.tempoVisualizacaoSegundos,
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
      'tipoItem': tipoItem,
      'itemId': itemId,
      'nomeItem': nomeItem,
      'acaoTipo': acaoTipo,
      'dataAcao': dataAcao.toIso8601String(),
      'metadados': metadados,
      'categoria': categoria,
      'cultura': cultura,
      'tempoVisualizacaoSegundos': tempoVisualizacaoSegundos,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipoItem': tipoItem,
      'itemId': itemId,
      'nomeItem': nomeItem,
      'acaoTipo': acaoTipo,
      'dataAcao': dataAcao.toIso8601String(),
      'metadados': metadados,
      'categoria': categoria,
      'cultura': cultura,
      'tempoVisualizacaoSegundos': tempoVisualizacaoSegundos,
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

  static UserHistorySyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return UserHistorySyncEntity(
      id: baseFields['id'] as String,
      tipoItem: map['tipoItem'] as String,
      itemId: map['itemId'] as String,
      nomeItem: map['nomeItem'] as String,
      acaoTipo: map['acaoTipo'] as String,
      dataAcao: DateTime.parse(map['dataAcao'] as String),
      metadados: Map<String, dynamic>.from(map['metadados'] as Map),
      categoria: map['categoria'] as String?,
      cultura: map['cultura'] as String?,
      tempoVisualizacaoSegundos: map['tempoVisualizacaoSegundos'] as int?,
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

  factory UserHistorySyncEntity.fromMap(Map<String, dynamic> map) {
    return UserHistorySyncEntity(
      id: map['id'] as String,
      tipoItem: map['tipoItem'] as String,
      itemId: map['itemId'] as String,
      nomeItem: map['nomeItem'] as String,
      acaoTipo: map['acaoTipo'] as String,
      dataAcao: DateTime.parse(map['dataAcao'] as String),
      metadados: Map<String, dynamic>.from(map['metadados'] as Map),
      categoria: map['categoria'] as String?,
      cultura: map['cultura'] as String?,
      tempoVisualizacaoSegundos: map['tempoVisualizacaoSegundos'] as int?,
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

  /// Factory para criar entrada de visualização
  factory UserHistorySyncEntity.createViewEntry({
    required String userId,
    required String tipoItem,
    required String itemId,
    required String nomeItem,
    String? categoria,
    String? cultura,
    int? tempoVisualizacaoSegundos,
    Map<String, dynamic>? metadadosAdicionais,
  }) {
    final now = DateTime.now();
    return UserHistorySyncEntity(
      id: 'history_${userId}_${now.millisecondsSinceEpoch}',
      tipoItem: tipoItem,
      itemId: itemId,
      nomeItem: nomeItem,
      acaoTipo: 'view',
      dataAcao: now,
      metadados: {
        'plataforma': 'mobile',
        'versaoApp': '1.0.0',
        ...?metadadosAdicionais,
      },
      categoria: categoria,
      cultura: cultura,
      tempoVisualizacaoSegundos: tempoVisualizacaoSegundos,
      userId: userId,
      moduleName: 'receituagro',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory para criar entrada de favorito
  factory UserHistorySyncEntity.createFavoriteEntry({
    required String userId,
    required String tipoItem,
    required String itemId,
    required String nomeItem,
    required bool isFavoriting, // true = add, false = remove
    String? categoria,
    String? cultura,
    Map<String, dynamic>? metadadosAdicionais,
  }) {
    final now = DateTime.now();
    return UserHistorySyncEntity(
      id: 'history_${userId}_${now.millisecondsSinceEpoch}',
      tipoItem: tipoItem,
      itemId: itemId,
      nomeItem: nomeItem,
      acaoTipo: isFavoriting ? 'favorite' : 'unfavorite',
      dataAcao: now,
      metadados: {
        'plataforma': 'mobile',
        'versaoApp': '1.0.0',
        'isFavoriting': isFavoriting,
        ...?metadadosAdicionais,
      },
      categoria: categoria,
      cultura: cultura,
      userId: userId,
      moduleName: 'receituagro',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Factory para criar entrada de busca
  factory UserHistorySyncEntity.createSearchEntry({
    required String userId,
    required String termoBusca,
    required int resultadosEncontrados,
    required String tipoFiltro,
    Map<String, dynamic>? metadadosAdicionais,
  }) {
    final now = DateTime.now();
    return UserHistorySyncEntity(
      id: 'history_${userId}_${now.millisecondsSinceEpoch}',
      tipoItem: 'search',
      itemId: 'search_${now.millisecondsSinceEpoch}',
      nomeItem: termoBusca,
      acaoTipo: 'search',
      dataAcao: now,
      metadados: {
        'plataforma': 'mobile',
        'versaoApp': '1.0.0',
        'resultadosEncontrados': resultadosEncontrados,
        'tipoFiltro': tipoFiltro,
        'termoBusca': termoBusca,
        ...?metadadosAdicionais,
      },
      userId: userId,
      moduleName: 'receituagro',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  UserHistorySyncEntity copyWith({
    String? id,
    String? tipoItem,
    String? itemId,
    String? nomeItem,
    String? acaoTipo,
    DateTime? dataAcao,
    Map<String, dynamic>? metadados,
    String? categoria,
    String? cultura,
    int? tempoVisualizacaoSegundos,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return UserHistorySyncEntity(
      id: id ?? this.id,
      tipoItem: tipoItem ?? this.tipoItem,
      itemId: itemId ?? this.itemId,
      nomeItem: nomeItem ?? this.nomeItem,
      acaoTipo: acaoTipo ?? this.acaoTipo,
      dataAcao: dataAcao ?? this.dataAcao,
      metadados: metadados ?? this.metadados,
      categoria: categoria ?? this.categoria,
      cultura: cultura ?? this.cultura,
      tempoVisualizacaoSegundos: tempoVisualizacaoSegundos ?? this.tempoVisualizacaoSegundos,
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
  UserHistorySyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserHistorySyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  UserHistorySyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserHistorySyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserHistorySyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  UserHistorySyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Check if this entry is recent (within last hour)
  bool get isRecent => DateTime.now().difference(dataAcao).inHours < 1;

  /// Check if this is a view action
  bool get isViewAction => acaoTipo == 'view';

  /// Check if this is a favorite action
  bool get isFavoriteAction => acaoTipo == 'favorite' || acaoTipo == 'unfavorite';

  /// Check if this is a search action
  bool get isSearchAction => acaoTipo == 'search';

  @override
  List<Object?> get props => [
        ...super.props,
        tipoItem,
        itemId,
        nomeItem,
        acaoTipo,
        dataAcao,
        metadados,
        categoria,
        cultura,
        tempoVisualizacaoSegundos,
      ];
}
