import 'package:core/core.dart';

import '../providers/animals_provider.dart';

/// Coordinator for managing Animals page business logic
/// 
/// Responsibilities:
/// - Coordinate data loading
/// - Manage page initialization
/// - Handle lifecycle events
/// - Separate business logic from UI
class AnimalsPageCoordinator {
  final WidgetRef ref;
  bool _isInitialized = false;

  AnimalsPageCoordinator({required this.ref});

  /// Initialize the page with data loading
  Future<void> initializePage() async {
    if (_isInitialized) return;
    
    await loadAnimals();
    _isInitialized = true;
  }

  /// Load animals data
  Future<void> loadAnimals() async {
    try {
      await ref.read(animalsProvider.notifier).loadAnimals();
    } catch (e) {
      // Error will be handled by the error handler component
      rethrow;
    }
  }

  /// Refresh animals data
  Future<void> refreshAnimals() async {
    await loadAnimals();
  }

  /// Clear any cached data or reset state if needed
  void dispose() {
    _isInitialized = false;
  }

  /// Check if page is initialized
  bool get isInitialized => _isInitialized;
}