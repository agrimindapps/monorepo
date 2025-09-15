import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';
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
    final semanticLabel = 'Abastecimento $vehicleName em ${_formatDate(record.data)}, ${record.litros.toStringAsFixed(1)} litros, R\$ ${record.valorTotal.toStringAsFixed(2)}${record.tanqueCheio ? ', tanque cheio' : ''}';

    return Semantics(
      label: semanticLabel,
      hint: 'Toque para ver detalhes completos, mantenha pressionado para editar ou excluir',
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: StandardListItemCard.fuel(
          date: record.data,
          fuelType: record.tipoCombustivel.displayName,
          liters: record.litros,
          amount: record.valorTotal,
          odometer: record.odometro,
          location: record.nomePosto,
          fullTank: record.tanqueCheio,
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