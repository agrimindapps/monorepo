/// Stub for BetaTestingService - removed service
/// This stub provides the same interface for compatibility
class BetaTestingService {
  static final BetaTestingService _instance = BetaTestingService._();
  static BetaTestingService get instance => _instance;
  
  BetaTestingService._();
  
  static bool get isInBeta => false;
  static String get currentPhase => 'production';
  
  static Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  
  static Future<bool> checkBetaStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return false;
  }
  
  static void recordBetaEvent(String event, Map<String, dynamic> data) {
  }
  
  static Future<Map<String, dynamic>> getBetaConfig() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return {};
  }
  Future<List<ReleaseChecklistItem>> getReleaseChecklist() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [];
  }
  
  Future<double> getReleaseReadinessScore() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 1.0; // 100% ready (stub)
  }
  
  Future<bool> isReadyForProduction() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true; // Always ready in stub
  }
  
  Future<Map<String, dynamic>> generateReleaseReport() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return {};
  }
  
  Future<void> completeChecklistItem(String itemId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  
  Future<Map<String, dynamic>> exportBetaData() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return {};
  }
  
  BetaPhase getCurrentPhase() {
    return BetaPhase.production;
  }
  
  Future<List<Map<String, dynamic>>> getBetaTesters() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [];
  }
  
  Future<List<Map<String, dynamic>>> getBetaFeedback() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [];
  }
  
  Future<void> setBetaPhase(BetaPhase phase) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// Stub enum for BetaPhase - removed from original service
enum BetaPhase {
  alpha,
  beta,
  production;
  
  String get value {
    switch (this) {
      case BetaPhase.alpha:
        return 'alpha';
      case BetaPhase.beta:
        return 'beta';
      case BetaPhase.production:
        return 'production';
    }
  }
}

/// Stub class for ReleaseChecklistItem - removed from original service  
class ReleaseChecklistItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isRequired;
  final bool isCompleted;
  final DateTime? completedAt;
  
  const ReleaseChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isRequired = false,
    this.isCompleted = false,
    this.completedAt,
  });
  
  ReleaseChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isRequired,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ReleaseChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
