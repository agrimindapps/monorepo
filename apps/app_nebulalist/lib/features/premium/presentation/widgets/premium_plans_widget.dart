import 'package:flutter/material.dart';

/// Widget responsável pela exibição e seleção de planos de subscription para NebulaList
///
/// Funcionalidades:
/// - Exibir 3 opções de planos mockados
/// - Seleção visual com estado
/// - Badges para destacar melhor valor
/// - Design visual consistente com tema Deep Purple → Indigo
class PremiumPlansWidget extends StatefulWidget {
  final String? selectedPlanId;
  final void Function(String) onPlanSelected;

  const PremiumPlansWidget({
    super.key,
    this.selectedPlanId,
    required this.onPlanSelected,
  });

  @override
  State<PremiumPlansWidget> createState() => _PremiumPlansWidgetState();
}

class _PremiumPlansWidgetState extends State<PremiumPlansWidget> {
  String? _selectedPlanId;

  /// Planos mockados para NebulaList
  final List<Map<String, dynamic>> _mockPlans = [
    {
      'id': 'nebulalist_monthly',
      'title': 'Mensal',
      'subtitle': 'Acesso básico',
      'price': 'R\$ 9,99',
      'period': '/mês',
      'badge': null,
    },
    {
      'id': 'nebulalist_semester',
      'title': 'Semestral',
      'subtitle': 'Economize 17%',
      'price': 'R\$ 49,99',
      'period': '/6 meses',
      'badge': 'POPULAR',
    },
    {
      'id': 'nebulalist_annual',
      'title': 'Anual',
      'subtitle': 'Economize 25%',
      'price': 'R\$ 89,99',
      'period': '/ano',
      'badge': 'MELHOR VALOR',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.selectedPlanId ?? _mockPlans[1]['id'] as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPlanSelected(_selectedPlanId!);
    });
  }

  @override
  void didUpdateWidget(PremiumPlansWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlanId != oldWidget.selectedPlanId) {
      _selectedPlanId = widget.selectedPlanId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _mockPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _mockPlans.length - 1 ? 8 : 0,
              ),
              child: _buildPlanCard(plan),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Constrói o card do plano
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlanId == plan['id'];
    final badge = plan['badge'] as String?;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              )
            : Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
      ),
      child: Stack(
        children: [
          if (badge != null)
            Positioned(
              top: 0,
              right: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  badge,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPlanId = plan['id'] as String;
                });
                widget.onPlanSelected(_selectedPlanId!);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  badge != null ? 32 : 16,
                  12,
                  16,
                ),
                child: Column(
                  children: [
                    _buildRadioButton(isSelected),
                    const SizedBox(height: 12),
                    _buildPlanTitle(
                      plan['title'] as String,
                      plan['subtitle'] as String,
                    ),
                    const SizedBox(height: 8),
                    _buildPlanPrice(
                      plan['price'] as String,
                      plan['period'] as String,
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
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.4),
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
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  /// Constrói o título do plano
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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Constrói o preço do plano
  Widget _buildPlanPrice(String price, String period) {
    return Column(
      children: [
        Text(
          price,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (period.isNotEmpty)
          Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
