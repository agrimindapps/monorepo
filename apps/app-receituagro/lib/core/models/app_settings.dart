import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Modelo de dados para configurações do aplicativo
///
/// Representa as configurações específicas do usuário armazenadas no Drift
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// ID único da configuração
    required int id,

    /// ID do Firebase para sincronização
    String? firebaseId,

    /// ID do usuário
    required String userId,

    /// Nome do módulo (sempre 'receituagro')
    @Default('receituagro') String moduleName,

    /// Data de criação
    required DateTime createdAt,

    /// Data da última atualização
    DateTime? updatedAt,

    /// Data da última sincronização
    DateTime? lastSyncAt,

    /// Se está sujo (precisa sincronizar)
    @Default(false) bool isDirty,

    /// Se está deletado (soft delete)
    @Default(false) bool isDeleted,

    /// Versão do registro
    @Default(1) int version,

    /// Tema do app ('light', 'dark', 'system')
    @Default('system') String theme,

    /// Idioma do app ('pt', 'en', 'es')
    @Default('pt') String language,

    /// Notificações habilitadas
    @Default(true) bool enableNotifications,

    /// Sincronização habilitada
    @Default(true) bool enableSync,

    /// Flags de funcionalidades (JSON string)
    @Default('{}') String featureFlags,
  }) = _AppSettings;
}
