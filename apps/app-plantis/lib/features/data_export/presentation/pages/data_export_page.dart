import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/export_request.dart';
import '../notifiers/data_export_notifier.dart';
import '../widgets/data_type_selector.dart';
import '../widgets/export_availability_widget.dart';
import '../widgets/export_format_selector.dart';
import '../widgets/export_progress_dialog.dart';

class DataExportPage extends ConsumerStatefulWidget {
  const DataExportPage({super.key});

  @override
  ConsumerState<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends ConsumerState<DataExportPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Set<DataType> _selectedDataTypes = {
    DataType.plants,
    DataType.plantTasks,
    DataType.plantComments,
    DataType.spaces,
    DataType.settings,
  };
  ExportFormat _selectedFormat = ExportFormat.json;
  Map<DataType, int>? _dataStatistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDataStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDataStatistics() async {
    try {
      if (mounted) {
        setState(() {
          _dataStatistics = {}; // Placeholder for now
        });
      }
    } catch (e) {
      // Silently fail - statistics are optional
    }
  }

  Future<void> _requestExport(WidgetRef ref) async {
    if (_selectedDataTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um tipo de dados para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final notifier = ref.read(dataExportNotifierProvider.notifier);
    final request = await notifier.requestExport(
      dataTypes: _selectedDataTypes,
      format: _selectedFormat,
    );

    if (request != null && mounted) {
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ExportProgressDialog(request: request),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar Dados',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Dados pessoais - LGPD',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _showHelpDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: PlantisColors.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: PlantisColors.primary,
          tabs: const [
            Tab(text: 'Exportar Dados'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: ResponsiveLayout(
        child: TabBarView(
          controller: _tabController,
          children: [_buildExportTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildExportTab() {
    return Consumer(
      builder: (context, ref, child) {
        final dataExportState = ref.watch(dataExportNotifierProvider);
        final availabilityResult = dataExportState.value?.availabilityResult;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PlantisColors.primary.withValues(alpha: 0.12),
                      PlantisColors.leaf.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PlantisColors.primary.withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PlantisColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.privacy_tip,
                            color: PlantisColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Direito à Portabilidade - LGPD',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: PlantisColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'De acordo com a Lei Geral de Proteção de Dados, você tem o direito de exportar seus dados pessoais em formato estruturado e de uso comum.',
                      style: TextStyle(
                        fontSize: 14,
                        color: PlantisColors.primary.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              DataTypeSelector(
                selectedDataTypes: _selectedDataTypes,
                onSelectionChanged: (types) {
                  setState(() {
                    _selectedDataTypes = types;
                  });
                },
                dataStatistics: _dataStatistics,
              ),

              const SizedBox(height: 24),
              ExportFormatSelector(
                selectedFormat: _selectedFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _selectedFormat = format;
                  });
                },
              ),

              const SizedBox(height: 24),
              ExportAvailabilityWidget(
                requestedDataTypes: _selectedDataTypes,
                onAvailabilityChecked: () async {
                  final notifier = ref.read(
                    dataExportNotifierProvider.notifier,
                  );
                  await notifier.checkExportAvailability(
                    requestedDataTypes: _selectedDataTypes,
                  );
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _selectedDataTypes.isEmpty ||
                          (availabilityResult?.isAvailable != true)
                      ? null
                      : () => _requestExport(ref),
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar Dados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlantisColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final dataExportState = ref.watch(dataExportNotifierProvider);
        final exportHistory = dataExportState.value?.exportHistory ?? [];

        if (exportHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: PlantisColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma exportação realizada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suas exportações de dados aparecerão aqui',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final notifier = ref.read(dataExportNotifierProvider.notifier);
            await notifier.refresh();
          },
          color: PlantisColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exportHistory.length,
            itemBuilder: (context, index) {
              final request = exportHistory[index];
              return _buildHistoryItem(request);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(ExportRequest request) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export ${request.format.displayName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        request.status.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.status == ExportRequestStatus.completed) ...[
                  IconButton(
                    onPressed: () async {
                      final notifier = ref.read(
                        dataExportNotifierProvider.notifier,
                      );
                      final success = await notifier.downloadExport(request.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download iniciado com sucesso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao fazer download'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download, color: PlantisColors.leaf),
                  ),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirmed = await _showDeleteConfirmation();
                      if (confirmed) {
                        final notifier = ref.read(
                          dataExportNotifierProvider.notifier,
                        );
                        final success = await notifier.deleteExport(request.id);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Exportação deletada com sucesso'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao deletar exportação'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Deletar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Data',
                    '${request.requestDate.day}/${request.requestDate.month}/${request.requestDate.year}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Tipos',
                    '${request.dataTypes.length} tipos',
                  ),
                ),
              ],
            ),
            if (request.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ExportRequestStatus status) {
    switch (status) {
      case ExportRequestStatus.completed:
        return PlantisColors.leaf;
      case ExportRequestStatus.processing:
        return PlantisColors.primary;
      case ExportRequestStatus.pending:
        return Colors.orange;
      case ExportRequestStatus.failed:
      case ExportRequestStatus.expired:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ExportRequestStatus status) {
    switch (status) {
      case ExportRequestStatus.completed:
        return Icons.check_circle;
      case ExportRequestStatus.processing:
        return Icons.hourglass_empty;
      case ExportRequestStatus.pending:
        return Icons.schedule;
      case ExportRequestStatus.failed:
        return Icons.error;
      case ExportRequestStatus.expired:
        return Icons.timer_off;
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar exportação'),
        content: const Text('Tem certeza que deseja deletar esta exportação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: PlantisColors.primary),
            SizedBox(width: 8),
            Text('Ajuda - Exportação de Dados'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sobre a LGPD:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'A Lei Geral de Proteção de Dados garante o seu direito de exportar seus dados pessoais em formato estruturado.',
              ),
              SizedBox(height: 16),
              Text(
                'Tipos de dados incluídos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Plantas cadastradas por você'),
              Text('• Tarefas e lembretes criados'),
              Text('• Espaços organizacionais'),
              Text('• Configurações personalizadas'),
              Text('• Metadados de fotos (não as imagens)'),
              SizedBox(height: 16),
              Text('Segurança:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Limite de uma exportação por hora'),
              Text('• Arquivos válidos por 30 dias'),
              Text('• Dados criptografados durante o processamento'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
