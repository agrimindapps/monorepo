import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../providers/pluviometer_provider.dart';
import '../widgets/rain_gauge_card.dart';
import 'rain_gauge_form_page.dart';

/// Página de listagem de pluviômetros
class RainGaugesListPage extends ConsumerWidget {
  const RainGaugesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rainGaugesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluviômetros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(rainGaugesProvider.notifier).loadGauges();
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, RainGaugesState state) {
    if (state.isLoading && state.gauges.isEmpty) {
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
              onPressed: () {
                ref.read(rainGaugesProvider.notifier).loadGauges();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (state.gauges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum pluviômetro cadastrado'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Pluviômetro'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(rainGaugesProvider.notifier).loadGauges();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.gauges.length,
        itemBuilder: (context, index) {
          final gauge = state.gauges[index];
          return RainGaugeCard(
            gauge: gauge,
            onTap: () => _showGaugeDetails(context, ref, gauge),
            onEdit: () => _navigateToForm(context, gauge: gauge),
            onDelete: () => _confirmDelete(context, ref, gauge),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {RainGaugeEntity? gauge}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => RainGaugeFormPage(gauge: gauge),
      ),
    );
  }

  void _showGaugeDetails(
      BuildContext context, WidgetRef ref, RainGaugeEntity gauge) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
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
                  gauge.description,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'ID', value: gauge.id),
                _DetailRow(label: 'Capacidade', value: '${gauge.capacity} mm'),
                if (gauge.hasLocation) ...[
                  _DetailRow(
                    label: 'Localização',
                    value: 'Lat: ${gauge.latitude}, Lon: ${gauge.longitude}',
                  ),
                ],
                if (gauge.groupId != null)
                  _DetailRow(label: 'Grupo', value: gauge.groupId!),
                if (gauge.createdAt != null)
                  _DetailRow(
                    label: 'Criado em',
                    value: _formatDate(gauge.createdAt!),
                  ),
                if (gauge.updatedAt != null)
                  _DetailRow(
                    label: 'Atualizado em',
                    value: _formatDate(gauge.updatedAt!),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToForm(context, gauge: gauge);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navega para medições deste pluviômetro
                        ref
                            .read(measurementsProvider.notifier)
                            .loadMeasurements(rainGaugeId: gauge.id);
                      },
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Ver Medições'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, RainGaugeEntity gauge) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o pluviômetro "${gauge.description}"?\n\n'
          'Todas as medições associadas também serão removidas.',
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
                  .read(rainGaugesProvider.notifier)
                  .deleteGauge(gauge.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pluviômetro excluído')),
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
