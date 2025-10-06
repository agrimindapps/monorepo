import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Tab controller manager for Body Condition Calculator
/// 
/// Responsibilities:
/// - Handle tab navigation and state
/// - Coordinate tab changes with calculations
/// - Keep tab logic separate from main page
class BodyConditionTabController {
  final TabController tabController;
  final WidgetRef ref;
  
  BodyConditionTabController({
    required this.tabController,
    required this.ref,
  });

  /// Navigate to the input tab (index 0)
  void goToInputTab() {
    tabController.animateTo(0);
  }

  /// Navigate to the result tab (index 1) after calculation
  void goToResultTab() {
    tabController.animateTo(1);
  }

  /// Navigate to the history tab (index 2)
  void goToHistoryTab() {
    tabController.animateTo(2);
  }

  /// Get the current tab index
  int get currentTabIndex => tabController.index;

  /// Check if we're on the input tab
  bool get isInputTab => currentTabIndex == 0;

  /// Check if we're on the result tab
  bool get isResultTab => currentTabIndex == 1;

  /// Check if we're on the history tab
  bool get isHistoryTab => currentTabIndex == 2;

  /// Handle tab change events
  void onTabChanged(int index) {
  }

  /// Calculate and automatically move to result tab
  void calculateAndNavigateToResult() {
    goToResultTab();
  }

  /// Get tab bar widget configuration
  TabBar getTabBar() {
    return TabBar(
      controller: tabController,
      onTap: onTabChanged,
      tabs: const [
        Tab(icon: Icon(Icons.input), text: 'Entrada'),
        Tab(icon: Icon(Icons.analytics), text: 'Resultado'),
        Tab(icon: Icon(Icons.history), text: 'Histórico'),
      ],
    );
  }

  /// Get tab bar view widget configuration
  TabBarView getTabBarView({
    required Widget inputTab,
    required Widget resultTab,
    required Widget historyTab,
  }) {
    return TabBarView(
      controller: tabController,
      children: [
        inputTab,
        resultTab,
        historyTab,
      ],
    );
  }

  /// Dispose of resources (handled by parent widget)
  void dispose() {
  }
}
