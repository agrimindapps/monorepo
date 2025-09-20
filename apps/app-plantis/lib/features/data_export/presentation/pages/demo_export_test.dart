import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/local/export_file_generator.dart';
import '../../data/datasources/local/settings_export_datasource.dart';
import '../../data/datasources/local/plants_export_datasource.dart';
import '../../data/repositories/data_export_repository_impl.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';
import '../providers/data_export_provider.dart';

/// Demo implementation that only uses mock data
class DemoPlantsExportDataSource implements PlantsExportDataSource {
  @override
  Future<List<PlantExportData>> getUserPlantsData(String userId) async {
    // Return mock data for demo
    return [
      PlantExportData(
        id: 'demo-1',
        name: 'Rosa Demo',
        species: 'Rosa gallica',
        spaceId: 'jardim-demo',
        imageUrls: const ['demo_rosa.jpg'],
        plantingDate: DateTime.now().subtract(const Duration(days: 30)),
        notes: 'Planta demo para teste de exportação LGPD',
        isFavorited: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PlantExportData(
        id: 'demo-2',
        name: 'Manjericão Demo',
        species: 'Ocimum basilicum',
        spaceId: 'horta-demo',
        imageUrls: const ['demo_manjericao.jpg'],
        plantingDate: DateTime.now().subtract(const Duration(days: 15)),
        notes: 'Outra planta para demonstração',
        isFavorited: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<TaskExportData>> getUserTasksData(String userId) async {
    return [
      TaskExportData(
        id: 'demo-task-1',
        title: 'Regar Rosa Demo',
        description: 'Tarefa de demonstração para teste de export',
        plantId: 'demo-1',
        plantName: 'Rosa Demo',
        type: 'watering',
        status: 'pending',
        priority: 'medium',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        completedAt: null,
        completionNotes: null,
        isRecurring: true,
        recurringIntervalDays: 7,
        nextDueDate: DateTime.now().add(const Duration(days: 8)),
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<SpaceExportData>> getUserSpacesData(String userId) async {
    return [
      SpaceExportData(
        id: 'jardim-demo',
        name: 'Jardim Demo',
        description: 'Espaço de demonstração para testes',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now(),
      ),
      SpaceExportData(
        id: 'horta-demo',
        name: 'Horta Demo',
        description: 'Outro espaço para demonstração',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId) async {
    return [
      PlantPhotoExportData(
        plantId: 'demo-1',
        plantName: 'Rosa Demo',
        photoUrls: const ['demo_rosa_1.jpg', 'demo_rosa_2.jpg'],
        takenAt: DateTime.now().subtract(const Duration(days: 5)),
        caption: 'Fotos demo da rosa',
      ),
    ];
  }

  @override
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(String userId) async {
    return [
      PlantCommentExportData(
        id: 'demo-comment-1',
        plantId: 'demo-1',
        plantName: 'Rosa Demo',
        content: 'Comentário demo sobre a rosa',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

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
          // Create dependencies - using demo implementation with mock data
          final plantsDataSource = DemoPlantsExportDataSource();
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