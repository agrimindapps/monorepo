import 'package:flutter/material.dart';

import '../../domain/entities/medication_dosage_output.dart';

/// Widget para exibir resultados do cálculo de dosagem de medicamentos
class MedicationDosageResultCard extends StatelessWidget {
  const MedicationDosageResultCard({
    super.key,
    required this.output,
  });

  final MedicationDosageOutput output;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDosageInfo(),
            const SizedBox(height: 12),
            _buildFrequencyInfo(),
            const SizedBox(height: 12),
            _buildAdministrationRoute(),
            if (output.volumeToAdminister != null) ...[
              const SizedBox(height: 12),
              _buildVolumeInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.medication,
          color: Colors.blue.shade600,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Resultado da Dosagem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dosagem Calculada',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${output.dosePerAdministration.toStringAsFixed(2)} ${output.unit}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dose diária total: ${output.totalDailyDose.toStringAsFixed(2)} ${output.unit}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            'Dosagem por kg: ${output.dosagePerKg.toStringAsFixed(2)} ${output.unit}/kg',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationRoute() {
    return _buildInfoRow(
      'Via de Administração',
      output.instructions.route,
      Icons.route,
    );
  }

  Widget _buildFrequencyInfo() {
    return _buildInfoRow(
      'Frequência',
      '${output.administrationsPerDay}x/dia (${output.intervalBetweenDoses})',
      Icons.schedule,
    );
  }

  Widget _buildVolumeInfo() {
    return _buildInfoRow(
      'Volume a Administrar',
      '${output.volumeToAdminister!.toStringAsFixed(2)} ml',
      Icons.science,
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
