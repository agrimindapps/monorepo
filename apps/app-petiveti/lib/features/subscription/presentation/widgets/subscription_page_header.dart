import 'package:flutter/material.dart';

/// Widget responsible for displaying subscription page header with marketing content
class SubscriptionPageHeader extends StatelessWidget {
  const SubscriptionPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(context),
        const SizedBox(height: 16),
        _buildTitle(context),
        const SizedBox(height: 8),
        _buildSubtitle(context),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Icon(
      Icons.star,
      size: 64,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Desbloqueie Todo o Potencial',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Acesse todas as funcionalidades premium e cuide melhor dos seus pets',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      textAlign: TextAlign.center,
    );
  }
}
