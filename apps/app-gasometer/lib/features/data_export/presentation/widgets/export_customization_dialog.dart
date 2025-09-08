import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/export_request.dart';

/// Dialog para customização da exportação de dados LGPD
class ExportCustomizationDialog extends StatefulWidget {
  final String userId;
  final Function(ExportRequest) onStartExport;

  const ExportCustomizationDialog({
    super.key,
    required this.userId,
    required this.onStartExport,
  });

  @override
  State<ExportCustomizationDialog> createState() => _ExportCustomizationDialogState();
}

class _ExportCustomizationDialogState extends State<ExportCustomizationDialog> {
  final Set<String> _selectedCategories = <String>{};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeAttachments = true;

  final List<ExportDataCategory> _availableCategories = ExportDataCategory.values;

  @override
  void initState() {
    super.initState();
    // Selecionar todas as categorias por padrão
    _selectedCategories.addAll(_availableCategories.map((e) => e.key));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoriesSection(),
                    const SizedBox(height: 24),
                    _buildDateRangeSection(),
                    const SizedBox(height: 24),
                    _buildOptionsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.download,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Exportar Meus Dados',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize sua exportação de dados conforme LGPD',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Categorias de Dados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Opção "Selecionar Todos"
              CheckboxListTile(
                title: const Text('Selecionar Todos'),
                subtitle: const Text('Incluir todas as categorias disponíveis'),
                value: _selectedCategories.length == _availableCategories.length,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.clear();
                      _selectedCategories.addAll(_availableCategories.map((e) => e.key));
                    } else {
                      _selectedCategories.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Divider(height: 1),
              // Categorias individuais
              ..._availableCategories.map((category) => CheckboxListTile(
                title: Text(category.displayName),
                subtitle: _getCategoryDescription(category),
                value: _selectedCategories.contains(category.key),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCategories.add(category.key);
                    } else {
                      _selectedCategories.remove(category.key);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.date_range,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Período (Opcional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Deixe em branco para incluir todos os dados',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Data Inicial',
                date: _startDate,
                onChanged: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Data Final',
                date: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Opções Adicionais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Incluir Anexos'),
          subtitle: const Text('Avatars e arquivos relacionados'),
          value: _includeAttachments,
          onChanged: (value) => setState(() => _includeAttachments = value),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedCategories.isEmpty ? null : _startExport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Iniciar Exportação'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Não definida',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (date != null)
              InkWell(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(Function(DateTime?) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onChanged(date);
    }
  }

  void _startExport() {
    final request = ExportRequest(
      userId: widget.userId,
      includedCategories: _selectedCategories.toList(),
      startDate: _startDate,
      endDate: _endDate,
      outputFormats: ['json'],
      includeAttachments: _includeAttachments,
    );

    Navigator.of(context).pop();
    widget.onStartExport(request);
  }

  Widget? _getCategoryDescription(ExportDataCategory category) {
    final descriptions = {
      ExportDataCategory.profile: 'Nome, email e configurações pessoais',
      ExportDataCategory.vehicles: 'Dados dos veículos cadastrados',
      ExportDataCategory.fuel: 'Histórico de abastecimentos',
      ExportDataCategory.maintenance: 'Registros de manutenção',
      ExportDataCategory.odometer: 'Leituras do odômetro',
      ExportDataCategory.expenses: 'Despesas dos veículos',
      ExportDataCategory.categories: 'Categorias de despesas',
      ExportDataCategory.settings: 'Configurações do aplicativo',
    };

    final description = descriptions[category];
    return description != null ? Text(description) : null;
  }
}