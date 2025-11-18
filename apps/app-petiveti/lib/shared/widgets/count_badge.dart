import 'package:flutter/material.dart';

/// Badge to display count of filtered items
///
/// **SRP**: Única responsabilidade de mostrar badge de contagem
class CountBadge extends StatelessWidget {
  final int count;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  const CountBadge({
    super.key,
    required this.count,
    this.fontSize = 12.0,
    this.horizontalPadding = 8.0,
    this.verticalPadding = 2.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$count itens filtrados',
      hint: 'Número de itens que atendem aos filtros aplicados',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            fontSize: fontSize,
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
