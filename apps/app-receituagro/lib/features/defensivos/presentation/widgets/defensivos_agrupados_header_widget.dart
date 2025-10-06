import 'package:flutter/material.dart';

import '../../../../core/widgets/modern_header_widget.dart';

/// Header especializado para Lista de Defensivos Agrupados
/// Wrapper do ModernHeaderWidget com lógica específica
class DefensivosAgrupadosHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final IconData rightIcon;
  final bool isDark;
  final bool showBackButton;
  final bool showActions;
  final bool canNavigateBack;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRightIconPressed;

  const DefensivosAgrupadosHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    required this.rightIcon,
    required this.isDark,
    required this.showBackButton,
    required this.showActions,
    required this.canNavigateBack,
    this.onBackPressed,
    this.onRightIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ModernHeaderWidget(
      title: title,
      subtitle: subtitle,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      isDark: isDark,
      showBackButton: showBackButton,
      showActions: showActions,
      onBackPressed: onBackPressed,
      onRightIconPressed: onRightIconPressed,
    );
  }
}
