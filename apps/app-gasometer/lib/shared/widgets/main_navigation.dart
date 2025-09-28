import 'package:flutter/material.dart';

import 'adaptive_main_navigation.dart';

/// Main navigation wrapper - provides adaptive navigation
/// Maintains compatibility while providing responsive behavior
class MainNavigation extends StatelessWidget {
  
  const MainNavigation({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdaptiveMainNavigation(child: child);
  }
}