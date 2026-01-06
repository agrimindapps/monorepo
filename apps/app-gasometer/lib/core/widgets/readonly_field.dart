import 'package:flutter/material.dart';

/// Widget que exibe um campo em modo somente leitura
/// 
/// Usado para exibir dados em modo de visualização do CRUD
/// com visual consistente e suporte a diferentes tipos de dados.
///
/// Exemplo:
/// ```dart
/// ReadOnlyField(
///   label: 'Tipo de Combustível',
///   value: 'Gasolina',
///   icon: Icons.local_gas_station,
/// )
/// ```
class ReadOnlyField extends StatelessWidget {
  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.suffix,
    this.isHighlighted = false,
    this.highlightColor,
    this.textStyle,
    this.onTap,
  });

  /// Rótulo do campo
  final String label;

  /// Valor a ser exibido
  final String value;

  /// Ícone opcional à esquerda
  final IconData? icon;

  /// Widget opcional à direita (ex: unidade, badge)
  final Widget? suffix;

  /// Se o campo deve ser destacado
  final bool isHighlighted;

  /// Cor de destaque personalizada
  final Color? highlightColor;

  /// Estilo de texto personalizado para o valor
  final TextStyle? textStyle;

  /// Callback ao tocar no campo (para campos clicáveis)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveHighlightColor = highlightColor ?? colorScheme.primary;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? effectiveHighlightColor.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(
                color: effectiveHighlightColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: isHighlighted
                  ? effectiveHighlightColor
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: textStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: value.isEmpty
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          if (suffix != null) suffix!,
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return content;
  }
}

/// Versão do campo para valores monetários
class ReadOnlyMoneyField extends StatelessWidget {
  const ReadOnlyMoneyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isHighlighted = false,
  });

  final String label;
  final double value;
  final IconData? icon;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReadOnlyField(
      label: label,
      value: 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
      icon: icon ?? Icons.attach_money,
      isHighlighted: isHighlighted,
      highlightColor: Colors.green,
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

/// Versão do campo para valores numéricos com unidade
class ReadOnlyNumberField extends StatelessWidget {
  const ReadOnlyNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.decimals = 2,
    this.isHighlighted = false,
  });

  final String label;
  final double value;
  final String unit;
  final IconData? icon;
  final int decimals;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReadOnlyField(
      label: label,
      value: value.toStringAsFixed(decimals).replaceAll('.', ','),
      icon: icon,
      isHighlighted: isHighlighted,
      suffix: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Versão do campo para datas
class ReadOnlyDateField extends StatelessWidget {
  const ReadOnlyDateField({
    super.key,
    required this.label,
    required this.value,
    this.showTime = true,
    this.icon,
    this.isHighlighted = false,
  });

  final String label;
  final DateTime value;
  final bool showTime;
  final IconData? icon;
  final bool isHighlighted;

  String _formatDate() {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;

    if (showTime) {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '$day/$month/$year às $hour:$minute';
    }

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return ReadOnlyField(
      label: label,
      value: _formatDate(),
      icon: icon ?? Icons.calendar_today,
      isHighlighted: isHighlighted,
    );
  }
}

/// Versão do campo para booleanos (switch visual)
class ReadOnlyBoolField extends StatelessWidget {
  const ReadOnlyBoolField({
    super.key,
    required this.label,
    required this.value,
    this.trueLabel = 'Sim',
    this.falseLabel = 'Não',
    this.icon,
  });

  final String label;
  final bool value;
  final String trueLabel;
  final String falseLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {

    return ReadOnlyField(
      label: label,
      value: value ? trueLabel : falseLabel,
      icon: icon,
      suffix: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: value
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: value ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              value ? trueLabel : falseLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? Colors.green.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Container para agrupar campos readonly em seções
class ReadOnlyFieldSection extends StatelessWidget {
  const ReadOnlyFieldSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.spacing = 12,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children.expand(
          (child) => [child, SizedBox(height: spacing)],
        ).take(children.length * 2 - 1),
      ],
    );
  }
}

/// Layout de dois campos lado a lado em modo readonly
class ReadOnlyFieldRow extends StatelessWidget {
  const ReadOnlyFieldRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((child) => [
                Expanded(child: child),
                SizedBox(width: spacing),
              ])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}
