import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'failure.dart';

/// Base class for all ad-related failures
/// Extends the core Failure class with ad-specific context
abstract class AdsFailure extends Failure {
  const AdsFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Failure when ad fails to load
/// Can include various Google Ads error codes
class AdLoadFailure extends AdsFailure {
  const AdLoadFailure(
    String message, {
    super.code,
    super.details,
  }) : super(
    message: message,
  );

  /// Ad failed to load due to no inventory (no ads available)
  factory AdLoadFailure.noInventory() => const AdLoadFailure(
        'Nenhum anúncio disponível no momento',
        code: 'NO_INVENTORY',
      );

  /// Ad failed to load due to network error
  factory AdLoadFailure.networkError() => const AdLoadFailure(
        'Erro de rede ao carregar anúncio',
        code: 'NETWORK_ERROR',
      );

  /// Ad failed to load due to invalid request
  factory AdLoadFailure.invalidRequest([String? details]) => AdLoadFailure(
        'Requisição inválida para anúncio',
        code: 'INVALID_REQUEST',
        details: details,
      );

  /// Ad failed to load - internal error
  factory AdLoadFailure.internalError([String? details]) => AdLoadFailure(
        'Erro interno ao carregar anúncio',
        code: 'INTERNAL_ERROR',
        details: details,
      );

  /// Ad failed to load - timeout
  factory AdLoadFailure.timeout() => const AdLoadFailure(
        'Tempo esgotado ao carregar anúncio',
        code: 'TIMEOUT',
      );
}

/// Failure when ad fails to show
class AdShowFailure extends AdsFailure {
  const AdShowFailure(
    String message, {
    super.code,
    super.details,
  }) : super(
    message: message,
  );

  /// Cannot show ad because it's not loaded/ready
  factory AdShowFailure.notReady() => const AdShowFailure(
        'Anúncio não está pronto para exibição',
        code: 'AD_NOT_READY',
      );

  /// Cannot show ad because another ad is already showing
  factory AdShowFailure.alreadyShowing() => const AdShowFailure(
        'Já existe um anúncio sendo exibido',
        code: 'AD_ALREADY_SHOWING',
      );

  /// Ad failed to show due to internal error
  factory AdShowFailure.internalError([String? details]) => AdShowFailure(
        'Erro ao exibir anúncio',
        code: 'SHOW_ERROR',
        details: details,
      );
}

/// Failure related to ad configuration
class AdConfigFailure extends AdsFailure {
  const AdConfigFailure(
    String message, {
    super.code,
    super.details,
  }) : super(
          message: message,
        );

  /// Ad unit ID is invalid or missing
  factory AdConfigFailure.invalidAdUnitId([String? adUnitId]) => AdConfigFailure(
        'ID de unidade de anúncio inválido',
        code: 'INVALID_AD_UNIT_ID',
        details: adUnitId,
      );

  /// Ad configuration is missing or incomplete
  factory AdConfigFailure.missingConfiguration() => const AdConfigFailure(
        'Configuração de anúncios ausente',
        code: 'MISSING_CONFIG',
      );

  /// App ID is invalid or missing
  factory AdConfigFailure.invalidAppId([String? appId]) => AdConfigFailure(
        'App ID inválido',
        code: 'INVALID_APP_ID',
        details: appId,
      );
}

/// Failure during ads initialization
class AdInitializationFailure extends AdsFailure {
  const AdInitializationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(
          message: message,
        );

  /// Ads SDK failed to initialize
  factory AdInitializationFailure.sdkInitFailed([String? details]) =>
      AdInitializationFailure(
        'Falha ao inicializar SDK de anúncios',
        code: 'SDK_INIT_FAILED',
        details: details,
      );

  /// Ads already initialized
  factory AdInitializationFailure.alreadyInitialized() =>
      const AdInitializationFailure(
        'SDK de anúncios já foi inicializado',
        code: 'ALREADY_INITIALIZED',
      );
}

/// Failure when frequency cap is reached
/// Prevents showing too many ads to users
class AdFrequencyCapFailure extends AdsFailure {
  const AdFrequencyCapFailure(
    String message, {
    super.code,
    super.details,
  }) : super(
          message: message,
        );

  /// Daily limit reached
  factory AdFrequencyCapFailure.dailyLimitReached() =>
      const AdFrequencyCapFailure(
        'Limite diário de anúncios atingido',
        code: 'DAILY_LIMIT_REACHED',
      );

  /// Session limit reached
  factory AdFrequencyCapFailure.sessionLimitReached() =>
      const AdFrequencyCapFailure(
        'Limite de anúncios por sessão atingido',
        code: 'SESSION_LIMIT_REACHED',
      );

  /// Minimum interval not elapsed
  factory AdFrequencyCapFailure.tooSoon() => const AdFrequencyCapFailure(
        'Intervalo mínimo entre anúncios não atingido',
        code: 'TOO_SOON',
      );

  /// Hourly limit reached
  factory AdFrequencyCapFailure.hourlyLimitReached() =>
      const AdFrequencyCapFailure(
        'Limite de anúncios por hora atingido',
        code: 'HOURLY_LIMIT_REACHED',
      );
}

/// Failure when user has premium subscription
/// Premium users should not see ads
class AdPremiumBlockFailure extends AdsFailure {
  const AdPremiumBlockFailure()
      : super(
          message: 'Usuário premium não vê anúncios',
          code: 'PREMIUM_USER',
        );
}

/// Extension to convert Google Ads error codes to our failures
extension GoogleAdsErrorCodeExtension on LoadAdError {
  /// Convert LoadAdError to AdLoadFailure
  AdLoadFailure toFailure() {
    switch (code) {
      case 0:
        return AdLoadFailure.internalError('Internal error');
      case 1:
        return AdLoadFailure.invalidRequest('Invalid request');
      case 2:
        return AdLoadFailure.networkError();
      case 3:
        return AdLoadFailure.noInventory();
      default:
        return AdLoadFailure(
          message,
          code: code.toString(),
          details: domain,
        );
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    // Network errors and no inventory are retryable
    return code == 2 || code == 3;
  }
}

/// Extension for FullScreenContentCallback errors
extension FullScreenContentErrorExtension on AdError {
  /// Convert AdError to AdShowFailure
  AdShowFailure toShowFailure() {
    return AdShowFailure(
      message,
      code: code.toString(),
      details: domain,
    );
  }
}

/// Helper to categorize ad failures for logging/analytics
extension AdsFailureAnalytics on AdsFailure {
  /// Get category for analytics
  String get category {
    if (this is AdLoadFailure) return 'ad_load_error';
    if (this is AdShowFailure) return 'ad_show_error';
    if (this is AdConfigFailure) return 'ad_config_error';
    if (this is AdInitializationFailure) return 'ad_init_error';
    if (this is AdFrequencyCapFailure) return 'ad_frequency_cap';
    if (this is AdPremiumBlockFailure) return 'ad_premium_block';
    return 'ad_unknown_error';
  }

  /// Check if failure is critical (needs immediate attention)
  bool get isCritical {
    return this is AdInitializationFailure || this is AdConfigFailure;
  }

  /// Check if failure is expected/normal (e.g., premium user, frequency cap)
  bool get isExpected {
    return this is AdPremiumBlockFailure || this is AdFrequencyCapFailure;
  }

  /// Get user-friendly message
  String get userMessage {
    if (this is AdPremiumBlockFailure) {
      return 'Você não verá anúncios pois é um usuário premium!';
    }
    if (this is AdFrequencyCapFailure) {
      return 'Por favor, tente novamente mais tarde.';
    }
    if (this is AdLoadFailure) {
      return 'Não foi possível carregar o anúncio no momento.';
    }
    return 'Ocorreu um erro com os anúncios.';
  }
}
