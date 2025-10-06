// ignore_for_file: public_member_api_docs

/// Providers de analytics, tracking e métricas utilizados por múltiplos
/// apps do monorepo.
///
/// Este arquivo reúne providers Riverpod para analytics, crash reporting,
/// métricas de performance e utilitários relacionados. A regra de
/// documentação pública foi temporariamente suprimida aqui para permitir
/// iterações rápidas; substitua por documentação específica por membro ao
/// evoluir o código.
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../infrastructure/services/firebase_analytics_service.dart';
import '../../../infrastructure/services/firebase_crashlytics_service.dart';
import '../auth/auth_domain_providers.dart' show domainCurrentUserProvider;
import '../premium/subscription_providers.dart';

/// Providers unificados para analytics e tracking
/// Consolidam Firebase Analytics, Crashlytics e métricas customizadas entre todos os apps

/// Provider principal para serviço de analytics
final analyticsServiceProvider = Provider<FirebaseAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Provider para Firebase Analytics instance
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

/// Provider para estado de analytics
final analyticsStateProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
      return AnalyticsNotifier();
    });

/// Provider para verificar se analytics está habilitado
final isAnalyticsEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(analyticsStateProvider);
  return state.maybeWhen(enabled: () => true, orElse: () => false);
});

/// Provider para propriedades do usuário para analytics
final userAnalyticsPropertiesProvider = Provider<Map<String, String>>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  final isPremium = ref.watch(isPremiumProvider);
  final appId = ref.watch(currentAppIdProvider);

  if (user == null) return {};

  return {
    'user_id': user.id,
    'is_premium': isPremium.toString(),
    'app_id': appId,
    'is_anonymous': (user.provider == AuthProvider.anonymous).toString(),
    'account_age_days': _calculateAccountAge(user.createdAt).toString(),
    'last_login': user.lastLoginAt?.toIso8601String() ?? '',
  };
});

/// Provider para tracking de sessão
final sessionTrackingProvider =
    StateNotifierProvider<SessionTrackingNotifier, SessionState>((ref) {
      return SessionTrackingNotifier();
    });

/// Provider para duração da sessão atual
final currentSessionDurationProvider = Provider<Duration>((ref) {
  final session = ref.watch(sessionTrackingProvider);
  return session.maybeWhen(
    active: (startTime) => DateTime.now().difference(startTime),
    orElse: () => Duration.zero,
  );
});

/// Provider para ações de tracking de eventos
final eventTrackingProvider = Provider<EventTracking>((ref) {
  final analytics = ref.read(analyticsServiceProvider);
  final userProperties = ref.watch(userAnalyticsPropertiesProvider);

  return EventTracking(
    trackEvent:
        (eventName, parameters) => analytics
            .logEvent(eventName, parameters: {...userProperties, ...parameters})
            .then((_) => {}), // Convert Either to Future<void>
    trackScreenView:
        (screenName, screenClass) => analytics
            .setCurrentScreen(
              screenName: screenName,
              screenClassOverride: screenClass,
            )
            .then((_) => {}),
    trackUserAction:
        (action, category, label) => analytics
            .logEvent(
              'user_action',
              parameters: {
                'action': action,
                'category': category ?? '',
                'label': label ?? '',
              },
            )
            .then((_) => {}),
    trackFeatureUsage:
        (feature, context) => analytics
            .logEvent(
              'feature_usage',
              parameters: {'feature': feature, ...context},
            )
            .then((_) => {}),
    trackError:
        (error, context) => analytics
            .logError(error: error.toString(), additionalInfo: context)
            .then((_) => {}),
  );
});

/// Provider para métricas de performance
final performanceTrackingProvider =
    StateNotifierProvider<PerformanceTrackingNotifier, PerformanceState>((ref) {
      return PerformanceTrackingNotifier();
    });

/// Provider para métricas de app específico
final appMetricsProvider =
    StateNotifierProvider.family<AppMetricsNotifier, AppMetrics, String>((
      ref,
      appId,
    ) {
      return AppMetricsNotifier(appId);
    });

/// Provider para métricas de negócio por app
final businessMetricsProvider = Provider.family<BusinessMetrics, String>((
  ref,
  appId,
) {
  final appMetrics = ref.watch(appMetricsProvider(appId));
  final isPremium = ref.watch(isPremiumProvider);

  return BusinessMetrics.fromAppMetrics(appId, appMetrics, isPremium);
});

/// Provider para KPIs principais
final kpiProvider = Provider<KPIMetrics>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  final isPremium = ref.watch(isPremiumProvider);
  final sessionDuration = ref.watch(currentSessionDurationProvider);

  return KPIMetrics(
    dau: user != null ? 1 : 0, // Daily Active Users (simplified)
    sessionDuration: sessionDuration,
    isPremiumUser: isPremium,
    retentionDay: _calculateRetentionDay(user?.createdAt),
  );
});

/// Provider para serviço de crash reporting
final crashReportingProvider = Provider<FirebaseCrashlyticsService>((ref) {
  return FirebaseCrashlyticsService();
});

/// Provider para ações de crash reporting
final crashReportingActionsProvider = Provider<CrashReportingActions>((ref) {
  final crashService = ref.read(crashReportingProvider);
  final userProperties = ref.watch(userAnalyticsPropertiesProvider);

  return CrashReportingActions(
    recordError:
        (error, stackTrace, fatal) => crashService
            .recordError(
              exception: error,
              stackTrace: stackTrace ?? StackTrace.empty,
              fatal: fatal,
              additionalInfo: userProperties,
            )
            .then((_) => {}),
    recordFlutterError:
        (flutterError) => crashService
            .recordError(
              exception: flutterError.exception,
              stackTrace: flutterError.stack ?? StackTrace.empty,
              additionalInfo: userProperties,
            )
            .then((_) => {}),
    log: (message) => crashService.log(message).then((_) => {}),
    setCustomKey:
        (key, value) =>
            crashService.setCustomKey(key: key, value: value).then((_) => {}),
    setUserId: (userId) => crashService.setUserId(userId).then((_) => {}),
  );
});

/// Provider para configuração de A/B tests
final abTestConfigProvider = FutureProvider<ABTestConfig>((ref) async {
  final user = ref.watch(domainCurrentUserProvider);

  if (user == null) return ABTestConfig.empty();
  return ABTestConfig.empty();
});

/// Provider para verificar variante de teste específico
final abTestVariantProvider = Provider.family<String?, String>((ref, testName) {
  final config = ref.watch(abTestConfigProvider).value;
  return config?.getVariant(testName);
});

/// Provider para ações de A/B testing
final abTestActionsProvider = Provider<ABTestActions>((ref) {
  final analytics = ref.read(analyticsServiceProvider);

  return ABTestActions(
    trackConversion:
        (testName, variant) => analytics
            .logEvent(
              'ab_test_conversion',
              parameters: {'test_name': testName, 'variant': variant},
            )
            .then((_) => {}),
    trackExposure:
        (testName, variant) => analytics
            .logEvent(
              'ab_test_exposure',
              parameters: {'test_name': testName, 'variant': variant},
            )
            .then((_) => {}),
  );
});

/// Provider para métricas customizadas por app
final customMetricsProvider = Provider.family<CustomMetrics, String>((
  ref,
  appId,
) {
  switch (appId) {
    case 'gasometer':
      return GasometerMetrics(ref);
    case 'plantis':
      return PlantisMetrics(ref);
    case 'receituagro':
      return ReceitaAgroMetrics(ref);
    default:
      return DefaultMetrics(ref);
  }
});

/// Provider para tracking de onboarding
final onboardingTrackingProvider =
    StateNotifierProvider<OnboardingTrackingNotifier, OnboardingState>((ref) {
      return OnboardingTrackingNotifier();
    });

/// Provider para métricas de engagement
final engagementMetricsProvider =
    StateNotifierProvider<EngagementMetricsNotifier, EngagementMetrics>((ref) {
      return EngagementMetricsNotifier();
    });

/// Provider para configurações de privacidade
final privacySettingsProvider = StateProvider<PrivacySettings>((ref) {
  return const PrivacySettings(
    analyticsEnabled: true,
    crashReportingEnabled: true,
    personalizedAdsEnabled: false,
    dataProcessingConsent: false,
  );
});

/// Provider para verificar se pode coletar analytics
final canCollectAnalyticsProvider = Provider<bool>((ref) {
  final settings = ref.watch(privacySettingsProvider);
  return settings.analyticsEnabled && settings.dataProcessingConsent;
});

/// Estados de analytics
abstract class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsDisabled extends AnalyticsState {
  const AnalyticsDisabled();
}

class AnalyticsEnabled extends AnalyticsState {
  const AnalyticsEnabled();
}

class AnalyticsInitializing extends AnalyticsState {
  const AnalyticsInitializing();
}

extension AnalyticsStateExtension on AnalyticsState {
  T maybeWhen<T>({
    T Function()? disabled,
    T Function()? enabled,
    T Function()? initializing,
    required T Function() orElse,
  }) {
    if (this is AnalyticsDisabled && disabled != null) return disabled();
    if (this is AnalyticsEnabled && enabled != null) return enabled();
    if (this is AnalyticsInitializing && initializing != null) {
      return initializing();
    }
    return orElse();
  }
}

/// Estados de sessão
abstract class SessionState {
  const SessionState();
}

class SessionInactive extends SessionState {
  const SessionInactive();
}

class SessionActive extends SessionState {
  final DateTime startTime;
  const SessionActive(this.startTime);
}

extension SessionStateExtension on SessionState {
  T maybeWhen<T>({
    T Function()? inactive,
    T Function(DateTime startTime)? active,
    required T Function() orElse,
  }) {
    if (this is SessionInactive && inactive != null) return inactive();
    if (this is SessionActive && active != null) {
      return active((this as SessionActive).startTime);
    }
    return orElse();
  }
}

/// Estados de performance
class PerformanceState {
  final Map<String, Duration> screenLoadTimes;
  final Map<String, int> apiCallDurations;
  final double appStartupTime;
  final int memoryUsage;
  final double cpuUsage;

  const PerformanceState({
    this.screenLoadTimes = const {},
    this.apiCallDurations = const {},
    this.appStartupTime = 0.0,
    this.memoryUsage = 0,
    this.cpuUsage = 0.0,
  });

  PerformanceState copyWith({
    Map<String, Duration>? screenLoadTimes,
    Map<String, int>? apiCallDurations,
    double? appStartupTime,
    int? memoryUsage,
    double? cpuUsage,
  }) {
    return PerformanceState(
      screenLoadTimes: screenLoadTimes ?? this.screenLoadTimes,
      apiCallDurations: apiCallDurations ?? this.apiCallDurations,
      appStartupTime: appStartupTime ?? this.appStartupTime,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      cpuUsage: cpuUsage ?? this.cpuUsage,
    );
  }
}

/// Métricas por app
class AppMetrics {
  final String appId;
  final int screenViews;
  final int userActions;
  final int featureUsages;
  final int errors;
  final Duration totalSessionTime;
  final Map<String, int> eventCounts;

  const AppMetrics({
    required this.appId,
    this.screenViews = 0,
    this.userActions = 0,
    this.featureUsages = 0,
    this.errors = 0,
    this.totalSessionTime = Duration.zero,
    this.eventCounts = const {},
  });

  AppMetrics copyWith({
    int? screenViews,
    int? userActions,
    int? featureUsages,
    int? errors,
    Duration? totalSessionTime,
    Map<String, int>? eventCounts,
  }) {
    return AppMetrics(
      appId: appId,
      screenViews: screenViews ?? this.screenViews,
      userActions: userActions ?? this.userActions,
      featureUsages: featureUsages ?? this.featureUsages,
      errors: errors ?? this.errors,
      totalSessionTime: totalSessionTime ?? this.totalSessionTime,
      eventCounts: eventCounts ?? this.eventCounts,
    );
  }

  double get engagementScore => _calculateEngagementScore();

  double _calculateEngagementScore() {
    final baseScore =
        (screenViews * 1.0) + (userActions * 2.0) + (featureUsages * 3.0);
    final errorPenalty = errors * 0.5;
    final timeBonus = totalSessionTime.inMinutes * 0.1;

    return (baseScore - errorPenalty + timeBonus).clamp(0.0, 100.0);
  }
}

/// Métricas de negócio
class BusinessMetrics {
  final String appId;
  final int dau; // Daily Active Users
  final int mau; // Monthly Active Users
  final double retentionRate;
  final double conversionRate;
  final double churnRate;
  final double arpu; // Average Revenue Per User
  final bool isPremiumUser;

  const BusinessMetrics({
    required this.appId,
    this.dau = 0,
    this.mau = 0,
    this.retentionRate = 0.0,
    this.conversionRate = 0.0,
    this.churnRate = 0.0,
    this.arpu = 0.0,
    this.isPremiumUser = false,
  });

  factory BusinessMetrics.fromAppMetrics(
    String appId,
    AppMetrics appMetrics,
    bool isPremium,
  ) {
    return BusinessMetrics(
      appId: appId,
      dau: 1, // Simplified - user is active today
      retentionRate: _calculateRetentionRate(appMetrics),
      conversionRate: isPremium ? 1.0 : 0.0,
      isPremiumUser: isPremium,
    );
  }

  static double _calculateRetentionRate(AppMetrics metrics) {
    return (metrics.engagementScore / 100.0).clamp(0.0, 1.0);
  }
}

/// KPIs principais
class KPIMetrics {
  final int dau;
  final Duration sessionDuration;
  final bool isPremiumUser;
  final int retentionDay;

  const KPIMetrics({
    required this.dau,
    required this.sessionDuration,
    required this.isPremiumUser,
    required this.retentionDay,
  });

  double get sessionQuality => _calculateSessionQuality();

  double _calculateSessionQuality() {
    final durationScore = (sessionDuration.inMinutes / 30.0).clamp(0.0, 1.0);
    final premiumBonus = isPremiumUser ? 0.2 : 0.0;
    return (durationScore + premiumBonus).clamp(0.0, 1.0);
  }
}

/// Configuração de A/B tests
class ABTestConfig {
  final Map<String, String> variants;
  final DateTime lastUpdated;

  const ABTestConfig({required this.variants, required this.lastUpdated});

  factory ABTestConfig.empty() {
    return ABTestConfig(variants: const {}, lastUpdated: DateTime.now());
  }

  String? getVariant(String testName) => variants[testName];
  bool hasTest(String testName) => variants.containsKey(testName);
}

/// Estados de onboarding
abstract class OnboardingState {
  const OnboardingState();
}

class OnboardingNotStarted extends OnboardingState {
  const OnboardingNotStarted();
}

class OnboardingInProgress extends OnboardingState {
  final int currentStep;
  final int totalSteps;
  const OnboardingInProgress(this.currentStep, this.totalSteps);
}

class OnboardingCompleted extends OnboardingState {
  final DateTime completedAt;
  const OnboardingCompleted(this.completedAt);
}

class OnboardingSkipped extends OnboardingState {
  final int skippedAtStep;
  const OnboardingSkipped(this.skippedAtStep);
}

/// Métricas de engagement
class EngagementMetrics {
  final int sessionsToday;
  final Duration totalTimeToday;
  final int actionsToday;
  final int daysActive;
  final double engagementScore;

  const EngagementMetrics({
    this.sessionsToday = 0,
    this.totalTimeToday = Duration.zero,
    this.actionsToday = 0,
    this.daysActive = 0,
    this.engagementScore = 0.0,
  });

  EngagementMetrics copyWith({
    int? sessionsToday,
    Duration? totalTimeToday,
    int? actionsToday,
    int? daysActive,
    double? engagementScore,
  }) {
    return EngagementMetrics(
      sessionsToday: sessionsToday ?? this.sessionsToday,
      totalTimeToday: totalTimeToday ?? this.totalTimeToday,
      actionsToday: actionsToday ?? this.actionsToday,
      daysActive: daysActive ?? this.daysActive,
      engagementScore: engagementScore ?? this.engagementScore,
    );
  }
}

/// Configurações de privacidade
class PrivacySettings {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool personalizedAdsEnabled;
  final bool dataProcessingConsent;

  const PrivacySettings({
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.personalizedAdsEnabled,
    required this.dataProcessingConsent,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? personalizedAdsEnabled,
    bool? dataProcessingConsent,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled:
          crashReportingEnabled ?? this.crashReportingEnabled,
      personalizedAdsEnabled:
          personalizedAdsEnabled ?? this.personalizedAdsEnabled,
      dataProcessingConsent:
          dataProcessingConsent ?? this.dataProcessingConsent,
    );
  }
}

/// Ações de tracking de eventos
class EventTracking {
  final Future<void> Function(String eventName, Map<String, String> parameters)
  trackEvent;
  final Future<void> Function(String screenName, String? screenClass)
  trackScreenView;
  final Future<void> Function(String action, String? category, String? label)
  trackUserAction;
  final Future<void> Function(String feature, Map<String, String> context)
  trackFeatureUsage;
  final Future<void> Function(dynamic error, Map<String, String> context)
  trackError;

  const EventTracking({
    required this.trackEvent,
    required this.trackScreenView,
    required this.trackUserAction,
    required this.trackFeatureUsage,
    required this.trackError,
  });
}

/// Ações de crash reporting
class CrashReportingActions {
  final Future<void> Function(dynamic error, StackTrace? stackTrace, bool fatal)
  recordError;
  final Future<void> Function(FlutterErrorDetails flutterError)
  recordFlutterError;
  final Future<void> Function(String message) log;
  final Future<void> Function(String key, String value) setCustomKey;
  final Future<void> Function(String userId) setUserId;

  const CrashReportingActions({
    required this.recordError,
    required this.recordFlutterError,
    required this.log,
    required this.setCustomKey,
    required this.setUserId,
  });
}

/// Ações de A/B testing
class ABTestActions {
  final Future<void> Function(String testName, String variant) trackConversion;
  final Future<void> Function(String testName, String variant) trackExposure;

  const ABTestActions({
    required this.trackConversion,
    required this.trackExposure,
  });
}

/// Métricas customizadas base
abstract class CustomMetrics {
  final Ref ref;
  const CustomMetrics(this.ref);

  Future<void> trackCustomEvent(String event, Map<String, String> parameters);
}

/// Métricas específicas do Gasometer
class GasometerMetrics extends CustomMetrics {
  const GasometerMetrics(super.ref);

  @override
  Future<void> trackCustomEvent(
    String event,
    Map<String, String> parameters,
  ) async {
    final eventTracking = ref.read(eventTrackingProvider);
    await eventTracking.trackEvent('gasometer_$event', {
      'app': 'gasometer',
      ...parameters,
    });
  }

  Future<void> trackFuelEntry(String fuelType, double amount) async {
    await trackCustomEvent('fuel_entry', {
      'fuel_type': fuelType,
      'amount': amount.toString(),
    });
  }

  Future<void> trackExpenseEntry(String category, double amount) async {
    await trackCustomEvent('expense_entry', {
      'category': category,
      'amount': amount.toString(),
    });
  }
}

/// Métricas específicas do Plantis
class PlantisMetrics extends CustomMetrics {
  const PlantisMetrics(super.ref);

  @override
  Future<void> trackCustomEvent(
    String event,
    Map<String, String> parameters,
  ) async {
    final eventTracking = ref.read(eventTrackingProvider);
    await eventTracking.trackEvent('plantis_$event', {
      'app': 'plantis',
      ...parameters,
    });
  }

  Future<void> trackPlantAdded(String plantType) async {
    await trackCustomEvent('plant_added', {'plant_type': plantType});
  }

  Future<void> trackCareAction(String action, String plantType) async {
    await trackCustomEvent('care_action', {
      'action': action,
      'plant_type': plantType,
    });
  }
}

/// Métricas específicas do ReceitaAgro
class ReceitaAgroMetrics extends CustomMetrics {
  const ReceitaAgroMetrics(super.ref);

  @override
  Future<void> trackCustomEvent(
    String event,
    Map<String, String> parameters,
  ) async {
    final eventTracking = ref.read(eventTrackingProvider);
    await eventTracking.trackEvent('receituagro_$event', {
      'app': 'receituagro',
      ...parameters,
    });
  }

  Future<void> trackDiagnosticSearch(String pestType, String cropType) async {
    await trackCustomEvent('diagnostic_search', {
      'pest_type': pestType,
      'crop_type': cropType,
    });
  }
}

/// Métricas padrão
class DefaultMetrics extends CustomMetrics {
  const DefaultMetrics(super.ref);

  @override
  Future<void> trackCustomEvent(
    String event,
    Map<String, String> parameters,
  ) async {
    final eventTracking = ref.read(eventTrackingProvider);
    await eventTracking.trackEvent('default_$event', parameters);
  }
}

/// Notifier para analytics
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsInitializing()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      state = const AnalyticsEnabled();
    } catch (e) {
      state = const AnalyticsDisabled();
    }
  }

  Future<void> enableAnalytics() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      state = const AnalyticsEnabled();
    } catch (e) {
      state = const AnalyticsDisabled();
    }
  }

  Future<void> disableAnalytics() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      state = const AnalyticsDisabled();
    } catch (e) {}
  }
}

/// Notifier para tracking de sessão
class SessionTrackingNotifier extends StateNotifier<SessionState> {
  SessionTrackingNotifier() : super(const SessionInactive());

  void startSession() {
    state = SessionActive(DateTime.now());
  }

  void endSession() {
    state = const SessionInactive();
  }
}

/// Notifier para performance tracking
class PerformanceTrackingNotifier extends StateNotifier<PerformanceState> {
  PerformanceTrackingNotifier() : super(const PerformanceState());

  void recordScreenLoadTime(String screenName, Duration loadTime) {
    state = state.copyWith(
      screenLoadTimes: {...state.screenLoadTimes, screenName: loadTime},
    );
  }

  void recordApiCallDuration(String endpoint, int duration) {
    state = state.copyWith(
      apiCallDurations: {...state.apiCallDurations, endpoint: duration},
    );
  }

  void recordAppStartupTime(double startupTime) {
    state = state.copyWith(appStartupTime: startupTime);
  }
}

/// Notifier para métricas por app
class AppMetricsNotifier extends StateNotifier<AppMetrics> {
  final String appId;

  AppMetricsNotifier(this.appId) : super(AppMetrics(appId: appId));

  void incrementScreenViews() {
    state = state.copyWith(screenViews: state.screenViews + 1);
  }

  void incrementUserActions() {
    state = state.copyWith(userActions: state.userActions + 1);
  }

  void incrementFeatureUsages() {
    state = state.copyWith(featureUsages: state.featureUsages + 1);
  }

  void incrementErrors() {
    state = state.copyWith(errors: state.errors + 1);
  }

  void addSessionTime(Duration duration) {
    state = state.copyWith(totalSessionTime: state.totalSessionTime + duration);
  }

  void recordEvent(String eventName) {
    final currentCount = state.eventCounts[eventName] ?? 0;
    state = state.copyWith(
      eventCounts: {...state.eventCounts, eventName: currentCount + 1},
    );
  }
}

/// Notifier para tracking de onboarding
class OnboardingTrackingNotifier extends StateNotifier<OnboardingState> {
  OnboardingTrackingNotifier() : super(const OnboardingNotStarted());

  void startOnboarding(int totalSteps) {
    state = OnboardingInProgress(1, totalSteps);
  }

  void nextStep() {
    final current = state;
    if (current is OnboardingInProgress) {
      if (current.currentStep >= current.totalSteps) {
        state = OnboardingCompleted(DateTime.now());
      } else {
        state = OnboardingInProgress(
          current.currentStep + 1,
          current.totalSteps,
        );
      }
    }
  }

  void skipOnboarding() {
    final current = state;
    if (current is OnboardingInProgress) {
      state = OnboardingSkipped(current.currentStep);
    }
  }

  void completeOnboarding() {
    state = OnboardingCompleted(DateTime.now());
  }
}

/// Notifier para métricas de engagement
class EngagementMetricsNotifier extends StateNotifier<EngagementMetrics> {
  EngagementMetricsNotifier() : super(const EngagementMetrics());

  void startNewSession() {
    state = state.copyWith(sessionsToday: state.sessionsToday + 1);
  }

  void addSessionTime(Duration duration) {
    state = state.copyWith(totalTimeToday: state.totalTimeToday + duration);
    _updateEngagementScore();
  }

  void recordAction() {
    state = state.copyWith(actionsToday: state.actionsToday + 1);
    _updateEngagementScore();
  }

  void _updateEngagementScore() {
    final sessionScore = (state.sessionsToday * 10.0).clamp(0.0, 50.0);
    final timeScore = (state.totalTimeToday.inMinutes / 60.0 * 30.0).clamp(
      0.0,
      30.0,
    );
    final actionScore = (state.actionsToday * 2.0).clamp(0.0, 20.0);

    final totalScore = sessionScore + timeScore + actionScore;

    state = state.copyWith(engagementScore: totalScore.clamp(0.0, 100.0));
  }
}

int _calculateAccountAge(DateTime? creationTime) {
  if (creationTime == null) return 0;
  return DateTime.now().difference(creationTime).inDays;
}

int _calculateRetentionDay(DateTime? creationTime) {
  if (creationTime == null) return 0;
  return DateTime.now().difference(creationTime).inDays + 1;
}
