import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Beta testing phases
enum BetaPhase {
  alpha('alpha'),
  closedBeta('closed_beta'),
  openBeta('open_beta'),
  releaseCandidate('release_candidate'),
  production('production');

  const BetaPhase(this.value);
  final String value;
}

/// Beta tester profile
class BetaTester {
  final String id;
  final String email;
  final String name;
  final BetaPhase phase;
  final DateTime joinedAt;
  final Map<String, dynamic> metadata;
  final bool isActive;

  BetaTester({
    required this.id,
    required this.email,
    required this.name,
    required this.phase,
    required this.joinedAt,
    this.metadata = const {},
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phase': phase.value,
        'joined_at': joinedAt.toIso8601String(),
        'metadata': metadata,
        'is_active': isActive,
      };

  factory BetaTester.fromJson(Map<String, dynamic> json) {
    return BetaTester(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phase: BetaPhase.values.firstWhere(
        (p) => p.value == json['phase'],
        orElse: () => BetaPhase.closedBeta,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Beta feedback entry
class BetaFeedback {
  final String id;
  final String testerId;
  final String title;
  final String description;
  final String category;
  final int priority;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  BetaFeedback({
    required this.id,
    required this.testerId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tester_id': testerId,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'metadata': metadata,
      };

  factory BetaFeedback.fromJson(Map<String, dynamic> json) {
    return BetaFeedback(
      id: json['id'] as String,
      testerId: json['tester_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Release checklist item
class ReleaseChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final bool isCompleted;
  final String category;
  final DateTime? completedAt;

  ReleaseChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isRequired,
    required this.isCompleted,
    required this.category,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_required': isRequired,
        'is_completed': isCompleted,
        'category': category,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory ReleaseChecklistItem.fromJson(Map<String, dynamic> json) {
    return ReleaseChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isRequired: json['is_required'] as bool,
      isCompleted: json['is_completed'] as bool,
      category: json['category'] as String,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
    );
  }

  ReleaseChecklistItem copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ReleaseChecklistItem(
      id: id,
      title: title,
      description: description,
      isRequired: isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Beta Testing Service for ReceitauAgro
/// Manages beta testing program and production release preparation
class BetaTestingService {
  static BetaTestingService? _instance;
  static BetaTestingService get instance => _instance ??= BetaTestingService._();

  BetaTestingService._();

  late ILocalStorageRepository _localStorage;
  late IAnalyticsRepository _analytics;
  bool _isInitialized = false;

  // Beta testing data
  BetaPhase _currentPhase = BetaPhase.closedBeta;
  final List<BetaTester> _testers = [];
  final List<BetaFeedback> _feedback = [];
  final List<ReleaseChecklistItem> _checklist = [];

  // Constants
  static const String _phaseKey = 'receituagro_beta_phase';
  static const String _testersKey = 'receituagro_beta_testers';
  static const String _feedbackKey = 'receituagro_beta_feedback';
  static const String _checklistKey = 'receituagro_release_checklist';

  /// Initialize beta testing service
  Future<void> initialize({
    required ILocalStorageRepository localStorage,
    required IAnalyticsRepository analytics,
  }) async {
    if (_isInitialized) return;

    _localStorage = localStorage;
    _analytics = analytics;

    // Setup release checklist
    await _setupReleaseChecklist();

    // Load saved data
    await _loadBetaData();

    _isInitialized = true;

    if (kDebugMode) {
      print('🧪 Beta Testing Service initialized');
    }
  }

  /// Setup default release checklist
  Future<void> _setupReleaseChecklist() async {
    _checklist.addAll([
      // Development checklist
      ReleaseChecklistItem(
        id: 'code_complete',
        title: 'Código Completo',
        description: 'Todas as funcionalidades implementadas e testadas',
        isRequired: true,
        isCompleted: false,
        category: 'development',
      ),
      ReleaseChecklistItem(
        id: 'unit_tests',
        title: 'Testes Unitários',
        description: 'Cobertura de testes >= 80%',
        isRequired: true,
        isCompleted: false,
        category: 'development',
      ),
      ReleaseChecklistItem(
        id: 'integration_tests',
        title: 'Testes de Integração',
        description: 'Fluxos críticos testados e aprovados',
        isRequired: true,
        isCompleted: false,
        category: 'development',
      ),

      // QA checklist
      ReleaseChecklistItem(
        id: 'manual_testing',
        title: 'Testes Manuais',
        description: 'QA completo em dispositivos físicos',
        isRequired: true,
        isCompleted: false,
        category: 'qa',
      ),
      ReleaseChecklistItem(
        id: 'performance_testing',
        title: 'Testes de Performance',
        description: 'App roda suavemente em dispositivos de gama baixa',
        isRequired: true,
        isCompleted: false,
        category: 'qa',
      ),
      ReleaseChecklistItem(
        id: 'accessibility_testing',
        title: 'Testes de Acessibilidade',
        description: 'App acessível para usuários com deficiências',
        isRequired: true,
        isCompleted: false,
        category: 'qa',
      ),

      // Security checklist
      ReleaseChecklistItem(
        id: 'security_audit',
        title: 'Auditoria de Segurança',
        description: 'Revisão completa de segurança dos dados',
        isRequired: true,
        isCompleted: false,
        category: 'security',
      ),
      ReleaseChecklistItem(
        id: 'data_encryption',
        title: 'Criptografia de Dados',
        description: 'Dados sensíveis criptografados adequadamente',
        isRequired: true,
        isCompleted: false,
        category: 'security',
      ),

      // Infrastructure checklist
      ReleaseChecklistItem(
        id: 'backend_ready',
        title: 'Backend Preparado',
        description: 'Serviços Firebase configurados e testados',
        isRequired: true,
        isCompleted: false,
        category: 'infrastructure',
      ),
      ReleaseChecklistItem(
        id: 'monitoring_setup',
        title: 'Monitoramento Configurado',
        description: 'Analytics e crash reporting ativos',
        isRequired: true,
        isCompleted: false,
        category: 'infrastructure',
      ),
      ReleaseChecklistItem(
        id: 'backup_strategy',
        title: 'Estratégia de Backup',
        description: 'Backup e recuperação de dados implementados',
        isRequired: true,
        isCompleted: false,
        category: 'infrastructure',
      ),

      // Release checklist
      ReleaseChecklistItem(
        id: 'app_store_assets',
        title: 'Assets da App Store',
        description: 'Screenshots, ícones e descrições preparados',
        isRequired: true,
        isCompleted: false,
        category: 'release',
      ),
      ReleaseChecklistItem(
        id: 'release_notes',
        title: 'Notas de Lançamento',
        description: 'Changelog e notas de versão escritas',
        isRequired: true,
        isCompleted: false,
        category: 'release',
      ),
      ReleaseChecklistItem(
        id: 'staged_rollout',
        title: 'Lançamento Gradual',
        description: 'Estratégia de rollout percentual configurada',
        isRequired: true,
        isCompleted: false,
        category: 'release',
      ),

      // Post-release checklist
      ReleaseChecklistItem(
        id: 'support_documentation',
        title: 'Documentação de Suporte',
        description: 'FAQ e documentação de usuário atualizadas',
        isRequired: false,
        isCompleted: false,
        category: 'post_release',
      ),
      ReleaseChecklistItem(
        id: 'marketing_materials',
        title: 'Materiais de Marketing',
        description: 'Conteúdo promocional e campanhas preparadas',
        isRequired: false,
        isCompleted: false,
        category: 'post_release',
      ),
    ]);
  }

  /// Set current beta phase
  Future<void> setBetaPhase(BetaPhase phase) async {
    if (!_isInitialized) return;

    final previousPhase = _currentPhase;
    _currentPhase = phase;
    
    await _saveBetaPhase();

    await _analytics.logEvent(
      'beta_phase_changed',
      parameters: {
        'previous_phase': previousPhase.value,
        'new_phase': phase.value,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🧪 Beta phase changed to: ${phase.value}');
    }
  }

  /// Add beta tester
  Future<void> addBetaTester(BetaTester tester) async {
    if (!_isInitialized) return;

    _testers.add(tester);
    await _saveBetaTesters();

    await _analytics.logEvent(
      'beta_tester_added',
      parameters: {
        'tester_id': tester.id,
        'tester_email': tester.email,
        'phase': tester.phase.value,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🧪 Beta tester added: ${tester.email}');
    }
  }

  /// Submit beta feedback
  Future<void> submitFeedback(BetaFeedback feedback) async {
    if (!_isInitialized) return;

    _feedback.add(feedback);
    await _saveBetaFeedback();

    await _analytics.logEvent(
      'beta_feedback_submitted',
      parameters: {
        'feedback_id': feedback.id,
        'tester_id': feedback.testerId,
        'category': feedback.category,
        'priority': feedback.priority,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('🧪 Beta feedback submitted: ${feedback.title}');
    }
  }

  /// Complete checklist item
  Future<void> completeChecklistItem(String itemId) async {
    if (!_isInitialized) return;

    final index = _checklist.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      throw Exception('Checklist item not found: $itemId');
    }

    _checklist[index] = _checklist[index].copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    await _saveReleaseChecklist();

    await _analytics.logEvent(
      'checklist_item_completed',
      parameters: {
        'item_id': itemId,
        'item_title': _checklist[index].title,
        'category': _checklist[index].category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (kDebugMode) {
      print('✅ Checklist item completed: ${_checklist[index].title}');
    }
  }

  /// Get release readiness score
  double getReleaseReadinessScore() {
    if (_checklist.isEmpty) return 0.0;

    final requiredItems = _checklist.where((item) => item.isRequired).length;
    final completedRequired = _checklist
        .where((item) => item.isRequired && item.isCompleted)
        .length;

    final optionalItems = _checklist.where((item) => !item.isRequired).length;
    final completedOptional = _checklist
        .where((item) => !item.isRequired && item.isCompleted)
        .length;

    // Required items weight 80%, optional items weight 20%
    final requiredScore = requiredItems > 0 ? (completedRequired / requiredItems) * 0.8 : 0.8;
    final optionalScore = optionalItems > 0 ? (completedOptional / optionalItems) * 0.2 : 0.2;

    return (requiredScore + optionalScore) * 100;
  }

  /// Check if ready for production release
  bool isReadyForProduction() {
    final requiredItems = _checklist.where((item) => item.isRequired);
    return requiredItems.every((item) => item.isCompleted);
  }

  /// Generate release report
  Map<String, dynamic> generateReleaseReport() {
    final readinessScore = getReleaseReadinessScore();
    final isReady = isReadyForProduction();

    final feedbackByCategory = <String, List<BetaFeedback>>{};
    for (final feedback in _feedback) {
      feedbackByCategory.putIfAbsent(feedback.category, () => []).add(feedback);
    }

    final checklistByCategory = <String, List<ReleaseChecklistItem>>{};
    for (final item in _checklist) {
      checklistByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return {
      'release_readiness': {
        'score_percentage': readinessScore,
        'is_ready_for_production': isReady,
        'current_beta_phase': _currentPhase.value,
      },
      'beta_testing': {
        'total_testers': _testers.length,
        'active_testers': _testers.where((t) => t.isActive).length,
        'testers_by_phase': _getTestersByPhase(),
        'feedback_count': _feedback.length,
        'feedback_by_category': feedbackByCategory.map(
          (key, value) => MapEntry(key, value.length),
        ),
      },
      'checklist': {
        'total_items': _checklist.length,
        'completed_items': _checklist.where((item) => item.isCompleted).length,
        'required_items': _checklist.where((item) => item.isRequired).length,
        'completed_required': _checklist
            .where((item) => item.isRequired && item.isCompleted)
            .length,
        'by_category': checklistByCategory.map(
          (key, items) => MapEntry(key, {
            'total': items.length,
            'completed': items.where((item) => item.isCompleted).length,
          }),
        ),
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Export beta testing data
  Future<Map<String, dynamic>> exportBetaData() async {
    return {
      'beta_phase': _currentPhase.value,
      'testers': _testers.map((t) => t.toJson()).toList(),
      'feedback': _feedback.map((f) => f.toJson()).toList(),
      'checklist': _checklist.map((c) => c.toJson()).toList(),
      'release_report': generateReleaseReport(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get current beta phase
  BetaPhase getCurrentPhase() => _currentPhase;

  /// Get beta testers
  List<BetaTester> getBetaTesters() => List.unmodifiable(_testers);

  /// Get beta feedback
  List<BetaFeedback> getBetaFeedback() => List.unmodifiable(_feedback);

  /// Get release checklist
  List<ReleaseChecklistItem> getReleaseChecklist() => List.unmodifiable(_checklist);

  // ===== PRIVATE METHODS =====

  Map<String, int> _getTestersByPhase() {
    final result = <String, int>{};
    for (final phase in BetaPhase.values) {
      result[phase.value] = _testers.where((t) => t.phase == phase).length;
    }
    return result;
  }

  Future<void> _loadBetaData() async {
    try {
      // Load beta phase
      final phaseResult = await _localStorage.get<String>(key: _phaseKey);
      await phaseResult.fold(
        (failure) async {
          // Use default phase
        },
        (data) async {
          if (data != null) {
            _currentPhase = BetaPhase.values.firstWhere(
              (p) => p.value == data,
              orElse: () => BetaPhase.closedBeta,
            );
          }
        },
      );

      // Load testers
      final testersResult = await _localStorage.get<String>(key: _testersKey);
      await testersResult.fold(
        (failure) async {
          // No saved testers
        },
        (data) async {
          if (data != null) {
            final List<dynamic> testersList = jsonDecode(data) as List;
            _testers.addAll(
              testersList.map((json) => BetaTester.fromJson(json as Map<String, dynamic>)),
            );
          }
        },
      );

      // Load feedback
      final feedbackResult = await _localStorage.get<String>(key: _feedbackKey);
      await feedbackResult.fold(
        (failure) async {
          // No saved feedback
        },
        (data) async {
          if (data != null) {
            final List<dynamic> feedbackList = jsonDecode(data) as List;
            _feedback.addAll(
              feedbackList.map((json) => BetaFeedback.fromJson(json as Map<String, dynamic>)),
            );
          }
        },
      );

      // Load checklist
      final checklistResult = await _localStorage.get<String>(key: _checklistKey);
      await checklistResult.fold(
        (failure) async {
          // Use default checklist
        },
        (data) async {
          if (data != null) {
            final List<dynamic> checklistList = jsonDecode(data) as List;
            final savedItems = checklistList.map(
              (json) => ReleaseChecklistItem.fromJson(json as Map<String, dynamic>),
            ).toList();

            // Update checklist with saved completion status
            for (var i = 0; i < _checklist.length; i++) {
              final savedItem = savedItems.firstWhere(
                (item) => item.id == _checklist[i].id,
                orElse: () => _checklist[i],
              );
              _checklist[i] = savedItem;
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load beta data: $e');
      }
    }
  }

  Future<void> _saveBetaPhase() async {
    try {
      await _localStorage.save<String>(
        key: _phaseKey,
        data: _currentPhase.value,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save beta phase: $e');
      }
    }
  }

  Future<void> _saveBetaTesters() async {
    try {
      await _localStorage.save<String>(
        key: _testersKey,
        data: jsonEncode(_testers.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save beta testers: $e');
      }
    }
  }

  Future<void> _saveBetaFeedback() async {
    try {
      await _localStorage.save<String>(
        key: _feedbackKey,
        data: jsonEncode(_feedback.map((f) => f.toJson()).toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save beta feedback: $e');
      }
    }
  }

  Future<void> _saveReleaseChecklist() async {
    try {
      await _localStorage.save<String>(
        key: _checklistKey,
        data: jsonEncode(_checklist.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save release checklist: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _testers.clear();
    _feedback.clear();
    _checklist.clear();
    _isInitialized = false;
  }
}