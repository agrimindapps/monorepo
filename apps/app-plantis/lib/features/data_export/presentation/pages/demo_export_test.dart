import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_export_provider.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../data/repositories/data_export_repository_impl.dart';
import '../../data/datasources/local/plants_export_datasource.dart';
import '../../data/datasources/local/settings_export_datasource.dart';
import '../../data/datasources/local/export_file_generator.dart';

/// Demo page to test the LGPD export functionality
class DemoExportTestPage extends StatelessWidget {
  const DemoExportTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Export LGPD'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ChangeNotifierProvider(
        create: (context) {
          // Create dependencies
          final plantsDataSource = PlantsExportLocalDataSource();
          final settingsDataSource = SettingsExportLocalDataSource();
          final fileGenerator = ExportFileGenerator();

          final repository = DataExportRepositoryImpl(
            plantsDataSource: plantsDataSource,
            settingsDataSource: settingsDataSource,
            fileGenerator: fileGenerator,
          );

          final checkAvailabilityUseCase = CheckExportAvailabilityUseCase(repository);
          final requestExportUseCase = RequestExportUseCase(repository);
          final getHistoryUseCase = GetExportHistoryUseCase(repository);

          return DataExportProvider(
            checkAvailabilityUseCase: checkAvailabilityUseCase,
            requestExportUseCase: requestExportUseCase,
            getHistoryUseCase: getHistoryUseCase,
            repository: repository,
          );
        },
        child: const _DemoContent(),
      ),
    );
  }
}

class _DemoContent extends StatefulWidget {
  const _DemoContent();

  @override
  State<_DemoContent> createState() => _DemoContentState();
}

class _DemoContentState extends State<_DemoContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataExportProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataExportProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teste de Funcionalidade LGPD Export',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Loading: ${provider.isLoading}'),
                      Text('Error: ${provider.error ?? 'None'}'),
                      Text('History: ${provider.exportHistory.length} exports'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Text(
                'Actions:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.checkExportAvailability(),
                icon: const Icon(Icons.search),
                label: const Text('Check Availability'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.requestExport(
                          dataTypes: {DataType.plants, DataType.settings},
                          format: ExportFormat.json,
                        ),
                icon: const Icon(Icons.download),
                label: const Text('Request Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Availability Result
              if (provider.availabilityResult != null) ...[
                Text(
                  'Availability Result:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available: ${provider.availabilityResult!.isAvailable}'),
                        if (provider.availabilityResult!.reason != null)
                          Text('Reason: ${provider.availabilityResult!.reason}'),
                        Text('Data Types: ${provider.availabilityResult!.availableDataTypes.length}'),
                        if (provider.availabilityResult!.estimatedSizeInBytes != null)
                          Text('Size: ${provider.availabilityResult!.estimatedSizeInBytes} bytes'),
                      ],
                    ),
                  ),
                ),
              ],

              // Export History
              if (provider.exportHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Export History:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.exportHistory.map(
                  (request) => Card(
                    child: ListTile(
                      title: Text('Export ${request.format.displayName}'),
                      subtitle: Text(request.status.displayName),
                      trailing: Text(request.requestDate.day.toString()),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}