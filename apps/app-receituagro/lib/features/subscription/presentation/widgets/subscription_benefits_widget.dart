import 'package:flutter/material.dart';

import '../providers/subscription_provider.dart';

/// Widget responsável pela exibição dos benefícios/recursos premium
/// 
/// Funcionalidades:
/// - Listar recursos premium disponíveis
/// - Dois estilos: moderno (marketing) e card (subscription ativa)
/// - Icons de check customizados
/// - Integração com provider para lista de recursos
/// 
/// Estilos:
/// - Modern: Para marketing/conversão (fundo transparente)
/// - Card: Para usuários ativos (background card)
class SubscriptionBenefitsWidget extends StatelessWidget {
  final SubscriptionProvider provider;
  final bool showModernStyle;

  const SubscriptionBenefitsWidget({
    super.key,
    required this.provider,
    this.showModernStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return showModernStyle 
        ? _buildModernFeaturesList()
        : _buildCardFeaturesList();
  }

  /// Estilo moderno para marketing/conversão
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
          ...provider.modernPremiumFeatures.map((feature) => _buildModernFeatureItem(feature)),
        ],
      ),
    );
  }

  /// Estilo card para usuários com subscription ativa
  Widget _buildCardFeaturesList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos Premium:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.premiumFeatures.map((feature) => _buildCardFeatureItem(feature)),
          ],
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
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Item de recurso para estilo card
  Widget _buildCardFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),  // App brand green
            size: 20,
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