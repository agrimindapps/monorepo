import 'diagnostico_details_model.dart';
import 'loading_state.dart';
import 'diagnostic_data.dart';

/// Comprehensive state model for diagnostic details page
/// Following Single Responsibility Principle (SOLID)
class DetalheDiagnosticoState {
  final DiagnosticoDetailsModel? diagnostico;
  final DiagnosticData? diagnosticData;
  final LoadingStateManager loadingManager;
  final bool isDark;
  final bool isPremiumUser;
  final bool isFavorite;
  final bool isTtsEnabled;
  final bool isTtsSpeaking;
  final String? error;
  final DateTime? lastUpdated;
  final Map<String, dynamic> cache;
  final Set<String> expandedSections;
  final String? searchQuery;
  final List<String> selectedTags;

  DetalheDiagnosticoState({
    this.diagnostico,
    this.diagnosticData,
    LoadingStateManager? loadingManager,
    this.isDark = false,
    this.isPremiumUser = false,
    this.isFavorite = false,
    this.isTtsEnabled = false,
    this.isTtsSpeaking = false,
    this.error,
    this.lastUpdated,
    Map<String, dynamic>? cache,
    Set<String>? expandedSections,
    this.searchQuery,
    List<String>? selectedTags,
  }) : loadingManager = loadingManager ?? LoadingStateManager(),
       cache = cache ?? const {},
       expandedSections = expandedSections ?? const {},
       selectedTags = selectedTags ?? const [];

  /// Convenience getters for loading states
  LoadingState get mainLoadingState => loadingManager.getState('main');
  LoadingState get favoriteLoadingState => loadingManager.getState('favorite');
  LoadingState get ttsLoadingState => loadingManager.getState('tts');
  LoadingState get dataLoadingState => loadingManager.getState('data');

  /// Check if page has data
  bool get hasData => diagnostico != null;

  /// Check if page is loading
  bool get isLoading => mainLoadingState.isLoading;

  /// Check if page has error
  bool get hasError => error != null || mainLoadingState.hasError;

  /// Check if any operation is processing
  bool get isProcessing => loadingManager.hasLoadingOperations;

  /// Check if diagnostic is premium content
  bool get isPremiumContent => diagnostico?.isPremium ?? false;

  /// Check if user has access to content
  bool get hasAccessToContent => !isPremiumContent || isPremiumUser;

  /// Check if specific section is expanded
  bool isSectionExpanded(String sectionId) {
    return expandedSections.contains(sectionId);
  }

  /// Get filtered diagnostic steps based on search
  List<DiagnosticStep> get filteredSteps {
    if (diagnostico == null) return [];
    if (searchQuery == null || searchQuery!.isEmpty) return diagnostico!.etapas;
    
    return diagnostico!.etapas.where((step) {
      return step.titulo.toLowerCase().contains(searchQuery!.toLowerCase()) ||
             step.descricao.toLowerCase().contains(searchQuery!.toLowerCase());
    }).toList();
  }

  /// Get filtered tags
  List<String> get filteredTags {
    if (diagnostico == null) return [];
    if (selectedTags.isEmpty) return diagnostico!.tags;
    
    return diagnostico!.tags.where((tag) => selectedTags.contains(tag)).toList();
  }

  /// Create copy with modifications
  DetalheDiagnosticoState copyWith({
    DiagnosticoDetailsModel? diagnostico,
    DiagnosticData? diagnosticData,
    LoadingStateManager? loadingManager,
    bool? isDark,
    bool? isPremiumUser,
    bool? isFavorite,
    bool? isTtsEnabled,
    bool? isTtsSpeaking,
    String? error,
    DateTime? lastUpdated,
    Map<String, dynamic>? cache,
    Set<String>? expandedSections,
    String? searchQuery,
    List<String>? selectedTags,
  }) {
    return DetalheDiagnosticoState(
      diagnostico: diagnostico ?? this.diagnostico,
      diagnosticData: diagnosticData ?? this.diagnosticData,
      loadingManager: loadingManager ?? this.loadingManager,
      isDark: isDark ?? this.isDark,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      isFavorite: isFavorite ?? this.isFavorite,
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
      isTtsSpeaking: isTtsSpeaking ?? this.isTtsSpeaking,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cache: cache ?? this.cache,
      expandedSections: expandedSections ?? this.expandedSections,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  /// Clear error state
  DetalheDiagnosticoState clearError() {
    return copyWith(error: null);
  }

  /// Toggle section expansion
  DetalheDiagnosticoState toggleSection(String sectionId) {
    final newExpanded = Set<String>.from(expandedSections);
    if (newExpanded.contains(sectionId)) {
      newExpanded.remove(sectionId);
    } else {
      newExpanded.add(sectionId);
    }
    return copyWith(expandedSections: newExpanded);
  }

  /// Add to cache
  DetalheDiagnosticoState addToCache(String key, dynamic value) {
    final newCache = Map<String, dynamic>.from(cache);
    newCache[key] = value;
    return copyWith(cache: newCache);
  }

  /// Remove from cache
  DetalheDiagnosticoState removeFromCache(String key) {
    final newCache = Map<String, dynamic>.from(cache);
    newCache.remove(key);
    return copyWith(cache: newCache);
  }

  /// Clear cache
  DetalheDiagnosticoState clearCache() {
    return copyWith(cache: {});
  }

  /// Update loading state for specific operation
  DetalheDiagnosticoState updateLoadingState(String operation, LoadingState state) {
    final newManager = LoadingStateManager();
    // Copy existing states
    for (final entry in loadingManager.states.entries) {
      newManager.setState(entry.key, entry.value);
    }
    // Set new state
    newManager.setState(operation, state);
    return copyWith(loadingManager: newManager);
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'diagnostico': diagnostico?.toJson(),
      'diagnosticData': diagnosticData?.toJson(),
      'isDark': isDark,
      'isPremiumUser': isPremiumUser,
      'isFavorite': isFavorite,
      'isTtsEnabled': isTtsEnabled,
      'isTtsSpeaking': isTtsSpeaking,
      'error': error,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'cache': cache,
      'expandedSections': expandedSections.toList(),
      'searchQuery': searchQuery,
      'selectedTags': selectedTags,
    };
  }

  /// Create from JSON
  factory DetalheDiagnosticoState.fromJson(Map<String, dynamic> json) {
    return DetalheDiagnosticoState(
      diagnostico: json['diagnostico'] != null
          ? DiagnosticoDetailsModel.fromJson(json['diagnostico'] as Map<String, dynamic>)
          : null,
      diagnosticData: json['diagnosticData'] != null
          ? DiagnosticData.fromJson(json['diagnosticData'] as Map<String, dynamic>)
          : null,
      isDark: json['isDark'] as bool? ?? false,
      isPremiumUser: json['isPremiumUser'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isTtsEnabled: json['isTtsEnabled'] as bool? ?? false,
      isTtsSpeaking: json['isTtsSpeaking'] as bool? ?? false,
      error: json['error'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      cache: Map<String, dynamic>.from(json['cache'] as Map? ?? {}),
      expandedSections: Set<String>.from(json['expandedSections'] as List? ?? []),
      searchQuery: json['searchQuery'] as String?,
      selectedTags: List<String>.from(json['selectedTags'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetalheDiagnosticoState &&
        other.diagnostico == diagnostico &&
        other.isDark == isDark &&
        other.isPremiumUser == isPremiumUser &&
        other.isFavorite == isFavorite &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      diagnostico,
      isDark,
      isPremiumUser,
      isFavorite,
      error,
    );
  }

  @override
  String toString() {
    return 'DetalheDiagnosticoState(hasData: $hasData, isLoading: $isLoading, hasError: $hasError)';
  }
}