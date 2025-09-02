import 'package:flutter/material.dart';

import 'adaptive_main_navigation.dart';

/// Legacy main navigation wrapper - now uses adaptive navigation
/// Maintains backward compatibility while providing responsive behavior
class MainNavigation extends StatelessWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AdaptiveMainNavigation(child: child);
  }
}