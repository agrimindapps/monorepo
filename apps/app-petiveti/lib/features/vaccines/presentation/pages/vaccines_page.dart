import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';
import '../widgets/add_vaccine_dialog.dart';
import '../widgets/vaccine_card.dart';

/// Página de vacinas simplificada seguindo padrão Odometer
class VaccinesPage extends ConsumerStatefulWidget {
  const VaccinesPage({super.key});

  @override
  ConsumerState<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends ConsumerState<VaccinesPage> {
  String? _selectedAnimalId;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaccinesProvider.notifier).loadVaccines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaccinesState = ref.watch(vaccinesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAnimalSelector(),
            if (_selectedAnimalId != null && vaccinesState.vaccines.isNotEmpty)
              _buildMonthSelector(vaccinesState.vaccines),
            Expanded(child: _buildContent(context, vaccinesState)),
          ],
        ),
      ),
      floatingActionButton: _selectedAnimalId != null
          ? FloatingActionButton(
              onPressed: () => _navigateToAddVaccine(context),
              tooltip: 'Adicionar Vacina',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PetivetiPageHeader(
        icon: Icons.vaccines,
        title: 'Vacinas',
        subtitle: 'Controle de vacinação dos pets',
        showBackButton: true,
        actions: [
          _buildHeaderAction(
            icon: _showStats ? Icons.analytics : Icons.analytics_outlined,
            onTap: () => setState(() => _showStats = !_showStats),
            tooltip: _showStats ? 'Ocultar estatísticas' : 'Mostrar estatísticas',
          ),
          _buildHeaderAction(
            icon: Icons.refresh,
            onTap: () => ref.read(vaccinesProvider.notifier).loadVaccines(),
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
            ref.read(vaccinesProvider.notifier).filterByAnimal(animalId);
          } else {
            ref.read(vaccinesProvider.notifier).clearAnimalFilter();
          }
        },
        hintText: 'Selecione um pet',
      ),
    );
  }

  Widget _buildMonthSelector(List<Vaccine> vaccines) {
    final months = _getMonths(vaccines);
    final selectedMonth = ref.watch(vaccinesProvider).selectedMonth;

    if (months.isEmpty) return const SizedBox.shrink();

    // Auto-select current month if none selected
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        final hasCurrentMonth = months.any((m) =>
            m.year == currentMonth.year && m.month == currentMonth.month);
        
        if (hasCurrentMonth) {
          ref.read(vaccinesProvider.notifier).selectMonth(currentMonth);
        } else {
          ref.read(vaccinesProvider.notifier).selectMonth(months.first);
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
                ref.read(vaccinesProvider.notifier).selectMonth(month);
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

  Widget _buildContent(BuildContext context, VaccinesState state) {
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
              onPressed: () {
                ref.read(vaccinesProvider.notifier).clearError();
                ref.read(vaccinesProvider.notifier).loadVaccines();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_selectedAnimalId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Selecione um pet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Escolha um pet acima para ver suas vacinas'),
          ],
        ),
      );
    }

    final filteredVaccines = _getFilteredVaccines(state.vaccines);

    if (filteredVaccines.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (_showStats) _buildStatsPanel(filteredVaccines),
        Expanded(child: _buildVaccinesList(filteredVaccines)),
      ],
    );
  }

  List<Vaccine> _getFilteredVaccines(List<Vaccine> vaccines) {
    final selectedMonth = ref.watch(vaccinesProvider).selectedMonth;
    if (selectedMonth == null) return vaccines;

    return vaccines.where((v) {
      final date = v.date;
      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();
  }

  Widget _buildStatsPanel(List<Vaccine> vaccines) {
    final total = vaccines.length;
    final overdue = vaccines.where((v) => v.isOverdue).length;
    final pending = vaccines.where((v) => v.isPending).length;
    final completed = vaccines.where((v) => v.isCompleted).length;

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
                  icon: Icons.vaccines,
                  label: 'Total',
                  value: total.toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning,
                  label: 'Vencidas',
                  value: overdue.toString(),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  label: 'Pendentes',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Concluídas',
                  value: completed.toString(),
                  color: Colors.green,
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

  Widget _buildVaccinesList(List<Vaccine> vaccines) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vaccinesProvider.notifier).loadVaccines();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vaccines.length,
        itemBuilder: (context, index) {
          final vaccine = vaccines[index];
          return Dismissible(
            key: ValueKey(vaccine.id),
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
            confirmDismiss: (direction) => _confirmDeleteVaccine(vaccine),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VaccineCard(
                vaccine: vaccine,
                onTap: () => _showVaccineDetails(context, vaccine),
                onEdit: () => _navigateToEditVaccine(context, vaccine),
                onDelete: () => _confirmDeleteVaccine(vaccine),
                showAnimalInfo: false,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vaccines_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma vacina encontrada',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione vacinas para acompanhar o histórico de vacinação',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<DateTime> _getMonths(List<Vaccine> vaccines) {
    if (vaccines.isEmpty) return [];
    
    final dates = vaccines.map((v) => v.date).toList();
    final uniqueMonths = <DateTime>{};
    
    for (final date in dates) {
      uniqueMonths.add(DateTime(date.year, date.month));
    }
    
    final sortedMonths = uniqueMonths.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first
    
    return sortedMonths;
  }

  void _navigateToAddVaccine(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddVaccineDialog(
        initialAnimalId: _selectedAnimalId,
      ),
    );
  }

  void _navigateToEditVaccine(BuildContext context, Vaccine vaccine) {
    showDialog<void>(
      context: context,
      builder: (context) => AddVaccineDialog(vaccine: vaccine),
    );
  }

  void _showVaccineDetails(BuildContext context, Vaccine vaccine) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    VaccineCard(
                      vaccine: vaccine,
                      onEdit: () {
                        Navigator.pop(context);
                        _navigateToEditVaccine(context, vaccine);
                      },
                      onDelete: () {
                        Navigator.pop(context);
                        _confirmDeleteVaccine(vaccine);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteVaccine(Vaccine vaccine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vacina'),
        content: Text('Tem certeza que deseja excluir "${vaccine.name}"?'),
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
      await ref.read(vaccinesProvider.notifier).deleteVaccine(vaccine.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacina excluída com sucesso')),
        );
      }
      return true;
    }
    return false;
  }
}
