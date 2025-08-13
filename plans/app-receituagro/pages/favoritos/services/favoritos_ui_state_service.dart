// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/view_mode.dart';

/// Service responsible for UI state management
/// Follows Single Responsibility Principle by handling only UI state operations
/// Simplified without TabController for better performance
class FavoritosUIStateService extends GetxController {
  // =========================================================================
  // Constants
  // =========================================================================
  static const _tabTitles = ['Defensivos', 'Pragas', 'Diagnóstico'];

  // =========================================================================
  // Observable State
  // =========================================================================
  final _viewModes = {
    0: ViewMode.list,
    1: ViewMode.list,
    2: ViewMode.list,
  }.obs;
  final _currentViewMode = ViewMode.list.obs;
  final _currentTabIndex = 0.obs;

  // =========================================================================
  // Getters
  // =========================================================================
  ViewMode get currentViewMode => _currentViewMode.value;
  int get currentTabIndex => _currentTabIndex.value;
  List<String> get tabTitles => _tabTitles;

  @override
  void onInit() {
    super.onInit();
    _updateCurrentViewMode();
  }



  // =========================================================================
  // View Mode Methods
  // =========================================================================

  /// Toggle view mode for current tab
  void toggleViewMode(ViewMode mode) {
    try {
      final currentTab = _currentTabIndex.value;
      _viewModes[currentTab] = mode;
      _updateCurrentViewMode();
      debugPrint('🎯 FavoritosUIStateService: View mode da aba $currentTab mudou para $mode');
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  /// Get view mode for specific tab
  ViewMode getViewModeForTab(int tabIndex) {
    return _viewModes[tabIndex] ?? ViewMode.list;
  }

  /// Set view mode for specific tab
  void setViewModeForTab(int tabIndex, ViewMode mode) {
    try {
      _viewModes[tabIndex] = mode;
      if (tabIndex == _currentTabIndex.value) {
        _updateCurrentViewMode();
      }
      debugPrint('🎯 FavoritosUIStateService: View mode da aba $tabIndex definido como $mode');
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  void _updateCurrentViewMode() {
    try {
      _currentViewMode.value = _viewModes[_currentTabIndex.value] ?? ViewMode.list;
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  // =========================================================================
  // Tab Navigation Methods
  // =========================================================================

  /// Navigate to specific tab
  void navigateToTab(int index) {
    try {
      if (index >= 0 && index < _tabTitles.length) {
        _currentTabIndex.value = index;
        _updateCurrentViewMode();
      } else {
        debugPrint('⚠️ FavoritosUIStateService: Índice de aba inválido: $index');
      }
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  /// Get current tab title
  String getCurrentTabTitle() {
    final index = _currentTabIndex.value;
    if (index >= 0 && index < _tabTitles.length) {
      return _tabTitles[index];
    }
    return _tabTitles[0];
  }

  // =========================================================================
  // Responsive UI Methods
  // =========================================================================

  /// Calculate cross axis count for grid based on screen width
  int getCrossAxisCount(BuildContext context) {
    try {
      final width = MediaQuery.of(context).size.width;
      if (width > 1200) return 3;
      if (width > 800) return 2;
      return 1;
    } catch (e) {
      return 1; // Fallback
    }
  }

  /// Check if screen is considered large
  bool isLargeScreen(BuildContext context) {
    try {
      return MediaQuery.of(context).size.width > 800;
    } catch (e) {
      return false;
    }
  }

  /// Get optimal item height for list items
  double getOptimalItemHeight(BuildContext context) {
    try {
      final screenHeight = MediaQuery.of(context).size.height;
      if (screenHeight > 800) return 120.0;
      if (screenHeight > 600) return 100.0;
      return 80.0;
    } catch (e) {
      return 100.0; // Fallback
    }
  }

  // =========================================================================
  // State Reset Methods
  // =========================================================================

  /// Reset all view modes to default
  void resetViewModes() {
    try {
      _viewModes.value = {
        0: ViewMode.list,
        1: ViewMode.list,
        2: ViewMode.list,
      };
      _updateCurrentViewMode();
      debugPrint('✅ FavoritosUIStateService: View modes resetados');
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  /// Reset to first tab
  void resetToFirstTab() {
    try {
      navigateToTab(0);
    } catch (e) {
      // Error updating UI state - continue with current state
    }
  }

  /// Get current tab index for external widgets
  int getCurrentTabIndex() {
    return _currentTabIndex.value;
  }

  /// Set tab index programmatically
  void setCurrentTabIndex(int index) {
    navigateToTab(index);
  }
}
