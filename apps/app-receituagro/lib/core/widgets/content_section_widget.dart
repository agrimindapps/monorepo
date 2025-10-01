import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

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
  final bool isEmpty;

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
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        _buildSectionHeader(theme),
        const SizedBox(height: ReceitaAgroSpacing.sm),

        // Conteúdo da seção
        if (showCard) _buildCardContent(theme) else _buildDirectContent(),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ReceitaAgroSpacing.horizontalPadding,
      ),
      child: Row(
        children: [
          // Linha verde vertical como no mockup
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Título da seção
          Expanded(
            child: Text(
              title,
              style: ReceitaAgroTypography.sectionTitle.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),

          // Ícone de ação
          if (actionIcon != null)
            IconButton(
              onPressed: onActionPressed,
              icon: Icon(
                actionIcon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Card(
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
      ),
      color: theme.cardColor,
      clipBehavior:
          Clip.antiAlias, // Para que os dividers fiquem dentro do card
      child: _buildContent(),
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

    // Se está vazio e tem mensagem, mostra a mensagem
    if (isEmpty && emptyMessage != null) {
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
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : theme.colorScheme.surface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
            // Leading widget ou ícone padrão
            leading ?? _buildDefaultIcon(theme),
            const SizedBox(width: 12),

            // Conteúdo principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category != null && category!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildCategoryTag(theme),
                  ],
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.eco,
        color: const Color(0xFF4CAF50),
        size: 20,
      ),
    );
  }

  Widget _buildCategoryTag(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.label_outline,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            category!,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
