import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/drill_down_navigation_state.dart';

/// Widget para navegação breadcrumb em drill-down
/// Permite navegação de volta aos grupos e mostra hierarquia
class DefensivosDrillDownNavigationWidget extends StatelessWidget {
  final DrillDownNavigationState navigationState;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRootPressed;

  const DefensivosDrillDownNavigationWidget({
    super.key,
    required this.navigationState,
    this.onBackPressed,
    this.onRootPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (navigationState.canGoBack) ...[
            InkWell(
              onTap: onBackPressed,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _buildBreadcrumbs(context),
          ),
          _buildLevelIndicator(context),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    final theme = Theme.of(context);
    final breadcrumbs = navigationState.breadcrumbs;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < breadcrumbs.length; i++) ...[
            if (i > 0) _buildBreadcrumbSeparator(theme),
            _buildBreadcrumbItem(
              context,
              breadcrumbs[i],
              isLast: i == breadcrumbs.length - 1,
              isFirst: i == 0,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    String text,
    {
      required bool isLast,
      required bool isFirst,
    }
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: isFirst && !isLast ? onRootPressed : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
            color: isLast
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBreadcrumbSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildLevelIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLevelColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getLevelIcon(),
            size: 12,
            color: _getLevelColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getLevelText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getLevelColor(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLevelIcon() {
    switch (navigationState.currentLevel) {
      case DrillDownLevel.groups:
        return FontAwesomeIcons.folderOpen;
      case DrillDownLevel.items:
        return FontAwesomeIcons.sprayCan;
    }
  }

  String _getLevelText() {
    switch (navigationState.currentLevel) {
      case DrillDownLevel.groups:
        return 'Grupos';
      case DrillDownLevel.items:
        return 'Itens';
    }
  }

  Color _getLevelColor() {
    switch (navigationState.currentLevel) {
      case DrillDownLevel.groups:
        return const Color(0xFF2196F3); // Azul para grupos
      case DrillDownLevel.items:
        return const Color(0xFF4CAF50); // Verde para itens
    }
  }
}

/// Widget compacto para navegação em contextos menores
class DefensivosDrillDownNavigationCompactWidget extends StatelessWidget {
  final DrillDownNavigationState navigationState;
  final VoidCallback? onBackPressed;

  const DefensivosDrillDownNavigationCompactWidget({
    super.key,
    required this.navigationState,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!navigationState.canGoBack) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          InkWell(
            onTap: onBackPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Voltar aos Grupos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de navegação para header de página
class DefensivosDrillDownHeaderNavigationWidget extends StatelessWidget {
  final DrillDownNavigationState navigationState;
  final VoidCallback? onBackPressed;

  const DefensivosDrillDownHeaderNavigationWidget({
    super.key,
    required this.navigationState,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!navigationState.canGoBack) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: onBackPressed,
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Voltar aos grupos',
    );
  }
}