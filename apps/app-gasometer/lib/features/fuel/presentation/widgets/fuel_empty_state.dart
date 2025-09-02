import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';

/// Reusable fuel empty state widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying empty state for fuel records
/// Follows OCP: Open for extension via callback functions
class FuelEmptyState extends StatelessWidget {
  const FuelEmptyState({
    super.key,
    this.onAddRecord,
  });

  final VoidCallback? onAddRecord;

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      icon: Icons.local_gas_station_outlined,
      title: 'Nenhum abastecimento registrado',
      description: 'Registre seu primeiro abastecimento para começar a acompanhar seus gastos com combustível',
      actionLabel: 'Adicionar Abastecimento',
      onAction: onAddRecord,
    );
  }
}