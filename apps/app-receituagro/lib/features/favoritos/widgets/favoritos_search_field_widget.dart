import 'package:flutter/material.dart';
import '../constants/favoritos_design_tokens.dart';
import '../models/view_mode.dart';

class FavoritosSearchFieldWidget extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final Color accentColor;
  final ViewMode selectedViewMode;
  final ValueChanged<ViewMode>? onToggleViewMode;

  const FavoritosSearchFieldWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.controller,
    required this.accentColor,
    required this.selectedViewMode,
    this.onToggleViewMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText ?? 'Buscar...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: accentColor,
                  ),
                  suffixIcon: controller?.text.isNotEmpty == true
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClear,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (onToggleViewMode != null) ...[
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(FavoritosDesignTokens.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewModeButton(
                    context,
                    ViewMode.list,
                    Icons.view_list,
                  ),
                  _buildViewModeButton(
                    context,
                    ViewMode.grid,
                    Icons.grid_view,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    ViewMode mode,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedViewMode == mode;

    return Material(
      color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onToggleViewMode?.call(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? accentColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}