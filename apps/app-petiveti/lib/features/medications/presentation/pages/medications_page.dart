import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';
import '../widgets/empty_medications_state.dart';
import '../widgets/medication_card.dart';
import '../widgets/medication_filters.dart';
import '../widgets/medication_stats.dart';

class MedicationsPage extends ConsumerStatefulWidget {
  final String? animalId;

  const MedicationsPage({
    super.key,
    this.animalId,
  });

  @override
  ConsumerState<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends ConsumerState<MedicationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load medications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.animalId != null) {
        ref.read(medicationsProvider.notifier).loadMedicationsByAnimalId(widget.animalId!);
      } else {
        ref.read(medicationsProvider.notifier).loadMedications();
      }
      ref.read(medicationsProvider.notifier).loadActiveMedications();
      ref.read(medicationsProvider.notifier).loadExpiringMedications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationsState = ref.watch(medicationsProvider);
    final filteredMedications = ref.watch(filteredMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animalId != null ? 'Medicamentos do Pet' : 'Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMedications,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddMedication(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              text: 'Todos (${medicationsState.medications.length})',
              icon: const Icon(Icons.medication, size: 16),
            ),
            Tab(
              text: 'Ativos (${medicationsState.activeMedications.length})',
              icon: const Icon(Icons.play_circle_filled, size: 16),
            ),
            Tab(
              text: 'Vencendo (${medicationsState.expiringMedications.length})',
              icon: const Icon(Icons.warning, size: 16),
            ),
            const Tab(
              text: 'Estatísticas',
              icon: Icon(Icons.analytics, size: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar medicamentos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(medicationSearchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 8),
                // Filters
                const MedicationFilters(),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All medications
                _buildMedicationsList(
                  medications: filteredMedications,
                  isLoading: medicationsState.isLoading,
                  error: medicationsState.error,
                ),
                
                // Active medications
                _buildMedicationsList(
                  medications: medicationsState.activeMedications,
                  isLoading: medicationsState.isLoading,
                  error: medicationsState.error,
                  emptyMessage: 'Nenhum medicamento ativo no momento',
                ),
                
                // Expiring medications
                _buildMedicationsList(
                  medications: medicationsState.expiringMedications,
                  isLoading: medicationsState.isLoading,
                  error: medicationsState.error,
                  emptyMessage: 'Nenhum medicamento próximo ao vencimento',
                ),
                
                // Statistics
                const MedicationStats(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMedication(context),
        tooltip: 'Adicionar Medicamento',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicationsList({
    required List<Medication> medications,
    required bool isLoading,
    String? error,
    String? emptyMessage,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMedications,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (medications.isEmpty) {
      return EmptyMedicationsState(
        message: emptyMessage ?? 'Nenhum medicamento encontrado',
        onAddPressed: () => _navigateToAddMedication(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMedications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MedicationCard(
              medication: medication,
              onTap: () => _navigateToMedicationDetails(context, medication),
              onEdit: () => _navigateToEditMedication(context, medication),
              onDelete: () => _confirmDeleteMedication(context, medication),
              onDiscontinue: () => _confirmDiscontinueMedication(context, medication),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshMedications() async {
    final notifier = ref.read(medicationsProvider.notifier);
    
    if (widget.animalId != null) {
      await notifier.loadMedicationsByAnimalId(widget.animalId!);
    } else {
      await notifier.loadMedications();
    }
    
    await notifier.loadActiveMedications();
    await notifier.loadExpiringMedications();
  }

  void _navigateToAddMedication(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/medications/add',
      arguments: {'animalId': widget.animalId},
    );
  }

  void _navigateToMedicationDetails(BuildContext context, Medication medication) {
    Navigator.of(context).pushNamed(
      '/medications/details',
      arguments: {'medicationId': medication.id},
    );
  }

  void _navigateToEditMedication(BuildContext context, Medication medication) {
    Navigator.of(context).pushNamed(
      '/medications/edit',
      arguments: {'medication': medication},
    );
  }

  Future<void> _confirmDeleteMedication(BuildContext context, Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Medicamento'),
        content: Text('Tem certeza que deseja excluir "${medication.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(medicationsProvider.notifier).deleteMedication(medication.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento excluído com sucesso')),
        );
      }
    }
  }

  Future<void> _confirmDiscontinueMedication(BuildContext context, Medication medication) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descontinuar Medicamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deseja descontinuar "${medication.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo da descontinuação',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Descontinuar'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      await ref.read(medicationsProvider.notifier).discontinueMedication(
        medication.id,
        reasonController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento descontinuado')),
        );
      }
    }
    
    reasonController.dispose();
  }
}