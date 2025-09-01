import 'package:flutter/material.dart';

import '../providers/subscription_provider.dart';

/// Widget responsável pela exibição e seleção de planos de subscription
/// 
/// Funcionalidades:
/// - Exibir opções de planos (Mensal, Anual, Semanal)
/// - Seleção visual com estado
/// - Badges para destacar melhor valor
/// - Design visual consistente com tema da aplicação
/// 
/// Design:
/// - Cards com seleção por radio button
/// - Destaque visual para plano selecionado
/// - Badge "MELHOR VALOR" para plano anual
/// - Cores do gradiente da aplicação
class SubscriptionPlansWidget extends StatelessWidget {
  final SubscriptionProvider provider;

  const SubscriptionPlansWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPlanOption(
          title: 'Mensal',
          price: 'R\$10,99 / mês',
          planType: 'monthly',
          isSelected: provider.isPlanSelected('monthly'),
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          title: 'Anual',
          price: 'R\$100,99 / ano',
          planType: 'yearly',
          isSelected: provider.isPlanSelected('yearly'),
          badge: 'MELHOR VALOR',
        ),
        const SizedBox(height: 12),
        _buildPlanOption(
          title: 'Semanal',
          price: 'R\$4,99 / semana',
          planType: 'weekly',
          isSelected: provider.isPlanSelected('weekly'),
        ),
      ],
    );
  }

  /// Constrói um card de opção de plano
  Widget _buildPlanOption({
    required String title,
    required String price,
    required String planType,
    required bool isSelected,
    String? badge,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        onTap: () => provider.selectPlan(planType),
        leading: _buildRadioButton(isSelected),
        title: _buildPlanTitle(title, badge),
        subtitle: _buildPlanPrice(price),
      ),
    );
  }

  /// Constrói o radio button customizado
  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              color: Color(0xFF4A148C),
              size: 16,
            )
          : null,
    );
  }

  /// Constrói o título do plano com badge opcional
  Widget _buildPlanTitle(String title, String? badge) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 12),
          _buildBadge(badge),
        ],
      ],
    );
  }

  /// Constrói o badge destacado
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Constrói o preço do plano
  Widget _buildPlanPrice(String price) {
    return Text(
      price,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }
}