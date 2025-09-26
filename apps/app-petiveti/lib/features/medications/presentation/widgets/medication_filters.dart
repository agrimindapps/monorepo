import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';

class MedicationFilters extends ConsumerWidget {
  const MedicationFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeFilter = ref.watch(medicationTypeFilterProvider);
    final statusFilter = ref.watch(medicationStatusFilterProvider);

    return Row(
      children: [
        // Type filter
        Expanded(
          child: DropdownButtonFormField<MedicationType?>(
            value: typeFilter,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<MedicationType?>(
                value: null,
                child: Text('Todos os tipos'),
              ),
              ...MedicationType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              )),
            ],
            onChanged: (value) {
              ref.read(medicationTypeFilterProvider.notifier).state = value;
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Status filter
        Expanded(
          child: DropdownButtonFormField<MedicationStatus?>(
            value: statusFilter,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<MedicationStatus?>(
                value: null,
                child: Text('Todos os status'),
              ),
              ...MedicationStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              )),
            ],
            onChanged: (value) {
              ref.read(medicationStatusFilterProvider.notifier).state = value;
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Clear filters button
        IconButton(
          onPressed: () {
            ref.read(medicationTypeFilterProvider.notifier).state = null;
            ref.read(medicationStatusFilterProvider.notifier).state = null;
            ref.read(medicationSearchQueryProvider.notifier).state = '';
          },
          icon: const Icon(Icons.clear),
          tooltip: 'Limpar filtros',
        ),
      ],
    );
  }
}