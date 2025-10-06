import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_controller_notifier.g.dart';

/// Tab Controller state
class TabControllerState {
  final int selectedTabIndex;
  final int tabLength;

  const TabControllerState({
    required this.selectedTabIndex,
    required this.tabLength,
  });

  factory TabControllerState.initial() {
    return const TabControllerState(
      selectedTabIndex: 0,
      tabLength: 4,
    );
  }

  TabControllerState copyWith({
    int? selectedTabIndex,
    int? tabLength,
  }) {
    return TabControllerState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      tabLength: tabLength ?? this.tabLength,
    );
  }

  /// Dados das tabs com ícones e textos
  List<Map<String, dynamic>> get tabData => [
        {'icon': Icons.info_outlined, 'text': 'Informações'},
        {'icon': Icons.search_outlined, 'text': 'Diagnóstico'},
        {'icon': Icons.settings_outlined, 'text': 'Tecnologia'},
        {'icon': Icons.comment_outlined, 'text': 'Comentários'},
      ];
}

/// Notifier para gerenciar estado das tabs (Presentation Layer)
/// Responsabilidade única: controle de navegação entre tabs
@riverpod
class TabControllerNotifier extends _$TabControllerNotifier {
  TabController? _tabController;

  @override
  Future<TabControllerState> build() async {
    return TabControllerState.initial();
  }

  /// Inicializa o TabController
  void initializeTabController(TickerProvider vsync) {
    _tabController?.dispose();
    _tabController = TabController(length: 4, vsync: vsync);
    _tabController!.addListener(_onTabChanged);
    ref.onDispose(() {
      _tabController?.removeListener(_onTabChanged);
      _tabController?.dispose();
      _tabController = null;
    });
  }

  /// Handler para mudança de tab
  void _onTabChanged() {
    final currentState = state.value;
    if (currentState == null) return;

    if (_tabController != null && _tabController!.index != currentState.selectedTabIndex) {
      state = AsyncValue.data(
        currentState.copyWith(selectedTabIndex: _tabController!.index),
      );
    }
  }

  /// Navega para uma tab específica
  void goToTab(int index) {
    final currentState = state.value;
    if (currentState == null) return;

    if (_tabController != null && index >= 0 && index < _tabController!.length) {
      _tabController!.animateTo(index);
    }
  }

  /// Reset do provider
  void reset() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedTabIndex: 0));

    if (_tabController != null) {
      _tabController!.animateTo(0);
    }
  }

  /// Getter para o TabController (null-safe)
  TabController? get tabController => _tabController;

  /// Getter para o índice selecionado
  int get selectedTabIndex {
    final currentState = state.value;
    return currentState?.selectedTabIndex ?? 0;
  }

  /// Getter para os dados das tabs
  List<Map<String, dynamic>> get tabData {
    final currentState = state.value;
    return currentState?.tabData ?? [];
  }
}
