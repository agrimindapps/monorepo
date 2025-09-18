import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Widget responsável pela exibição e seleção de planos de subscription para Plantis
/// 
/// Funcionalidades:
/// - Exibir opções de planos baseadas nos produtos disponíveis
/// - Seleção visual com estado
/// - Badges para destacar melhor valor
/// - Design visual consistente com tema do Plantis
/// 
/// Design:
/// - Cards com seleção por radio button
/// - Destaque visual para plano selecionado
/// - Badge "MELHOR VALOR" para plano anual
/// - Cores do gradiente verde do Plantis
class PlantisSubscriptionPlansWidget extends StatefulWidget {
  final List<ProductInfo> availableProducts;
  final String? selectedPlanId;
  final Function(String) onPlanSelected;

  const PlantisSubscriptionPlansWidget({
    super.key,
    required this.availableProducts,
    this.selectedPlanId,
    required this.onPlanSelected,
  });

  @override
  State<PlantisSubscriptionPlansWidget> createState() => _PlantisSubscriptionPlansWidgetState();
}

class _PlantisSubscriptionPlansWidgetState extends State<PlantisSubscriptionPlansWidget> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.selectedPlanId;
    
    // Se não há plano selecionado e existem produtos, seleciona o primeiro (geralmente anual)
    if (_selectedPlanId == null && widget.availableProducts.isNotEmpty) {
      // Prioriza plano anual se disponível
      final yearlyPlan = widget.availableProducts.firstWhere(
        (product) => product.productId.toLowerCase().contains('year') || 
                    product.productId.toLowerCase().contains('annual'),
        orElse: () => widget.availableProducts.first,
      );
      _selectedPlanId = yearlyPlan.productId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPlanSelected(_selectedPlanId!);
      });
    }
  }

  @override
  void didUpdateWidget(PlantisSubscriptionPlansWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlanId != oldWidget.selectedPlanId) {
      _selectedPlanId = widget.selectedPlanId;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: widget.availableProducts.map((product) => 
        _buildPlanOption(product)
      ).toList(),
    );
  }

  /// Constrói um card de opção de plano
  Widget _buildPlanOption(ProductInfo product) {
    final isSelected = _selectedPlanId == product.productId;
    final isYearly = product.productId.toLowerCase().contains('year') || 
                    product.productId.toLowerCase().contains('annual');
    final isMonthly = product.productId.toLowerCase().contains('month');
    final isWeekly = product.productId.toLowerCase().contains('week');
    
    String planTitle;
    String planSubtitle = '';
    String? badge;
    
    if (isYearly) {
      planTitle = 'Anual';
      planSubtitle = 'Economize 20%';
      badge = 'MELHOR VALOR';
    } else if (isMonthly) {
      planTitle = 'Mensal';
    } else if (isWeekly) {
      planTitle = 'Semanal';
    } else {
      planTitle = product.title;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildPlanCard(
        product: product,
        title: planTitle,
        subtitle: planSubtitle,
        badge: badge,
        isSelected: isSelected,
      ),
    );
  }

  /// Constrói o card do plano
  Widget _buildPlanCard({
    required ProductInfo product,
    required String title,
    String subtitle = '',
    String? badge,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected 
            ? PlantisColors.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)
            : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Stack(
        children: [
          // Badge "MELHOR VALOR" se aplicável
          if (badge != null)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PlantisColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Conteúdo principal do card
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPlanId = product.productId;
                });
                widget.onPlanSelected(product.productId);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildRadioButton(isSelected),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPlanTitle(title, subtitle),
                          const SizedBox(height: 4),
                          _buildPlanPrice(product),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          color: isSelected ? PlantisColors.primary : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: PlantisColors.primary,
                ),
              ),
            )
          : null,
    );
  }

  /// Constrói o título do plano
  Widget _buildPlanTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: PlantisColors.primary.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Constrói o preço do plano
  Widget _buildPlanPrice(ProductInfo product) {
    final isYearly = product.productId.toLowerCase().contains('year') || 
                    product.productId.toLowerCase().contains('annual');
    final isMonthly = product.productId.toLowerCase().contains('month');
    final isWeekly = product.productId.toLowerCase().contains('week');
    
    String period;
    if (isYearly) {
      period = '/ano';
    } else if (isMonthly) {
      period = '/mês';
    } else if (isWeekly) {
      period = '/semana';
    } else {
      period = '';
    }

    return Row(
      children: [
        Text(
          product.priceString,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (period.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            period,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}