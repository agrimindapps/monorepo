import 'package:flutter/material.dart';

import '../../domain/entities/vaccine.dart';

/// Widget responsible for basic vaccine information form following SRP
/// 
/// Single responsibility: Handle vaccine basic information input
class VaccineBasicInfoForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController veterinarianController;
  final TextEditingController batchController;
  final TextEditingController manufacturerController;
  final TextEditingController dosageController;
  final TextEditingController notesController;
  final VaccineStatus status;
  final bool isRequired;
  final ValueChanged<VaccineStatus> onStatusChanged;
  final ValueChanged<bool> onRequiredChanged;

  const VaccineBasicInfoForm({
    super.key,
    required this.nameController,
    required this.veterinarianController,
    required this.batchController,
    required this.manufacturerController,
    required this.dosageController,
    required this.notesController,
    required this.status,
    required this.isRequired,
    required this.onStatusChanged,
    required this.onRequiredChanged,
  });

  @override
  State<VaccineBasicInfoForm> createState() => _VaccineBasicInfoFormState();
}

class _VaccineBasicInfoFormState extends State<VaccineBasicInfoForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildVaccineNameField(theme),
          const SizedBox(height: 16),
          _buildVeterinarianField(theme),
          const SizedBox(height: 16),
          _buildManufacturerAndBatch(theme),
          const SizedBox(height: 16),
          _buildDosageField(theme),
          const SizedBox(height: 16),
          _buildStatusAndRequired(theme),
          const SizedBox(height: 16),
          _buildNotesField(theme),
        ],
      ),
    );
  }

  Widget _buildVaccineNameField(ThemeData theme) {
    return TextFormField(
      controller: widget.nameController,
      decoration: InputDecoration(
        labelText: 'Nome da Vacina *',
        hintText: 'Ex: V8, V10, Antirrábica...',
        prefixIcon: const Icon(Icons.vaccines),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Nome da vacina é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildVeterinarianField(ThemeData theme) {
    return TextFormField(
      controller: widget.veterinarianController,
      decoration: InputDecoration(
        labelText: 'Veterinário',
        hintText: 'Nome do veterinário responsável',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildManufacturerAndBatch(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: widget.manufacturerController,
            decoration: InputDecoration(
              labelText: 'Fabricante',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: widget.batchController,
            decoration: InputDecoration(
              labelText: 'Lote',
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageField(ThemeData theme) {
    return TextFormField(
      controller: widget.dosageController,
      decoration: InputDecoration(
        labelText: 'Dosagem',
        hintText: 'Ex: 1ml subcutânea',
        prefixIcon: const Icon(Icons.colorize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildStatusAndRequired(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusSelector(theme),
            const SizedBox(height: 12),
            _buildRequiredToggle(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status da Vacina',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<VaccineStatus>(
          initialValue: widget.status,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: VaccineStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusName(status)),
                ],
              ),
            );
          }).toList(),
          onChanged: (status) {
            if (status != null) {
              widget.onStatusChanged(status);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRequiredToggle(ThemeData theme) {
    return SwitchListTile.adaptive(
      title: const Text('Vacina Obrigatória'),
      subtitle: const Text('Vacinas obrigatórias têm prioridade nos lembretes'),
      value: widget.isRequired,
      onChanged: widget.onRequiredChanged,
      activeThumbColor: theme.colorScheme.primary,
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    return TextFormField(
      controller: widget.notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Observações',
        hintText: 'Reações, instruções especiais...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  IconData _getStatusIcon(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return Icons.schedule;
      case VaccineStatus.applied:
        return Icons.check_circle;
      case VaccineStatus.overdue:
        return Icons.warning;
      case VaccineStatus.completed:
        return Icons.done_all;
      case VaccineStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return Colors.blue;
      case VaccineStatus.applied:
        return Colors.green;
      case VaccineStatus.overdue:
        return Colors.orange;
      case VaccineStatus.completed:
        return Colors.teal;
      case VaccineStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusName(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return 'Agendada';
      case VaccineStatus.applied:
        return 'Aplicada';
      case VaccineStatus.overdue:
        return 'Atrasada';
      case VaccineStatus.completed:
        return 'Completa';
      case VaccineStatus.cancelled:
        return 'Cancelada';
    }
  }
}
