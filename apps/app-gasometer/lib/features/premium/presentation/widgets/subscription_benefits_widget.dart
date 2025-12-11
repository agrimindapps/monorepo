import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionBenefitsWidget extends ConsumerStatefulWidget {
  const SubscriptionBenefitsWidget({
    super.key,
    this.showModernStyle = false,
  });

  final bool showModernStyle;

  @override
  ConsumerState<SubscriptionBenefitsWidget> createState() =>
      _SubscriptionBenefitsWidgetState();
}

class _SubscriptionBenefitsWidgetState
    extends ConsumerState<SubscriptionBenefitsWidget> {
  bool _isExpanded = true;

  final List<String> _features = [
    'Veículos Ilimitados',
    'Relatórios Avançados',
    'Sincronização em Nuvem',
    'Análises Inteligentes',
    'Alertas Personalizados',
    'Exportação de Dados',
    'Suporte Prioritário',
    'Backup Automático',
  ];

  final List<String> _modernFeatures = [
    'Veículos Ilimitados',
    'Relatórios Avançados',
    'Sincronização em Nuvem',
    'Análises Inteligentes',
  ];

  @override
  Widget build(BuildContext context) {
    return widget.showModernStyle
        ? _buildModernFeaturesList()
        : _buildCollapsibleCard();
  }

  Widget _buildModernFeaturesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que está incluído',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ..._modernFeatures.map(
            (feature) => _buildModernFeatureItem(feature),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Color(0xFF2196F3), // Gasometer Primary
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recursos Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ..._features.map(
                  (feature) => _buildCardFeatureItem(feature),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Toque para ver todos os recursos',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF2196F3), // Gasometer Primary
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
