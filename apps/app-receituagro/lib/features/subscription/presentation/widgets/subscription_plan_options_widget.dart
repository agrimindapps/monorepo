import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';

/// Widget responsável por exibir as opções de planos disponíveis
///
/// Responsabilidades:
/// - Mostrar planos disponíveis (Mensal, Anual, Semanal)
/// - Permitir seleção de plano
/// - Destacar plano recomendado
/// - Mostrar preços e economias
/// - Estado responsivo a mudanças de seleção
class SubscriptionPlanOptionsWidget extends ConsumerWidget {
  const SubscriptionPlanOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final selectedPlan = subscriptionState.selectedPlan;

    return Column(
      children: [
        // Plano Mensal
        _buildPlanOption(
          context: context,
          ref: ref,
          title: 'Mensal',
          price: 'R\$ 10,99 / mês',
          planType: 'monthly',
          isSelected: selectedPlan == 'monthly',
        ),
        
        const SizedBox(height: 12),
        
        // Plano Anual (Recomendado)
        _buildPlanOption(
          context: context,
          ref: ref,
          title: 'Anual',
          price: 'R\$ 100,99 / ano',
          planType: 'yearly',
          isSelected: selectedPlan == 'yearly',
          badge: 'MELHOR VALOR',
          savingsText: 'Economize R\$ 30,89',
        ),
        
        const SizedBox(height: 12),
        
        // Plano Semanal
        _buildPlanOption(
          context: context,
          ref: ref,
          title: 'Semanal',
          price: 'R\$ 4,99 / semana',
          planType: 'weekly',
          isSelected: selectedPlan == 'weekly',
        ),
      ],
    );
  }

  /// Constrói uma opção de plano
  Widget _buildPlanOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String price,
    required String planType,
    required bool isSelected,
    String? badge,
    String? savingsText,
  }) {
    return GestureDetector(
      onTap: () => _selectPlan(ref, planType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange.shade400 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header do plano
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e preço
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge e indicador de seleção
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Radio button indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.orange.shade400 : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isSelected ? Colors.orange.shade400 : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            
            // Texto de economia se disponível
            if (savingsText != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  savingsText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Seleciona um plano
  void _selectPlan(WidgetRef ref, String planType) {
    ref.read(subscriptionProvider.notifier).selectPlan(planType);
  }
}