// Refactored mobile page controller with proper lifecycle management
// Solves nested navigation issues and prevents memory leaks

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/navigation/enhanced_navigation_controller.dart';

/// Refactored mobile page controller following SRP
/// Responsibilities: APENAS coordenação entre UI e NavigationController
class MobilePageController extends GetxController {
  final EnhancedNavigationController _navigationController;
  
  // UI reactive state
  final RxInt _currentIndex = 0.obs;
  final RxBool _isInitialized = false.obs;
  
  // Navigation key for nested navigator
  GlobalKey<NavigatorState> get navigatorKey => _navigationController.navigatorKey;
  
  // UI getters
  int get currentIndex => _currentIndex.value;
  bool get isInitialized => _isInitialized.value;
  bool get canGoBack => _navigationController.canGoBack;
  String get currentRoute => _navigationController.currentRoute;
  
  MobilePageController({
    EnhancedNavigationController? navigationController,
  }) : _navigationController = navigationController ?? Get.find<EnhancedNavigationController>();

  @override
  void onInit() {
    super.onInit();
    _setupReactiveBindings();
    _initialize();
  }

  /// Initialize controller with proper lifecycle
  void _initialize() {
    try {
      // Sync UI state with navigation state
      _syncWithNavigationState();
      _isInitialized.value = true;
      
      debugPrint('MobilePageController initialized successfully');
      debugPrint('Current tab: ${_currentIndex.value}');
      debugPrint('Current route: ${_navigationController.currentRoute}');
    } catch (e) {
      debugPrint('MobilePageController initialization failed: $e');
      _isInitialized.value = false;
    }
  }

  /// Setup reactive bindings between UI and navigation state
  void _setupReactiveBindings() {
    // Listen to navigation state changes and update UI
    ever(_navigationController.state.obs, (NavigationState state) {
      if (_currentIndex.value != state.currentTabIndex) {
        _currentIndex.value = state.currentTabIndex;
        debugPrint('UI synced with navigation state: tab ${state.currentTabIndex}');
      }
    });
  }

  /// Change tab index with proper error handling
  Future<void> changeTabIndex(int index) async {
    if (!_isInitialized.value) {
      debugPrint('Cannot change tab: controller not initialized');
      return;
    }

    if (index == _currentIndex.value) {
      debugPrint('Already on tab $index, skipping navigation');
      return;
    }

    debugPrint('Attempting to change tab from ${_currentIndex.value} to $index');

    try {
      final success = await _navigationController.changeTab(index);
      if (success) {
        // State will be updated automatically via reactive binding
        debugPrint('Tab changed successfully to $index');
      } else {
        debugPrint('Tab change failed for index: $index');
        _showNavigationError('Não foi possível navegar para a aba solicitada');
      }
    } catch (e) {
      debugPrint('Tab change error: $e');
      _showNavigationError('Erro durante navegação');
    }
  }

  /// Navigate to specific route with arguments
  Future<void> navigateToRoute(String route, {dynamic arguments}) async {
    if (!_isInitialized.value) {
      debugPrint('Cannot navigate: controller not initialized');
      return;
    }

    try {
      final success = await _navigationController.navigateToRoute(
        route, 
        arguments: arguments,
      );
      
      if (!success) {
        debugPrint('Navigation failed for route: $route');
        _showNavigationError('Não foi possível navegar para a tela solicitada');
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      _showNavigationError('Erro durante navegação');
    }
  }

  /// Go back in navigation stack
  Future<void> goBack() async {
    if (!_isInitialized.value) {
      debugPrint('Cannot go back: controller not initialized');
      return;
    }

    if (!canGoBack) {
      debugPrint('Cannot go back: no history available');
      return;
    }

    try {
      final success = await _navigationController.goBack();
      if (!success) {
        debugPrint('Back navigation failed');
      }
    } catch (e) {
      debugPrint('Back navigation error: $e');
    }
  }

  /// Handle deep links
  Future<void> handleDeepLink(String route, {dynamic arguments}) async {
    if (!_isInitialized.value) {
      debugPrint('Cannot handle deep link: controller not initialized');
      return;
    }

    try {
      await _navigationController.handleDeepLink(route, arguments: arguments);
    } catch (e) {
      debugPrint('Deep link handling error: $e');
    }
  }

  /// Reset navigation to initial state
  void resetNavigation() {
    try {
      _navigationController.resetNavigation();
      _syncWithNavigationState();
      debugPrint('Navigation reset successfully');
    } catch (e) {
      debugPrint('Navigation reset error: $e');
    }
  }

  /// Get current navigation statistics for debugging
  Map<String, dynamic> getNavigationStats() {
    return _navigationController.getNavigationStats();
  }

  /// Force sync UI state with navigation state
  void _syncWithNavigationState() {
    _currentIndex.value = _navigationController.currentTabIndex;
  }

  /// Show user-friendly navigation error
  void _showNavigationError(String message) {
    try {
      Get.snackbar(
        'Erro de Navegação',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
      );
    } catch (e) {
      debugPrint('Failed to show error snackbar: $e');
    }
  }

  @override
  void onClose() {
    debugPrint('MobilePageController disposing resources');
    
    try {
      // Clean up any remaining resources
      _isInitialized.value = false;
    } catch (e) {
      debugPrint('Error during MobilePageController disposal: $e');
    }
    
    super.onClose();
  }
}