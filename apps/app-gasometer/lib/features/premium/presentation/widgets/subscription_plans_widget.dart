import 'package:core/core.dart' show ProductInfo;
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

class SubscriptionPlansWidget extends StatefulWidget {

  const SubscriptionPlansWidget({
    super.key,
    required this.availableProducts,
    this.selectedPlanId,
    required this.onPlanSelected,
  });
  final List<ProductInfo> availableProducts;
  final String? selectedPlanId;
  final void Function(String) onPlanSelected;

  @override
  State<SubscriptionPlansWidget> createState() =>
      _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
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
  void didUpdateWidget(SubscriptionPlansWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlanId != oldWidget.selectedPlanId) {
      _selectedPlanId = widget.selectedPlanId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.availableProducts.isEmpty
        ? _getMockProducts()
        : widget.availableProducts;

    // Remove duplicates based on productId
    final uniqueProducts = <String, ProductInfo>{};
    for (final product in products) {
      uniqueProducts[product.productId] = product;
    }
    final productsList = uniqueProducts.values.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: productsList.map((product) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPlanOption(product),
          );
        }).toList(),
      ),
    );
  }

  List<ProductInfo> _getMockProducts() {
    return [
      const ProductInfo(
        productId: 'gasometer_premium_monthly',
        title: 'Mensal',
        description: 'Plano mensal básico',
        price: 4.99,
        priceString: 'R\$ 4,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'mensal',
      ),
      const ProductInfo(
        productId: 'gasometer_premium_semester',
        title: 'Semestral',
        description: 'Plano semestral com desconto',
        price: 24.99,
        priceString: 'R\$ 24,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'semestral',
      ),
      const ProductInfo(
        productId: 'gasometer_premium_annual',
        title: 'Anual',
        description: 'Plano anual - melhor valor',
        price: 39.99,
        priceString: 'R\$ 39,99',
        currencyCode: 'BRL',
        subscriptionPeriod: 'anual',
      ),
    ];
  }

  Widget _buildPlanOption(ProductInfo product) {
    final isSelected = _selectedPlanId == product.productId;
    final isYearly = product.productId.toLowerCase().contains('year') ||
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

  Widget _buildPlanCard({
    required ProductInfo product,
    required String title,
    String subtitle = '',
    String? badge,
    required bool isSelected,
  }) {
    final isHero = badge != null;

    final borderColor = isSelected
        ? (isHero
            ? const Color(0xFFFFD700)
            : Colors.white.withValues(alpha: 0.6))
        : Colors.white.withValues(alpha: 0.1);

    final backgroundColor = isSelected
        ? (isHero
            ? const Color(0x33FFD700)
            : GasometerDesignTokens.colorPrimary.withValues(
                alpha: 0.15,
              ))
        : Colors.white.withValues(alpha: 0.05);

    return Transform.scale(
      scale: isSelected && isHero ? 1.02 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected && isHero
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
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
                    color: const Color(0xFFFFD700),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHero
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : GasometerDesignTokens.colorPrimary
                                              .withValues(
                                              alpha: 0.2,
                                            ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      subtitle,
                                      style: TextStyle(
                                        color: isHero
                                            ? const Color(0xFFFFD700)
                                            : GasometerDesignTokens
                                                .colorPrimaryLight,
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

  Widget _buildRadioButton(bool isSelected, bool isHero) {
    final activeColor =
        isHero ? const Color(0xFFFFD700) : GasometerDesignTokens.colorPrimary;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        color: Colors.transparent,
      ),
      child: isSelected
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

  Widget _buildPlanPrice(ProductInfo product) {
    final isYearly = product.productId.toLowerCase().contains('year') ||
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
