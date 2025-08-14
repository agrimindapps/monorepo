import 'package:flutter/material.dart';
import '../models/view_mode.dart';

class FavoritosUIStateService extends ChangeNotifier {
  int _currentTabIndex = 0;
  final List<ViewMode> _viewModes = [ViewMode.list, ViewMode.list, ViewMode.list];

  int get currentTabIndex => _currentTabIndex;
  ViewMode get currentViewMode => _viewModes[_currentTabIndex];
  
  ViewMode getViewModeForTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _viewModes.length) {
      return _viewModes[tabIndex];
    }
    return ViewMode.list;
  }

  void setCurrentTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < 3) {
      _currentTabIndex = tabIndex;
      notifyListeners();
    }
  }

  void toggleViewMode(ViewMode mode) {
    final currentIndex = _currentTabIndex;
    if (currentIndex >= 0 && currentIndex < _viewModes.length) {
      _viewModes[currentIndex] = mode;
      notifyListeners();
    }
  }

  void setViewModeForTab(int tabIndex, ViewMode mode) {
    if (tabIndex >= 0 && tabIndex < _viewModes.length) {
      _viewModes[tabIndex] = mode;
      notifyListeners();
    }
  }
}