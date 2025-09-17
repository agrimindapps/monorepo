import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../domain/entities/fuel_record_entity.dart';
import 'fuel_record_card.dart';

/// Reusable fuel records list widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying a list of fuel records
/// Follows OCP: Open for extension via callback functions
class FuelRecordsList extends StatelessWidget {
  const FuelRecordsList({
    super.key,
    required this.records,
    required this.getVehicleName,
    this.onRecordTap,
    this.onRecordLongPress,
  });

  final List<FuelRecordEntity> records;
  final String Function(String vehicleId) getVehicleName;
  final void Function(FuelRecordEntity record)? onRecordTap;
  final void Function(FuelRecordEntity record)? onRecordLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Histórico de Abastecimentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // ✅ Virtualized list for performance
        SizedBox(
          height: 400, // Fixed height for virtualization
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final vehicleName = getVehicleName(record.vehicleId);

              return FuelRecordCard(
                record: record,
                vehicleName: vehicleName,
                onTap: onRecordTap != null 
                    ? () => onRecordTap!(record)
                    : null,
                onLongPress: onRecordLongPress != null
                    ? () => onRecordLongPress!(record)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}