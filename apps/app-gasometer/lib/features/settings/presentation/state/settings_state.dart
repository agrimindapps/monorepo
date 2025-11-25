import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../premium/domain/entities/premium_status.dart';

part 'settings_state.freezed.dart';

/// View states for settings feature
enum SettingsViewState {
  initial,
  loading,
  loaded,
  error,
}

/// State imutável para gerenciamento de configurações
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    /// Tema escuro ativado
    @Default(false) bool isDarkTheme,

    /// Notificações ativadas
    @Default(true) bool notificationsEnabled,

    /// Som ativado
    @Default(true) bool soundEnabled,

    /// Idioma (pt-BR, en-US, es-ES)
    @Default('pt-BR') String language,

    /// Unidade de distância (km, miles)
    @Default('km') String distanceUnit,

    /// Unidade de volume (liters, gallons)
    @Default('liters') String volumeUnit,

    /// Moeda (BRL, USD, EUR)
    @Default('BRL') String currency,

    /// Lembrete de manutenção (dias antes)
    @Default(7) int maintenanceReminderDays,

    /// Backup automático ativado
    @Default(true) bool autoBackupEnabled,

    /// Analytics ativado
    @Default(true) bool analyticsEnabled,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Status premium do usuário
    PremiumStatus? premiumStatus,

    /// ID do usuário atual
    String? currentUserId,

    /// Email do usuário
    String? userEmail,

    /// Nome do usuário
    String? userName,

    /// Última sincronização
    DateTime? lastSync,

    /// Sincronização em progresso
    @Default(false) bool isSyncing,
  }) = _SettingsState;

  /// Factory para estado inicial
  factory SettingsState.initial() => const SettingsState();

  // ========== Computed Properties ==========

  /// Verifica se usuário é premium
  bool get isPremiumUser => premiumStatus?.isPremium ?? false;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se usuário está logado
  bool get isUserLoggedIn => currentUserId != null;

  /// Verifica se backup está habilitado
  bool get isBackupEnabled => autoBackupEnabled && isUserLoggedIn;

  /// Estado da view baseado nos dados
  SettingsViewState get viewState {
    if (isLoading) return SettingsViewState.loading;
    if (hasError) return SettingsViewState.error;
    return SettingsViewState.loaded;
  }

  /// Símbolo da moeda
  String get currencySymbol {
    switch (currency) {
      case 'BRL':
        return 'R\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  /// Nome da unidade de distância
  String get distanceUnitName {
    switch (distanceUnit) {
      case 'km':
        return 'Quilômetros';
      case 'miles':
        return 'Milhas';
      default:
        return distanceUnit;
    }
  }

  /// Nome da unidade de volume
  String get volumeUnitName {
    switch (volumeUnit) {
      case 'liters':
        return 'Litros';
      case 'gallons':
        return 'Galões';
      default:
        return volumeUnit;
    }
  }

  /// Verifica se última sincronização foi recente (últimas 24h)
  bool get isLastSyncRecent {
    if (lastSync == null) return false;
    final difference = DateTime.now().difference(lastSync!);
    return difference.inHours < 24;
  }

  /// Tempo desde última sincronização
  String get lastSyncLabel {
    if (lastSync == null) return 'Nunca';

    final difference = DateTime.now().difference(lastSync!);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}sem atrás';

    return '${(difference.inDays / 30).floor()}m atrás';
  }
}

/// Extension para métodos de transformação do state
extension SettingsStateX on SettingsState {
  /// Limpa mensagem de erro
  SettingsState clearError() => copyWith(error: null);

  /// Reseta ao padrão
  SettingsState resetToDefaults() => SettingsState.initial().copyWith(
        currentUserId: currentUserId,
        userEmail: userEmail,
        userName: userName,
        premiumStatus: premiumStatus,
      );
}
