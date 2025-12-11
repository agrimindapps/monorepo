import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../core/theme/accessibility_tokens.dart';
import '../../core/theme/colors.dart';

/// Card acessível para plantas com semântica apropriada
class AccessiblePlantCard extends StatelessWidget {
  const AccessiblePlantCard({
    super.key,
    required this.plantName,
    required this.plantType,
    this.imageUrl,
    this.lastWatered,
    this.nextTask,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  final String plantName;
  final String plantType;
  final String? imageUrl;
  final DateTime? lastWatered;
  final String? nextTask;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWateredText = lastWatered != null
        ? 'Regada pela última vez há ${_daysSince(lastWatered!)} dias'
        : 'Sem registro de rega';

    final nextTaskText = nextTask != null
        ? 'Próxima tarefa: $nextTask'
        : 'Nenhuma tarefa pendente';

    return Semantics(
      label: 'Planta $plantName, tipo $plantType',
      hint:
          '$lastWateredText. $nextTaskText. Toque duas vezes para ver detalhes.',
      button: true,
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: isSelected ? 8 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  AccessibilityTokens.performHapticFeedback('light');
                  onTap!();
                }
              : null,
          onLongPress: onLongPress != null
              ? () {
                  AccessibilityTokens.performHapticFeedback('heavy');
                  onLongPress!();
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AccessibilityTokens.largeTouchTargetSize + 16,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPlantImage(context),
                const SizedBox(width: 16),
                Expanded(child: _buildPlantInfo(context)),
                _buildStatusIndicator(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantImage(BuildContext context) {
    return Semantics(
      label: imageUrl != null ? 'Foto da planta $plantName' : 'Planta sem foto',
      excludeSemantics: true,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: PlantisColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderIcon(),
                ),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(
      Icons.local_florist,
      size: 30,
      color: PlantisColors.primary,
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plantName,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          plantType,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (nextTask != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PlantisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              nextTask!,
              style: TextStyle(
                fontSize: AccessibilityTokens.getAccessibleFontSize(
                  context,
                  12,
                ),
                color: PlantisColors.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final daysSinceWatering = lastWatered != null
        ? _daysSince(lastWatered!)
        : 99;
    final isOverdue = daysSinceWatering > 7;
    final isWarning = daysSinceWatering > 3;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (isOverdue) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.warning;
      statusLabel = 'Rega atrasada';
    } else if (isWarning) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusLabel = 'Próxima da rega';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusLabel = 'Em dia';
    }

    return Semantics(
      label: 'Status da planta: $statusLabel',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(statusIcon, color: statusColor, size: 20),
      ),
    );
  }

  int _daysSince(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }
}

/// Barra de pesquisa acessível com semântica apropriada
class AccessibleSearchBar extends StatelessWidget {
  const AccessibleSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Pesquisar',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      textField: true,
      label: AccessibilityTokens.getSemanticLabel(
        'search_field',
        'Campo de pesquisa',
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
            ),
            prefixIcon: Semantics(
              label: 'Ícone de pesquisa',
              excludeSemantics: true,
              child: const Icon(Icons.search),
            ),
            suffixIcon: controller?.text.isNotEmpty == true
                ? Semantics(
                    label: 'Limpar pesquisa',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        AccessibilityTokens.performHapticFeedback('light');
                        controller?.clear();
                        onClear?.call();
                      },
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão de ação flutuante acessível
class AccessibleFAB extends StatelessWidget {
  const AccessibleFAB({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: tooltip ?? 'Toque duas vezes para $label',
      button: true,
      child: FloatingActionButton.extended(
        onPressed: () {
          AccessibilityTokens.performHapticFeedback('medium');
          onPressed();
        },
        label: Text(
          label,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(icon),
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        heroTag: heroTag,
      ),
    );
  }
}

/// Lista vazia acessível com semântica apropriada
class AccessibleEmptyState extends StatelessWidget {
  const AccessibleEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Estado vazio: $title. $description',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Ícone de estado vazio',
                excludeSemantics: true,
                child: Icon(
                  icon,
                  size: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: AccessibilityTokens.getAccessibleFontSize(
                    context,
                    20,
                  ),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: AccessibilityTokens.getAccessibleFontSize(
                    context,
                    16,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 24),
                AccessibleButton(
                  onPressed: onAction,
                  semanticLabel: actionText,
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// AppBar acessível com semântica apropriada
class AccessibleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccessibleAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Switch acessível com semântica apropriada
class AccessibleSwitch extends StatelessWidget {
  const AccessibleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
  });

  final bool value;
  final void Function(bool) onChanged;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: label,
      hint: subtitle,
      toggled: value,
      onTap: () {
        AccessibilityTokens.performHapticFeedback('selection');
        onChanged(!value);
      },
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AccessibilityTokens.getAccessibleFontSize(
                    context,
                    14,
                  ),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            AccessibilityTokens.performHapticFeedback('selection');
            onChanged(newValue);
            final message = newValue ? '$label ativado' : '$label desativado';
            SemanticsService.announce(message, TextDirection.ltr);
          },
        ),
        onTap: () {
          AccessibilityTokens.performHapticFeedback('selection');
          onChanged(!value);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minTileHeight: AccessibilityTokens.recommendedTouchTargetSize,
      ),
    );
  }
}

/// Dialog de confirmação acessível
class AccessibleConfirmDialog extends StatelessWidget {
  const AccessibleConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AccessibleConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      scopesRoute: true,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
            height: 1.4,
          ),
        ),
        actions: [
          AccessibleButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            semanticLabel: cancelText,
            child: Text(cancelText),
          ),
          AccessibleButton(
            onPressed: () {
              AccessibilityTokens.performHapticFeedback('medium');
              Navigator.of(context).pop(true);
            },
            semanticLabel: confirmText,
            backgroundColor: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            foregroundColor: isDestructive
                ? theme.colorScheme.onError
                : theme.colorScheme.onPrimary,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
