import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'adaptive_main_navigation.dart';

/// Main navigation wrapper - provides adaptive navigation
/// Maintains compatibility while providing responsive behavior
class MainNavigation extends StatelessWidget {
  
  const MainNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMainNavigation(navigationShell: navigationShell);
  }
}
