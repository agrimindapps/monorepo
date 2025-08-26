import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Widget padronizado para seções de conteúdo nas páginas home
/// 
/// Garante consistência visual entre diferentes páginas da aplicação,
/// com header de seção padronizado e card wrapper opcional.
class ContentSectionWidget extends StatelessWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final Widget child;
  final bool showCard;
  final bool isLoading;
  final Widget? emptyState;
  final String? emptyMessage;

  const ContentSectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.actionIcon,
    this.onActionPressed,
    this.showCard = true,
    this.isLoading = false,
    this.emptyState,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        _buildSectionHeader(theme),
        SizedBox(height: ReceitaAgroSpacing.sm),
        
        // Conteúdo da seção
        if (showCard)
          _buildCardContent(theme)
        else
          _buildDirectContent(),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: ReceitaAgroTypography.sectionTitle.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (actionIcon != null)
            IconButton(
              onPressed: onActionPressed,
              icon: Icon(
                actionIcon,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Card(
        elevation: ReceitaAgroElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(ReceitaAgroSpacing.md),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildDirectContent() {
    return _buildContent();
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(ReceitaAgroSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (emptyState != null) {
      return emptyState!;
    }

    if (emptyMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
          child: Text(
            emptyMessage!,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return child;
  }
}

/// Widget padronizado para items de lista nas seções de conteúdo
class ContentListItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? category;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const ContentListItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.category,
    this.icon,
    this.iconColor,
    this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(ReceitaAgroSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.md),
        ),
        child: Row(
          children: [
            // Leading widget ou ícone padrão
            leading ?? _buildDefaultIcon(theme),
            SizedBox(width: ReceitaAgroSpacing.md),
            
            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ReceitaAgroTypography.itemTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ReceitaAgroSpacing.xs),
                  Text(
                    subtitle,
                    style: ReceitaAgroTypography.itemSubtitle.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category != null) ...[
                    SizedBox(height: ReceitaAgroSpacing.xs),
                    _buildCategoryTag(theme),
                  ],
                ],
              ),
            ),
            
            // Trailing widget ou seta padrão
            trailing ?? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(ThemeData theme) {
    if (icon == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
      decoration: BoxDecoration(
        color: (iconColor ?? const Color(0xFF4CAF50)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.sm + 2),
      ),
      child: Icon(
        icon,
        color: iconColor ?? const Color(0xFF4CAF50),
        size: 20,
      ),
    );
  }

  Widget _buildCategoryTag(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.sm),
      ),
      child: Text(
        category!,
        style: ReceitaAgroTypography.itemCategory.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}