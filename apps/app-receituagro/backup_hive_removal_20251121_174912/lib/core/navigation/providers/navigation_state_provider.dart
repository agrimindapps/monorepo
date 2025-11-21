import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_state_provider.g.dart';

/// Provider para gerenciar estado global de navegação
@riverpod
class NavigationState extends _$NavigationState {
  @override
  NavigationStateData build() {
    return const NavigationStateData(
      selectedTabIndex: 0,
      showBottomNav: true,
    );
  }

  /// Seleciona uma tab do BottomNavigationBar
  void selectTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  /// Controla visibilidade do BottomNavigationBar
  void setBottomNavVisibility(bool visible) {
    state = state.copyWith(showBottomNav: visible);
  }
}

/// Estado de navegação imutável
class NavigationStateData {
  final int selectedTabIndex;
  final bool showBottomNav;

  const NavigationStateData({
    required this.selectedTabIndex,
    required this.showBottomNav,
  });

  NavigationStateData copyWith({
    int? selectedTabIndex,
    bool? showBottomNav,
  }) {
    return NavigationStateData(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      showBottomNav: showBottomNav ?? this.showBottomNav,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationStateData &&
          runtimeType == other.runtimeType &&
          selectedTabIndex == other.selectedTabIndex &&
          showBottomNav == other.showBottomNav;

  @override
  int get hashCode => Object.hash(selectedTabIndex, showBottomNav);
}
