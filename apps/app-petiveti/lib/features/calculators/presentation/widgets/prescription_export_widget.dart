import 'package:flutter/material.dart';

import '../../domain/entities/medication_dosage_input.dart';
import '../../domain/entities/medication_dosage_output.dart';

/// Widget para exportar prescrição de medicamento
class PrescriptionExportWidget extends StatelessWidget {
  const PrescriptionExportWidget({
    super.key,
    required this.output,
    required this.input,
    required this.scrollController,
  });

  final MedicationDosageOutput output;
  final MedicationDosageInput input;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildPrescriptionHeader(),
                const SizedBox(height: 24),
                _buildPatientInfo(),
                const SizedBox(height: 24),
                _buildMedicationInfo(),
                const SizedBox(height: 24),
                _buildDosageInstructions(),
                const SizedBox(height: 24),
                _buildAdministrationInstructions(),
                if (output.monitoringInfo != null) ...[
                  const SizedBox(height: 24),
                  _buildMonitoringInstructions(),
                ],
                if (output.alerts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSafetyAlerts(),
                ],
                const SizedBox(height: 32),
                _buildExportButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_information,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Prescrição Veterinária',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRESCRIÇÃO VETERINÁRIA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${_formatDate(output.calculatedAt ?? DateTime.now())}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INFORMAÇÕES DO PACIENTE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Espécie:', input.species.displayName),
            _buildInfoRow('Peso:', '${input.weight} kg'),
            _buildInfoRow('Grupo de Idade:', input.ageGroup.displayName),
            if (input.specialConditions.isNotEmpty)
              _buildInfoRow('Condições Especiais:', 
                input.specialConditions.map((c) => c.displayName).join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEDICAMENTO PRESCRITO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Medicamento:', output.medicationName),
            _buildInfoRow('ID do Medicamento:', input.medicationId),
            if (input.concentration != null)
              _buildInfoRow('Concentração:', '${input.concentration} mg/ml'),
            if (input.pharmaceuticalForm != null)
              _buildInfoRow('Forma Farmacêutica:', input.pharmaceuticalForm!),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POSOLOGIA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${output.dosePerAdministration.toStringAsFixed(2)} ${output.unit}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (output.volumeToAdminister != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Volume: ${output.volumeToAdminister!.toStringAsFixed(2)} ml',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Frequência:', '${output.administrationsPerDay}x ao dia'),
            _buildInfoRow('Intervalo:', output.intervalBetweenDoses),
            _buildInfoRow('Dose diária total:', '${output.totalDailyDose.toStringAsFixed(2)} ${output.unit}'),
            _buildInfoRow('Dosagem por kg:', '${output.dosagePerKg.toStringAsFixed(2)} ${output.unit}/kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdministrationInstructions() {
    final instructions = output.instructions;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INSTRUÇÕES DE ADMINISTRAÇÃO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Via de administração:', instructions.route),
            _buildInfoRow('Horário:', instructions.timing),
            if (instructions.dilution != null)
              _buildInfoRow('Diluição:', instructions.dilution!),
            if (instructions.storage != null)
              _buildInfoRow('Armazenamento:', instructions.storage!),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringInstructions() {
    final monitoring = output.monitoringInfo!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MONITORAMENTO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Frequência:', monitoring.frequency),
            _buildInfoRow('Duração:', monitoring.duration),
            const SizedBox(height: 8),
            Text(
              'Parâmetros a monitorar:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            ...monitoring.parametersToMonitor.map(
              (param) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $param'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyAlerts() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ALERTAS DE SEGURANÇA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...output.alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getAlertColor(alert.level),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${alert.type.displayName}: ${alert.message}',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _exportToPDF(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Exportar como PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareText(),
                icon: const Icon(Icons.share),
                label: const Text('Compartilhar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard(),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getAlertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.safe:
        return Colors.green;
      case AlertLevel.caution:
        return Colors.yellow.shade700;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.danger:
        return Colors.red;
    }
  }

  void _exportToPDF() {
    debugPrint('Exportar para PDF');
  }

  void _shareText() {
    debugPrint('Compartilhar prescrição');
  }

  void _copyToClipboard() {
    debugPrint('Copiar para clipboard');
  }
}