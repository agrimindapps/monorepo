import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

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
  final void Function(String) onPlanSelected;

  const PlantisSubscriptionPlansWidget({
    super.key,
    required this.availableProducts,
    this.selectedPlanId,
    required this.onPlanSelected,
  });

  @override
  State<PlantisSubscriptionPlansWidget> createState() =>
      _PlantisSubscriptionPlansWidgetState();
}

class _PlantisSubscriptionPlansWidgetState
    extends State<PlantisSubscriptionPlansWidget> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.selectedPlanId;
    if (_selectedPlanId == null && widget.availableProducts.isNotEmpty) {
      final yearlyPlan = widget.availableProducts.firstWhere(
        (product) =>
            product.productId.toLowerCase().contains('year') ||
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
    final products =
        widget.availableProducts.isEmpty
            ? _getMockProducts()
            : widget.availableProducts;

    // Sort products to have Annual in the middle or highlighted
    // For vertical list, we usually want: Monthly, Annual (Hero), Semestral
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
            products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPlanOption(product),
              );
            }).toList(),
      ),
    );
  }

  /// Mock products for development/testing
  List<ProductInfo> _getMockProducts() {
    return [
      const ProductInfo(
        productId: 'plantis_premium_monthly',
        title: 'Plantis Premium Mensal',
        description: 'Plano mensal básico',
        price: 1.99,
        priceString: 'R\$ 1,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'mensal',
      ),
      const ProductInfo(
        productId: 'plantis_premium_semester',
        title: 'Plantis Premium Semestral',
        description: 'Plano semestral com desconto',
        price: 9.99,
        priceString: 'R\$ 9,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'semestral',
      ),
      const ProductInfo(
        productId: 'plantis_premium_annual',
        title: 'Plantis Premium Anual',
        description: 'Plano anual - melhor valor',
        price: 17.99,
        priceString: 'R\$ 17,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'anual',
      ),
    ];
  }

  /// Constrói um card de opção de plano
  Widget _buildPlanOption(ProductInfo product) {
    final isSelected = _selectedPlanId == product.productId;
    final isYearly =
        product.productId.toLowerCase().contains('year') ||
        product.productId.toLowerCase().contains('annual');
    final isMonthly = product.productId.toLowerCase().contains('month');
    final isSemester = product.productId.toLowerCase().contains('semester');
    final isWeekly = product.productId.toLowerCase().contains('week');

    String planTitle;
    String planSubtitle = '';
    String? badge;

    if (isYearly) {
      planTitle = 'Anual';
      planSubtitle = 'Economize 67%';
      badge = 'MELHOR VALOR';
    } else if (isSemester) {
      planTitle = 'Semestral';
      planSubtitle = 'Economize 17%';
    } else if (isMonthly) {
      planTitle = 'Mensal';
      planSubtitle = 'Acesso básico';
    } else if (isWeekly) {
      planTitle = 'Semanal';
    } else {
      planTitle = product.title;
    }

    return _buildPlanCard(
      product: product,
      title: planTitle,
      subtitle: planSubtitle,
      badge: badge,
      isSelected: isSelected,
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
    final isHero = badge != null; // Annual plan is hero
    
    // Dynamic colors based on selection and hero status
    final borderColor = isSelected
        ? (isHero ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.6)) // Gold for hero
        : Colors.white.withValues(alpha: 0.1);
        
    final backgroundColor = isSelected
        ? (isHero ? const Color(0x33FFD700) : PlantisColors.primary.withValues(alpha: 0.15)) // Gold tint for hero
        : Colors.white.withValues(alpha: 0.05);

    return Transform.scale(
      scale: isSelected && isHero ? 1.02 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && isHero
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (badge != null)
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700), // Gold
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
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
                      _buildRadioButton(isSelected, isHero),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (subtitle.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHero 
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : PlantisColors.primary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      subtitle,
                                      style: TextStyle(
                                        color: isHero ? const Color(0xFFFFD700) : PlantisColors.primaryLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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
      ),
    );
  }

  /// Constrói o radio button customizado
  Widget _buildRadioButton(bool isSelected, bool isHero) {
    final activeColor = isHero ? const Color(0xFFFFD700) : PlantisColors.primary;
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isSelected
                  ? activeColor
                  : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child:
          isSelected
              ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                ),
              )
              : null,
    );
  }

  /// Constrói o título do plano (Legacy - não usado no novo layout vertical)
  Widget _buildPlanTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PlantisColors.primary.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Constrói o preço do plano
  Widget _buildPlanPrice(ProductInfo product) {
    final isYearly =
        product.productId.toLowerCase().contains('year') ||
        product.productId.toLowerCase().contains('annual');
    final isMonthly = product.productId.toLowerCase().contains('month');
    final isSemester = product.productId.toLowerCase().contains('semester');
    final isWeekly = product.productId.toLowerCase().contains('week');

    String period;
    if (isYearly) {
      period = '/ano';
    } else if (isSemester) {
      period = '/sem';
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
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (period.isNotEmpty)
          Text(
            period,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
