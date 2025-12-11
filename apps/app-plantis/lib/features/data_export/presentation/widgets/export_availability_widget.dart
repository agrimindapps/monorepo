import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/export_request.dart';
import '../notifiers/data_export_notifier.dart';

/// Widget that displays data export availability information for Plantis
class ExportAvailabilityWidget extends ConsumerStatefulWidget {
  final Set<DataType> requestedDataTypes;
  final VoidCallback? onAvailabilityChecked;

  const ExportAvailabilityWidget({
    super.key,
    required this.requestedDataTypes,
    this.onAvailabilityChecked,
  });

  @override
  ConsumerState<ExportAvailabilityWidget> createState() =>
      _ExportAvailabilityWidgetState();
}

class _ExportAvailabilityWidgetState
    extends ConsumerState<ExportAvailabilityWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAvailability();
    });
  }

  Future<void> _checkAvailability() async {
    await ref
        .read(dataExportNotifierProvider.notifier)
        .checkExportAvailability(requestedDataTypes: widget.requestedDataTypes);

    if (widget.onAvailabilityChecked != null) {
      widget.onAvailabilityChecked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(dataExportNotifierProvider);

    return asyncValue.when(
      data: (state) {
        final availability = state.availabilityResult;
        if (availability == null) {
          return const _NoDataWidget();
        }

        return _AvailabilityResultWidget(
          availability: availability,
          requestedDataTypes: widget.requestedDataTypes,
        );
      },
      loading: () => const _LoadingWidget(),
      error: (error, _) =>
          _ErrorWidget(error: error.toString(), onRetry: _checkAvailability),
    );
  }
}

/// Widget displayed while checking availability
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: PlantisColors.primary),
            const SizedBox(height: 16),
            Text(
              'Verificando disponibilidade dos dados...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displayed when there's an error checking availability
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao verificar disponibilidade',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displayed when no availability data is present
class _NoDataWidget extends StatelessWidget {
  const _NoDataWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma informação de disponibilidade encontrada',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays the availability result
class _AvailabilityResultWidget extends StatelessWidget {
  final ExportAvailabilityResult availability;
  final Set<DataType> requestedDataTypes;

  const _AvailabilityResultWidget({
    required this.availability,
    required this.requestedDataTypes,
  });

  @override
  Widget build(BuildContext context) {
    if (!availability.isAvailable) {
      return _UnavailableWidget(
        reason: availability.reason ?? 'Dados não disponíveis',
        earliestDate: availability.earliestAvailableDate,
      );
    }

    return _AvailableWidget(
      availability: availability,
      requestedDataTypes: requestedDataTypes,
    );
  }
}

/// Widget displayed when data is not available
class _UnavailableWidget extends StatelessWidget {
  final String reason;
  final DateTime? earliestDate;

  const _UnavailableWidget({required this.reason, this.earliestDate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dados não disponíveis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withAlpha(60)),
              ),
              child: Text(
                reason,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (earliestDate != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PlantisColors.primary.withAlpha(60),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: PlantisColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Disponível a partir de:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: PlantisColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${earliestDate!.day}/${earliestDate!.month}/${earliestDate!.year} às ${earliestDate!.hour}:${earliestDate!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: PlantisColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget displayed when data is available
class _AvailableWidget extends StatelessWidget {
  final ExportAvailabilityResult availability;
  final Set<DataType> requestedDataTypes;

  const _AvailableWidget({
    required this.availability,
    required this.requestedDataTypes,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = availability.availableDataTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet();

    final unavailableTypes = availability.availableDataTypes.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toSet();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.leaf.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: PlantisColors.leaf,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados disponíveis para exportação',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seus dados do Plantis estão prontos para exportação',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (availability.estimatedSizeInBytes != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PlantisColors.primary.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storage,
                      color: PlantisColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tamanho estimado: ${_formatFileSize(availability.estimatedSizeInBytes!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: PlantisColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (availableTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tipos de dados disponíveis:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...availableTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.eco,
                        color: PlantisColors.leaf,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.displayName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (unavailableTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tipos de dados não disponíveis:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...unavailableTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.displayName,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
