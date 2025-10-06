import 'package:flutter/material.dart';

/// Widget responsável por exibir os recursos premium disponíveis
///
/// Responsabilidades:
/// - Listar todos os recursos premium
/// - Mostrar ícones de check para cada recurso
/// - Design consistente com tema do app
/// - Lista otimizada para performance
class SubscriptionFeaturesCardWidget extends StatelessWidget {
  const SubscriptionFeaturesCardWidget({super.key});

  /// Lista de recursos premium
  static const List<String> _premiumFeatures = [
    'Acesso a todos os defensivos',
    'Pesquisa avançada de pragas',
    'Histórico completo de consultas',
    'Receitas detalhadas de aplicação',
    'Suporte técnico prioritário',
    'Atualizações automáticas da base',
    'Exportação de relatórios',
    'Modo offline completo',
    'Notificações personalizadas',
    'Análise de eficácia',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
            
            const SizedBox(height: 16),
            ..._premiumFeatures.map((feature) => _buildFeatureItem(feature)),
          ],
        ),
      ),
    );
  }

  /// Constrói um item da lista de recursos
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}