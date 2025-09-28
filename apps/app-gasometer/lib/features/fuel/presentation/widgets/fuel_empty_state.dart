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
    return const EnhancedEmptyState(
      icon: Icons.local_gas_station_outlined,
      title: 'Nenhum abastecimento registrado',
      description: 'Use o botão + para registrar seu primeiro abastecimento e acompanhar seus gastos com combustível',
    );
  }
}