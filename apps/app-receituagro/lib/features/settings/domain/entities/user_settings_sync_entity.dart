import 'package:core/core.dart';

/// Entidade de sincronização para configurações do usuário
/// Extends BaseSyncEntity do core package para compatibilidade
class UserSettingsSyncEntity extends BaseSyncEntity {
  final String tema;
  final String idioma;
  final bool notificacoesPush;
  final bool notificacoesEmail;
  final bool modoProdutorRural;
  final Map<String, dynamic> configuracoesBusca;
  final Map<String, dynamic> preferenciasVisualizacao;
  final bool syncAutomatico;
  final int frequenciaSyncMinutos;

  const UserSettingsSyncEntity({
    required String id,
    required this.tema,
    required this.idioma,
    required this.notificacoesPush,
    required this.notificacoesEmail,
    required this.modoProdutorRural,
    required this.configuracoesBusca,
    required this.preferenciasVisualizacao,
    required this.syncAutomatico,
    required this.frequenciaSyncMinutos,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'tema': tema,
      'idioma': idioma,
      'notificacoesPush': notificacoesPush,
      'notificacoesEmail': notificacoesEmail,
      'modoProdutorRural': modoProdutorRural,
      'configuracoesBusca': configuracoesBusca,
      'preferenciasVisualizacao': preferenciasVisualizacao,
      'syncAutomatico': syncAutomatico,
      'frequenciaSyncMinutos': frequenciaSyncMinutos,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tema': tema,
      'idioma': idioma,
      'notificacoesPush': notificacoesPush,
      'notificacoesEmail': notificacoesEmail,
      'modoProdutorRural': modoProdutorRural,
      'configuracoesBusca': configuracoesBusca,
      'preferenciasVisualizacao': preferenciasVisualizacao,
      'syncAutomatico': syncAutomatico,
      'frequenciaSyncMinutos': frequenciaSyncMinutos,
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

  static UserSettingsSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return UserSettingsSyncEntity(
      id: baseFields['id'] as String,
      tema: map['tema'] as String,
      idioma: map['idioma'] as String,
      notificacoesPush: map['notificacoesPush'] as bool,
      notificacoesEmail: map['notificacoesEmail'] as bool,
      modoProdutorRural: map['modoProdutorRural'] as bool,
      configuracoesBusca: Map<String, dynamic>.from(map['configuracoesBusca'] as Map),
      preferenciasVisualizacao: Map<String, dynamic>.from(map['preferenciasVisualizacao'] as Map),
      syncAutomatico: map['syncAutomatico'] as bool,
      frequenciaSyncMinutos: map['frequenciaSyncMinutos'] as int,
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

  factory UserSettingsSyncEntity.fromMap(Map<String, dynamic> map) {
    return UserSettingsSyncEntity(
      id: map['id'] as String,
      tema: map['tema'] as String,
      idioma: map['idioma'] as String,
      notificacoesPush: map['notificacoesPush'] as bool,
      notificacoesEmail: map['notificacoesEmail'] as bool,
      modoProdutorRural: map['modoProdutorRural'] as bool,
      configuracoesBusca: Map<String, dynamic>.from(map['configuracoesBusca'] as Map),
      preferenciasVisualizacao: Map<String, dynamic>.from(map['preferenciasVisualizacao'] as Map),
      syncAutomatico: map['syncAutomatico'] as bool,
      frequenciaSyncMinutos: map['frequenciaSyncMinutos'] as int,
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

  /// Factory para criar configurações padrão
  factory UserSettingsSyncEntity.defaultSettings({
    required String userId,
  }) {
    return UserSettingsSyncEntity(
      id: 'user_settings_$userId',
      tema: 'light',
      idioma: 'pt_BR',
      notificacoesPush: true,
      notificacoesEmail: false,
      modoProdutorRural: false,
      configuracoesBusca: {
        'filtrosPadraoAtivos': true,
        'exibirResultadosDetalhados': true,
        'ordenacaoPadrao': 'relevancia',
      },
      preferenciasVisualizacao: {
        'exibirImagens': true,
        'tamanhoPadrao': 'medio',
        'visualizacaoPadrao': 'lista',
      },
      syncAutomatico: true,
      frequenciaSyncMinutos: 30,
      userId: userId,
      moduleName: 'receituagro',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity copyWith({
    String? id,
    String? tema,
    String? idioma,
    bool? notificacoesPush,
    bool? notificacoesEmail,
    bool? modoProdutorRural,
    Map<String, dynamic>? configuracoesBusca,
    Map<String, dynamic>? preferenciasVisualizacao,
    bool? syncAutomatico,
    int? frequenciaSyncMinutos,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return UserSettingsSyncEntity(
      id: id ?? this.id,
      tema: tema ?? this.tema,
      idioma: idioma ?? this.idioma,
      notificacoesPush: notificacoesPush ?? this.notificacoesPush,
      notificacoesEmail: notificacoesEmail ?? this.notificacoesEmail,
      modoProdutorRural: modoProdutorRural ?? this.modoProdutorRural,
      configuracoesBusca: configuracoesBusca ?? this.configuracoesBusca,
      preferenciasVisualizacao: preferenciasVisualizacao ?? this.preferenciasVisualizacao,
      syncAutomatico: syncAutomatico ?? this.syncAutomatico,
      frequenciaSyncMinutos: frequenciaSyncMinutos ?? this.frequenciaSyncMinutos,
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
  UserSettingsSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  UserSettingsSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  UserSettingsSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  @override
  List<Object?> get props => [
        ...super.props,
        tema,
        idioma,
        notificacoesPush,
        notificacoesEmail,
        modoProdutorRural,
        configuracoesBusca,
        preferenciasVisualizacao,
        syncAutomatico,
        frequenciaSyncMinutos,
      ];
}