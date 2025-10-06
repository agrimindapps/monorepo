import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Onboarding step definition
class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final Map<String, dynamic> config;
  final bool isRequired;
  final List<String> dependencies;

  OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset,
    this.config = const {},
    this.isRequired = true,
    this.dependencies = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_asset': imageAsset,
        'config': config,
        'is_required': isRequired,
        'dependencies': dependencies,
      };

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageAsset: json['image_asset'] as String?,
      config: json['config'] as Map<String, dynamic>? ?? {},
      isRequired: json['is_required'] as bool? ?? true,
      dependencies: (json['dependencies'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// User onboarding progress
class OnboardingProgress {
  final Map<String, bool> completedSteps;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String currentStep;
  final bool isCompleted;

  OnboardingProgress({
    required this.completedSteps,
    this.startedAt,
    this.completedAt,
    required this.currentStep,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
        'completed_steps': completedSteps,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'current_step': currentStep,
        'is_completed': isCompleted,
      };

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      completedSteps: (json['completed_steps'] as Map<String, dynamic>?)?.cast<String, bool>() ?? {},
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      currentStep: json['current_step'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  OnboardingProgress copyWith({
    Map<String, bool>? completedSteps,
    DateTime? startedAt,
    DateTime? completedAt,
    String? currentStep,
    bool? isCompleted,
  }) {
    return OnboardingProgress(
      completedSteps: completedSteps ?? this.completedSteps,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Feature discovery tooltip
class FeatureTooltip {
  final String id;
  final String title;
  final String description;
  final String targetWidget;
  final Map<String, dynamic> config;
  final int priority;
  final List<String> triggers;

  FeatureTooltip({
    required this.id,
    required this.title,
    required this.description,
    required this.targetWidget,
    this.config = const {},
    this.priority = 1,
    this.triggers = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target_widget': targetWidget,
        'config': config,
        'priority': priority,
        'triggers': triggers,
      };

  factory FeatureTooltip.fromJson(Map<String, dynamic> json) {
    return FeatureTooltip(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetWidget: json['target_widget'] as String,
      config: json['config'] as Map<String, dynamic>? ?? {},
      priority: json['priority'] as int? ?? 1,
      triggers: (json['triggers'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// Onboarding Service for ReceitauAgro
/// Manages user onboarding flow and feature discovery
class OnboardingService {
  static OnboardingService? _instance;
  static OnboardingService get instance => _instance ??= OnboardingService._();

  OnboardingService._();

  late ILocalStorageRepository _localStorage;
  late IAnalyticsRepository _analytics;
  bool _isInitialized = false;
  final List<OnboardingStep> _onboardingSteps = [];
  OnboardingProgress? _currentProgress;
  final List<FeatureTooltip> _featureTooltips = [];
  final Set<String> _shownTooltips = {};
  static const String _progressKey = 'receituagro_onboarding_progress';
  static const String _tooltipsKey = 'receituagro_shown_tooltips';

  /// Initialize onboarding service
  Future<void> initialize({
    required ILocalStorageRepository localStorage,
    required IAnalyticsRepository analytics,
  }) async {
    if (_isInitialized) return;

    _localStorage = localStorage;
    _analytics = analytics;
    await _setupOnboardingSteps();
    await _setupFeatureTooltips();
    await _loadProgress();

    _isInitialized = true;

    if (kDebugMode) {
      print('🎯 Onboarding Service initialized');
    }
  }

  /// Setup default onboarding steps for ReceitauAgro
  Future<void> _setupOnboardingSteps() async {
    _onboardingSteps.addAll([
      OnboardingStep(
        id: 'welcome',
        title: 'Bem-vindo ao ReceitauAgro!',
        description: 'Seu assistente completo para diagnóstico e controle de pragas e doenças agrícolas.',
        imageAsset: 'assets/images/onboarding_welcome.png',
        config: {
          'show_logo': true,
          'background_color': '#4CAF50',
        },
      ),
      OnboardingStep(
        id: 'explore_database',
        title: 'Explore o Banco de Pragas',
        description: 'Acesse informações detalhadas sobre pragas, doenças e culturas.',
        imageAsset: 'assets/images/onboarding_database.png',
        config: {
          'highlight_search': true,
          'show_categories': true,
        },
      ),
      OnboardingStep(
        id: 'diagnostic_tool',
        title: 'Use a Ferramenta de Diagnóstico',
        description: 'Identifique problemas em suas culturas usando nossos filtros inteligentes.',
        imageAsset: 'assets/images/onboarding_diagnostic.png',
        config: {
          'demo_filters': ['cultura', 'sintoma', 'parte_afetada'],
        },
      ),
      OnboardingStep(
        id: 'favorites',
        title: 'Salve seus Favoritos',
        description: 'Marque pragas e diagnósticos importantes para acesso rápido.',
        imageAsset: 'assets/images/onboarding_favorites.png',
        config: {
          'show_favorite_button': true,
        },
      ),
      OnboardingStep(
        id: 'premium_features',
        title: 'Recursos Premium',
        description: 'Desbloqueie funcionalidades avançadas com a assinatura Premium.',
        imageAsset: 'assets/images/onboarding_premium.png',
        config: {
          'highlight_premium': ['export', 'advanced_search', 'comments'],
        },
        isRequired: false,
      ),
      OnboardingStep(
        id: 'notifications',
        title: 'Mantenha-se Atualizado',
        description: 'Receba notificações sobre novas pragas e atualizações importantes.',
        imageAsset: 'assets/images/onboarding_notifications.png',
        config: {
          'request_permission': true,
        },
        isRequired: false,
      ),
      OnboardingStep(
        id: 'profile_setup',
        title: 'Configure seu Perfil',
        description: 'Personalize sua experiência definindo suas culturas principais.',
        imageAsset: 'assets/images/onboarding_profile.png',
        config: {
          'suggest_cultures': ['soja', 'milho', 'algodão', 'café'],
        },
        isRequired: false,
      ),
    ]);
  }

  /// Setup feature discovery tooltips
  Future<void> _setupFeatureTooltips() async {
    _featureTooltips.addAll([
      FeatureTooltip(
        id: 'search_filters',
        title: 'Busca Avançada',
        description: 'Use os filtros para encontrar exatamente o que precisa',
        targetWidget: 'search_filters_button',
        priority: 1,
        triggers: ['first_search'],
        config: {
          'position': 'bottom',
          'delay_ms': 2000,
        },
      ),
      FeatureTooltip(
        id: 'export_function',
        title: 'Exportar Relatórios',
        description: 'Gere relatórios PDF dos seus diagnósticos (Premium)',
        targetWidget: 'export_button',
        priority: 2,
        triggers: ['diagnostic_completed'],
        config: {
          'premium_only': true,
          'position': 'top',
        },
      ),
      FeatureTooltip(
        id: 'comment_system',
        title: 'Sistema de Comentários',
        description: 'Compartilhe experiências com outros usuários (Premium)',
        targetWidget: 'comments_tab',
        priority: 3,
        triggers: ['viewing_plague_details'],
        config: {
          'premium_only': true,
          'position': 'left',
        },
      ),
      FeatureTooltip(
        id: 'sync_devices',
        title: 'Sincronização',
        description: 'Seus dados são sincronizados entre todos os dispositivos',
        targetWidget: 'sync_status_icon',
        priority: 2,
        triggers: ['second_session'],
        config: {
          'position': 'bottom',
          'show_sync_animation': true,
        },
      ),
      FeatureTooltip(
        id: 'offline_access',
        title: 'Acesso Offline',
        description: 'Consulte dados mesmo sem conexão com a internet',
        targetWidget: 'offline_indicator',
        priority: 3,
        triggers: ['network_disconnected'],
        config: {
          'position': 'top',
          'timeout_ms': 5000,
        },
      ),
    ]);
  }

  /// Start onboarding flow
  Future<void> startOnboarding() async {
    if (!_isInitialized) return;

    final progress = OnboardingProgress(
      completedSteps: {},
      startedAt: DateTime.now(),
      completedAt: null,
      currentStep: _onboardingSteps.first.id,
      isCompleted: false,
    );

    _currentProgress = progress;
    await _saveProgress();
    await _analytics.logEvent(
      'onboarding_started',
      parameters: {
        'total_steps': _onboardingSteps.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🎯 Onboarding started');
    }
  }

  /// Complete onboarding step
  Future<void> completeStep(String stepId) async {
    if (!_isInitialized || _currentProgress == null) return;

    final step = _onboardingSteps.firstWhere(
      (s) => s.id == stepId,
      orElse: () => throw Exception('Step not found: $stepId'),
    );
    for (final dependency in step.dependencies) {
      if (_currentProgress!.completedSteps[dependency] != true) {
        throw Exception('Dependency not completed: $dependency');
      }
    }
    final updatedSteps = Map<String, bool>.from(_currentProgress!.completedSteps);
    updatedSteps[stepId] = true;
    final currentIndex = _onboardingSteps.indexWhere((s) => s.id == stepId);
    final nextStep = currentIndex < _onboardingSteps.length - 1 
        ? _onboardingSteps[currentIndex + 1] 
        : null;
    final requiredSteps = _onboardingSteps.where((s) => s.isRequired).toList();
    final completedRequired = requiredSteps.where((s) => updatedSteps[s.id] == true).length;
    final isCompleted = completedRequired == requiredSteps.length;

    _currentProgress = _currentProgress!.copyWith(
      completedSteps: updatedSteps,
      currentStep: nextStep?.id ?? '',
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    await _saveProgress();
    await _analytics.logEvent(
      'onboarding_step_completed',
      parameters: {
        'step_id': stepId,
        'step_title': step.title,
        'is_onboarding_completed': isCompleted,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (isCompleted) {
      await _analytics.logEvent(
        'onboarding_completed',
        parameters: {
          'total_steps_completed': updatedSteps.length,
          'duration_minutes': _currentProgress!.startedAt != null 
              ? DateTime.now().difference(_currentProgress!.startedAt!).inMinutes
              : 0,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (kDebugMode) {
        print('🎯 Onboarding completed!');
      }
    }
  }

  /// Skip onboarding step (if optional)
  Future<void> skipStep(String stepId) async {
    final step = _onboardingSteps.firstWhere(
      (s) => s.id == stepId,
      orElse: () => throw Exception('Step not found: $stepId'),
    );

    if (step.isRequired) {
      throw Exception('Cannot skip required step: $stepId');
    }

    await _analytics.logEvent(
      'onboarding_step_skipped',
      parameters: {
        'step_id': stepId,
        'step_title': step.title,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    await completeStep(stepId);
  }

  /// Show feature tooltip
  Future<void> showFeatureTooltip(String tooltipId, {Map<String, dynamic>? context}) async {
    if (!_isInitialized || _shownTooltips.contains(tooltipId)) return;

    final tooltip = _featureTooltips.firstWhere(
      (t) => t.id == tooltipId,
      orElse: () => throw Exception('Tooltip not found: $tooltipId'),
    );

    _shownTooltips.add(tooltipId);
    await _saveTooltipState();

    await _analytics.logEvent(
      'feature_tooltip_shown',
      parameters: {
        'tooltip_id': tooltipId,
        'tooltip_title': tooltip.title,
        'target_widget': tooltip.targetWidget,
        'context': context ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🎯 Feature tooltip shown: $tooltipId');
    }
  }

  /// Check if tooltip should be shown for trigger
  Future<List<FeatureTooltip>> getTooltipsForTrigger(String trigger) async {
    if (!_isInitialized) return [];

    return _featureTooltips
        .where((tooltip) =>
            tooltip.triggers.contains(trigger) &&
            !_shownTooltips.contains(tooltip.id))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Get current onboarding progress
  OnboardingProgress? getCurrentProgress() => _currentProgress;

  /// Get onboarding steps
  List<OnboardingStep> getOnboardingSteps() => List.unmodifiable(_onboardingSteps);

  /// Check if onboarding is completed
  bool isOnboardingCompleted() => _currentProgress?.isCompleted ?? false;

  /// Get completion percentage
  double getCompletionPercentage() {
    if (_currentProgress == null) return 0.0;
    
    final totalRequired = _onboardingSteps.where((s) => s.isRequired).length;
    final completed = _currentProgress!.completedSteps.values
        .where((completed) => completed)
        .length;
    
    return totalRequired > 0 ? (completed / totalRequired * 100) : 0.0;
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    _currentProgress = null;
    _shownTooltips.clear();
    
    await _localStorage.remove(key: _progressKey);
    await _localStorage.remove(key: _tooltipsKey);

    await _analytics.logEvent(
      'onboarding_reset',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🎯 Onboarding reset');
    }
  }

  /// Load progress from storage
  Future<void> _loadProgress() async {
    try {
      final progressResult = await _localStorage.get<String>(key: _progressKey);
      await progressResult.fold(
        (failure) async {
          if (kDebugMode) {
            print('🎯 No saved onboarding progress found');
          }
        },
        (data) async {
          if (data != null) {
            final json = jsonDecode(data) as Map<String, dynamic>;
            _currentProgress = OnboardingProgress.fromJson(json);
          }
        },
      );

      final tooltipsResult = await _localStorage.get<String>(key: _tooltipsKey);
      await tooltipsResult.fold(
        (failure) async {
        },
        (data) async {
          if (data != null) {
            final List<dynamic> tooltipsList = jsonDecode(data) as List;
            _shownTooltips.addAll(tooltipsList.cast<String>());
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load onboarding progress: $e');
      }
    }
  }

  /// Save progress to storage
  Future<void> _saveProgress() async {
    if (_currentProgress == null) return;

    try {
      await _localStorage.save<String>(
        key: _progressKey,
        data: jsonEncode(_currentProgress!.toJson()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save onboarding progress: $e');
      }
    }
  }

  /// Save tooltip state to storage
  Future<void> _saveTooltipState() async {
    try {
      await _localStorage.save<String>(
        key: _tooltipsKey,
        data: jsonEncode(_shownTooltips.toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save tooltip state: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _onboardingSteps.clear();
    _featureTooltips.clear();
    _shownTooltips.clear();
    _currentProgress = null;
    _isInitialized = false;
  }
}
