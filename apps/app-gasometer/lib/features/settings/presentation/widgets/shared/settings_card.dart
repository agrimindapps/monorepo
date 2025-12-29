import 'package:flutter/material.dart';

/// Componente card reutilizável para seções de configurações
/// Fornece um container decorado com header padrão
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            ..._buildChildrenWithDividers(context),
          ],
        ),
      ),
    );
  }

  /// Constrói o header com ícone e título
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Constrói children com dividers entre items
  /// (exceto antes do primeiro e depois do último)
  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final List<Widget> result = [];

    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);

      // Adicionar divider entre items (não após o último)
      if (i < children.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        );
      }
    }

    return result;
  }
}
