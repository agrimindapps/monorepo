import 'package:flutter/material.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../providers/home_defensivos_provider.dart';

/// Header component for Defensivos home page.
/// 
/// Displays the title, subtitle based on provider state, and maintains
/// consistent styling across the application.
/// 
/// Performance: Lightweight component with minimal rebuilds.
class HomeDefensivosHeader extends StatelessWidget {
  const HomeDefensivosHeader({
    super.key,
    required this.provider,
    required this.isDark,
  });

  final HomeDefensivosProvider provider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ModernHeaderWidget(
      title: 'Defensivos',
      subtitle: provider.headerSubtitle,
      leftIcon: Icons.shield_outlined,
      showBackButton: false,
      showActions: false,
      isDark: isDark,
    );
  }
}