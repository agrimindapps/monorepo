import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';
import '../widgets/add_medication_dialog.dart';
import '../widgets/empty_medications_state.dart';
import '../widgets/medication_card.dart';

/// Página de medicamentos simplificada seguindo padrão Odometer
class MedicationsPage extends ConsumerStatefulWidget {
  final String? animalId;

  const MedicationsPage({super.key, this.animalId});

  @override
  ConsumerState<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends ConsumerState<MedicationsPage> {
  String? _selectedAnimalId;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final notifier = ref.read(medicationsProvider.notifier);
      if (widget.animalId != null) {
        await notifier.loadMedicationsByAnimalId(widget.animalId!);
      } else {
        await notifier.loadMedications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar medicamentos: $e'),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: _loadInitialData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicationsState = ref.watch(medicationsProvider);
    final medications = medicationsState.medications;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (widget.animalId == null) _buildAnimalSelector(),
            if (_selectedAnimalId != null && medications.isNotEmpty)
              _buildMonthSelector(medications),
            Expanded(
              child: _buildContent(context, medicationsState, medications),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_selectedAnimalId != null || widget.animalId != null)
            ? () => _navigateToAddMedication(context)
            : null,
        tooltip: (_selectedAnimalId != null || widget.animalId != null)
            ? 'Adicionar medicamento'
            : 'Selecione um pet primeiro',
        backgroundColor: (_selectedAnimalId != null || widget.animalId != null)
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: (_selectedAnimalId != null || widget.animalId != null)
            ? null
            : Theme.of(context).colorScheme.onSurfaceVariant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PetivetiPageHeader(
        icon: Icons.medication,
        title: 'Medicamentos',
        subtitle: 'Controle de medicamentos dos pets',
        showBackButton: true,
        actions: [
          _buildHeaderAction(
            icon: _showStats ? Icons.analytics : Icons.analytics_outlined,
            onTap: () => setState(() => _showStats = !_showStats),
            tooltip: _showStats ? 'Ocultar estatísticas' : 'Mostrar estatísticas',
          ),
          _buildHeaderAction(
            icon: Icons.refresh,
            onTap: _refreshMedications,
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: (animalId) {
          setState(() => _selectedAnimalId = animalId);
          if (animalId != null) {
            ref.read(medicationsProvider.notifier).filterByAnimal(animalId);
          } else {
            ref.read(medicationsProvider.notifier).clearAnimalFilter();
          }
        },
        hintText: 'Selecione um pet',
      ),
    );
  }

  Widget _buildMonthSelector(List<Medication> medications) {
    final months = _getMonths(medications);
    final selectedMonth = ref.watch(medicationsProvider).selectedMonth;

    if (months.isEmpty) return const SizedBox.shrink();

    // Auto-select current month if none selected
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final hasCurrentMonth = months.any((m) =>
            m.year == currentMonth.year && m.month == currentMonth.month);
        
        if (hasCurrentMonth) {
          ref.read(medicationsProvider.notifier).selectMonth(currentMonth);
        } else {
          ref.read(medicationsProvider.notifier).selectMonth(months.first);
        }
      });
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth != null &&
              month.year == selectedMonth.year &&
              month.month == selectedMonth.month;

          final monthName = DateFormat('MMM yy', 'pt_BR').format(month);
          final formattedMonth =
              monthName[0].toUpperCase() + monthName.substring(1);

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                ref.read(medicationsProvider.notifier).selectMonth(month);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MedicationsState state,
    List<Medication> medications,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMedications,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_selectedAnimalId == null && widget.animalId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Selecione um pet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Escolha um pet acima para ver seus medicamentos'),
          ],
        ),
      );
    }

    final filteredMedications = _getFilteredMedications(medications);

    if (filteredMedications.isEmpty) {
      return EmptyMedicationsState(
        message: 'Nenhum medicamento encontrado',
        onAddPressed: () => _navigateToAddMedication(context),
      );
    }

    return Column(
      children: [
        if (_showStats) _buildStatsPanel(filteredMedications),
        Expanded(child: _buildMedicationsList(filteredMedications)),
      ],
    );
  }

  List<Medication> _getFilteredMedications(List<Medication> medications) {
    final selectedMonth = ref.watch(medicationsProvider).selectedMonth;
    if (selectedMonth == null) return medications;

    return medications.where((m) {
      final startDate = m.startDate;
      return startDate.year == selectedMonth.year &&
          startDate.month == selectedMonth.month;
    }).toList();
  }

  Widget _buildStatsPanel(List<Medication> medications) {
    final total = medications.length;
    final active = medications.where((m) => m.isActive).length;
    final expiring = medications.where((m) {
      if (m.endDate == null) return false;
      final daysUntilEnd = m.endDate!.difference(DateTime.now()).inDays;
      return daysUntilEnd <= 7 && daysUntilEnd >= 0;
    }).length;
    final completed = medications.where((m) => !m.isActive).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.medication,
                  label: 'Total',
                  value: total.toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.play_circle_filled,
                  label: 'Ativos',
                  value: active.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning,
                  label: 'Vencendo',
                  value: expiring.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Concluídos',
                  value: completed.toString(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList(List<Medication> medications) {
    return RefreshIndicator(
      onRefresh: _refreshMedications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Dismissible(
            key: ValueKey(medication.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Excluir',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) => _confirmDeleteMedication(medication),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MedicationCard(
                medication: medication,
                onTap: () => _navigateToMedicationDetails(context, medication),
                onEdit: () => _navigateToEditMedication(context, medication),
                onDelete: () => _confirmDeleteMedication(medication),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DateTime> _getMonths(List<Medication> medications) {
    if (medications.isEmpty) return [];
    
    final dates = medications.map((m) => m.startDate).toList();
    final uniqueMonths = <DateTime>{};
    
    for (final date in dates) {
      uniqueMonths.add(DateTime(date.year, date.month));
    }
    
    final sortedMonths = uniqueMonths.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first
    
    return sortedMonths;
  }

  Future<void> _refreshMedications() async {
    try {
      final notifier = ref.read(medicationsProvider.notifier);
      if (widget.animalId != null) {
        await notifier.loadMedicationsByAnimalId(widget.animalId!);
      } else {
        await notifier.loadMedications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  void _navigateToAddMedication(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddMedicationDialog(
        initialAnimalId: widget.animalId ?? _selectedAnimalId,
      ),
    );
  }

  void _navigateToMedicationDetails(BuildContext context, Medication medication) {
    Navigator.of(context).pushNamed(
      '/medications/details',
      arguments: {'medicationId': medication.id},
    );
  }

  void _navigateToEditMedication(BuildContext context, Medication medication) {
    showDialog<void>(
      context: context,
      builder: (context) => AddMedicationDialog(medication: medication),
    );
  }

  Future<bool> _confirmDeleteMedication(Medication medication) async {
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
      return true;
    }
    return false;
  }
}
