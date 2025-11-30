import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rainfall_measurement_entity.dart';
import '../providers/pluviometer_provider.dart';
import '../widgets/measurement_card.dart';
import 'measurement_form_page.dart';

/// Página de listagem de medições pluviométricas
class MeasurementsListPage extends ConsumerStatefulWidget {
  const MeasurementsListPage({super.key, this.rainGaugeId});

  final String? rainGaugeId;

  @override
  ConsumerState<MeasurementsListPage> createState() =>
      _MeasurementsListPageState();
}

class _MeasurementsListPageState extends ConsumerState<MeasurementsListPage> {
  String? _selectedRainGaugeId;
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedRainGaugeId = widget.rainGaugeId;
    _loadMeasurements();
  }

  void _loadMeasurements() {
    ref.read(measurementsProvider.notifier).loadMeasurements(
          rainGaugeId: _selectedRainGaugeId,
          start: _selectedPeriod?.start,
          end: _selectedPeriod?.end,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementsProvider);
    final gaugesState = ref.watch(rainGaugesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medições'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, gaugesState),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeasurements,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chips de filtros ativos
          if (_selectedRainGaugeId != null || _selectedPeriod != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedRainGaugeId != null)
                    Chip(
                      label: Text(
                        gaugesState.gauges
                                .where((g) => g.id == _selectedRainGaugeId)
                                .firstOrNull
                                ?.description ??
                            'Pluviômetro',
                      ),
                      onDeleted: () {
                        setState(() => _selectedRainGaugeId = null);
                        _loadMeasurements();
                      },
                    ),
                  if (_selectedPeriod != null)
                    Chip(
                      label: Text(
                        '${_formatDate(_selectedPeriod!.start)} - ${_formatDate(_selectedPeriod!.end)}',
                      ),
                      onDeleted: () {
                        setState(() => _selectedPeriod = null);
                        _loadMeasurements();
                      },
                    ),
                ],
              ),
            ),

          // Lista de medições
          Expanded(
            child: _buildBody(context, state, gaugesState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Medição'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MeasurementsState state,
    RainGaugesState gaugesState,
  ) {
    if (state.isLoading && state.measurements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeasurements,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (state.measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhuma medição registrada'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Medição'),
            ),
          ],
        ),
      );
    }

    // Mapa de pluviômetros para exibir nome
    final gaugeMap = {
      for (var g in gaugesState.gauges) g.id: g.description,
    };

    return RefreshIndicator(
      onRefresh: () async => _loadMeasurements(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.measurements.length,
        itemBuilder: (context, index) {
          final measurement = state.measurements[index];
          final gaugeName =
              gaugeMap[measurement.rainGaugeId] ?? 'Pluviômetro desconhecido';

          return MeasurementCard(
            measurement: measurement,
            gaugeName: gaugeName,
            onTap: () => _showMeasurementDetails(context, measurement, gaugeName),
            onEdit: () => _navigateToForm(context, measurement: measurement),
            onDelete: () => _confirmDelete(context, measurement),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, RainGaugesState gaugesState) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por pluviômetro
            const Text('Pluviômetro:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedRainGaugeId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                ...gaugesState.gauges.map(
                  (g) => DropdownMenuItem(
                    value: g.id,
                    child: Text(g.description),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedRainGaugeId = value);
              },
            ),
            const SizedBox(height: 16),

            // Filtro por período
            const Text('Período:'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedPeriod,
                );
                if (range != null) {
                  setState(() => _selectedPeriod = range);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedPeriod != null
                    ? '${_formatDate(_selectedPeriod!.start)} - ${_formatDate(_selectedPeriod!.end)}'
                    : 'Selecionar período',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRainGaugeId = null;
                _selectedPeriod = null;
              });
              Navigator.pop(context);
              _loadMeasurements();
            },
            child: const Text('Limpar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadMeasurements();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {RainfallMeasurementEntity? measurement}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MeasurementFormPage(
          measurement: measurement,
          preselectedRainGaugeId: _selectedRainGaugeId,
        ),
      ),
    );
  }

  void _showMeasurementDetails(
      BuildContext context, RainfallMeasurementEntity measurement, String gaugeName) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '${measurement.amount.toStringAsFixed(1)} mm',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Pluviômetro: $gaugeName'),
            Text('Data: ${_formatDateTime(measurement.measurementDate)}'),
            if (measurement.observations != null) ...[
              const SizedBox(height: 8),
              Text('Observações: ${measurement.observations}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToForm(context, measurement: measurement);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context, measurement);
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RainfallMeasurementEntity measurement) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir esta medição de ${measurement.amount.toStringAsFixed(1)} mm?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(measurementsProvider.notifier)
                  .deleteMeasurement(measurement.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medição excluída')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
