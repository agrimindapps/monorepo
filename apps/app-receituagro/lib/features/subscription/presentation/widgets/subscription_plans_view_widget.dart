import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_footer_links_widget.dart';
import 'subscription_header_widget.dart';
import 'subscription_plan_options_widget.dart';
import 'subscription_purchase_button_widget.dart';

/// Widget responsável pela view de seleção de planos
///
/// Responsabilidades:
/// - Mostrar opções de planos disponíveis
/// - Permitir seleção entre planos
/// - Exibir botão de compra
/// - Mostrar links do footer (termos, privacidade)
///
/// Estrutura:
/// - Header com título e ícone de fechar
/// - Título principal da oferta
/// - Opções de planos
/// - Lista de recursos
/// - Botão de compra
/// - Links do footer
class SubscriptionPlansViewWidget extends ConsumerWidget {
  const SubscriptionPlansViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Header com título principal
          const SubscriptionHeaderWidget(),
          
          const SizedBox(height: 40),
          
          // Opções de planos
          const SubscriptionPlanOptionsWidget(),
          
          const SizedBox(height: 30),
          
          // Lista de recursos premium
          _buildFeaturesList(),
          
          const Spacer(),
          
          // Botão de compra
          const SubscriptionPurchaseButtonWidget(),
          
          const SizedBox(height: 20),
          
          // Links do footer
          const SubscriptionFooterLinksWidget(),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Constrói a lista de recursos premium destacados
  Widget _buildFeaturesList() {
    const features = [
      'Acesso ilimitado a todos os defensivos',
      'Pesquisa avançada e filtros',
      'Histórico completo de consultas',
      'Receitas detalhadas de aplicação',
      'Modo offline completo',
    ];

    return Column(
      children: features.map((feature) => _buildFeatureItem(feature)).toList(),
    );
  }

  /// Constrói um item da lista de recursos
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade700,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}