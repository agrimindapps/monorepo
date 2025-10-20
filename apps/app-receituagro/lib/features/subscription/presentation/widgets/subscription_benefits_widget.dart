import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/receituagro_colors.dart';
import '../providers/subscription_notifier.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium
///
/// VERSÃO REFATORADA - UX/UI Melhorado:
/// - Versão colapsável para economizar espaço
/// - Dois estilos: moderno (marketing) e colapsável (subscription ativa)
///
/// Funcionalidades:
/// - Listar recursos premium disponíveis
/// - Card colapsável para usuários ativos (economiza espaço)
/// - Estilo moderno para conversão
/// - Icons de check customizados
class SubscriptionBenefitsWidget extends ConsumerStatefulWidget {
  final bool showModernStyle;

  const SubscriptionBenefitsWidget({
    super.key,
    this.showModernStyle = false,
  });

  @override
  ConsumerState<SubscriptionBenefitsWidget> createState() =>
      _SubscriptionBenefitsWidgetState();
}

class _SubscriptionBenefitsWidgetState
    extends ConsumerState<SubscriptionBenefitsWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final subscriptionNotifier = ref.read(subscriptionNotifierProvider.notifier);

    return widget.showModernStyle
        ? _buildModernFeaturesList(subscriptionNotifier)
        : _buildCollapsibleCard(subscriptionNotifier);
  }

  /// Estilo moderno para marketing/conversão
  Widget _buildModernFeaturesList(SubscriptionNotifier notifier) {
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
          ...notifier.modernPremiumFeatures.map(
            (feature) => _buildModernFeatureItem(feature),
          ),
        ],
      ),
    );
  }

  /// Card colapsável para usuários ativos (NOVO - UX Melhorado)
  Widget _buildCollapsibleCard(SubscriptionNotifier notifier) {
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
              // Header sempre visível
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: ReceitaAgroColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
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

              // Lista expandível
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ...notifier.premiumFeatures.map(
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

  /// Item de recurso para estilo moderno
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

  /// Item de recurso para estilo card colapsável
  Widget _buildCardFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: ReceitaAgroColors.primary,
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
