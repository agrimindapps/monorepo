import 'package:flutter/material.dart';

import '../../../../shared/widgets/design_system/base/standard_list_item_card.dart';
import '../../domain/entities/fuel_record_entity.dart';

/// Reusable fuel record card widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying a fuel record
/// Follows OCP: Open for extension via callback functions
class FuelRecordCard extends StatelessWidget {
  const FuelRecordCard({
    super.key,
    required this.record,
    required this.vehicleName,
    this.onTap,
    this.onLongPress,
  });

  final FuelRecordEntity record;
  final String vehicleName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = 'Abastecimento $vehicleName em ${_formatDate(record.date)}, ${record.liters.toStringAsFixed(1)} litros, R\$ ${record.totalPrice.toStringAsFixed(2)}${record.fullTank ? ', tanque cheio' : ''}';

    return Semantics(
      label: semanticLabel,
      hint: 'Toque para ver detalhes completos, mantenha pressionado para editar ou excluir',
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: StandardListItemCard.fuel(
          date: record.date,
          fuelType: record.fuelType.displayName,
          liters: record.liters,
          amount: record.totalPrice,
          odometer: record.odometer,
          location: record.gasStationName,
          fullTank: record.fullTank,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}