import 'package:flutter/material.dart';

/// Widget responsible for displaying feature comparison between free and premium plans
class SubscriptionFeatureComparison extends StatelessWidget {
  const SubscriptionFeatureComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 16),
            _buildHeader(context),
            const Divider(height: 16),
            ..._buildFeatureRows(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Compare os Recursos',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: SizedBox(), // Empty space for feature names
        ),
        Expanded(
          child: Text(
            'Grátis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Premium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureRows(BuildContext context) {
    final features = [
      const _FeatureRow('Animais ilimitados', free: false, premium: true),
      const _FeatureRow('Todas as calculadoras', free: false, premium: true),
      const _FeatureRow('Controle de medicamentos', free: false, premium: true),
      const _FeatureRow('Lembretes avançados', free: false, premium: true),
      const _FeatureRow('Controle de despesas', free: false, premium: true),
      const _FeatureRow('Backup na nuvem', free: false, premium: true),
      const _FeatureRow('Relatórios detalhados', free: false, premium: true),
      const _FeatureRow('Suporte prioritário', free: false, premium: true),
    ];

    return features
        .map((feature) => _buildFeatureRow(context, feature))
        .toList();
  }

  Widget _buildFeatureRow(BuildContext context, _FeatureRow feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: _buildFeatureIcon(context, feature.free),
          ),
          Expanded(
            child: _buildFeatureIcon(context, feature.premium),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, bool available) {
    return Icon(
      available ? Icons.check_circle : Icons.cancel,
      color: available ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
      size: 20,
    );
  }
}

class _FeatureRow {
  final String name;
  final bool free;
  final bool premium;

  const _FeatureRow(this.name, {required this.free, required this.premium});
}
