import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/export_request.dart';
import '../providers/data_export_notifier.dart';

/// Widget that displays data export availability information
class ExportAvailabilityWidget extends ConsumerStatefulWidget {
  final String userId;
  final Set<DataType> requestedDataTypes;
  final VoidCallback? onAvailabilityChecked;

  const ExportAvailabilityWidget({
    super.key,
    required this.userId,
    required this.requestedDataTypes,
    this.onAvailabilityChecked,
  });

  @override
  ConsumerState<ExportAvailabilityWidget> createState() => _ExportAvailabilityWidgetState();
}

class _ExportAvailabilityWidgetState extends ConsumerState<ExportAvailabilityWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAvailability();
    });
  }

  Future<void> _checkAvailability() async {
    await ref.read(dataExportNotifierProvider.notifier).checkExportAvailability(
      userId: widget.userId,
      requestedDataTypes: widget.requestedDataTypes,
    );

    if (widget.onAvailabilityChecked != null) {
      widget.onAvailabilityChecked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportStateAsync = ref.watch(dataExportNotifierProvider);

    return exportStateAsync.when(
      data: (exportState) {
        if (exportState.isLoading) {
          return const _LoadingWidget();
        }

        if (exportState.error != null) {
          return _ErrorWidget(
            error: exportState.error!,
            onRetry: _checkAvailability,
          );
        }

        final availability = exportState.availabilityResult;
        if (availability == null) {
          return const _NoDataWidget();
        }

        return _AvailabilityResultWidget(
          availability: availability,
          requestedDataTypes: widget.requestedDataTypes,
        );
      },
      loading: () => const _LoadingWidget(),
      error: (error, _) => _ErrorWidget(
        error: error.toString(),
        onRetry: _checkAvailability,
      ),
    );
  }
}

/// Widget displayed while checking availability
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Verificando disponibilidade dos dados...',
              style: TextStyle(fontSize: 16),
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

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao verificar disponibilidade',
              style: Theme.of(context).textTheme.titleMedium,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
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

  const _UnavailableWidget({
    required this.reason,
    this.earliestDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dados não disponíveis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (earliestDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponível a partir de:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${earliestDate!.day}/${earliestDate!.month}/${earliestDate!.year}',
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
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dados disponíveis para exportação',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            if (availability.estimatedSizeInBytes != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storage, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tamanho estimado: ${_formatFileSize(availability.estimatedSizeInBytes!)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],

            if (availableTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tipos de dados disponíveis:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...availableTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(type.displayName)),
                    ],
                  ),
                ),
              ),
            ],

            if (unavailableTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tipos de dados não disponíveis:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...unavailableTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(type.displayName)),
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
