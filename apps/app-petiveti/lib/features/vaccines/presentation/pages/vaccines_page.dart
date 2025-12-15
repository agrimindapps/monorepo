import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';
import '../widgets/add_vaccine_dialog.dart';
import '../widgets/vaccine_calendar_widget.dart';
import '../widgets/vaccine_card.dart';
import '../widgets/vaccine_dashboard_cards.dart';
import '../widgets/vaccine_history_visualization.dart';
import '../widgets/vaccine_reminder_management.dart';
import '../widgets/vaccine_scheduling_interface.dart';

class VaccinesPage extends ConsumerStatefulWidget {
  const VaccinesPage({super.key});

  @override
  ConsumerState<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends ConsumerState<VaccinesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showCalendarView = false;
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
    ); // Added dashboard tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaccinesProvider.notifier).loadVaccines();
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
    final vaccinesState = ref.watch(vaccinesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PetivetiPageHeader(
              icon: Icons.vaccines,
              title: 'Vacinas',
              subtitle: 'Controle de vacinação dos pets',
              actions: [
                _buildHeaderAction(
                  icon: _showCalendarView ? Icons.list : Icons.calendar_view_month,
                  onTap: () => setState(() => _showCalendarView = !_showCalendarView),
                  tooltip: _showCalendarView ? 'Ver Lista' : 'Ver Calendário',
                ),
                _buildHeaderAction(
                  icon: Icons.search,
                  onTap: () => _showSearchDialog(context),
                  tooltip: 'Buscar',
                ),
                _buildHeaderPopupMenu(),
              ],
            ),
            _buildAnimalSelector(),
            _buildTabBar(vaccinesState),
            Expanded(child: _buildBody(context, vaccinesState)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVaccine(context),
        tooltip: 'Adicionar Vacina',
        child: const Icon(Icons.add),
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

  Widget _buildHeaderPopupMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
      onSelected: (action) {
        switch (action) {
          case 'filter':
            _showFilterMenu(context);
            break;
          case 'history':
            _navigateToHistory(context);
            break;
          case 'reminders':
            _navigateToReminders(context);
            break;
          case 'schedule':
            _navigateToAdvancedScheduling(context);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'filter',
          child: ListTile(
            leading: Icon(Icons.filter_list),
            title: Text('Filtros'),
          ),
        ),
        const PopupMenuItem(
          value: 'history',
          child: ListTile(
            leading: Icon(Icons.history),
            title: Text('Histórico Completo'),
          ),
        ),
        const PopupMenuItem(
          value: 'reminders',
          child: ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Gerenciar Lembretes'),
          ),
        ),
        const PopupMenuItem(
          value: 'schedule',
          child: ListTile(
            leading: Icon(Icons.schedule_send),
            title: Text('Agendamento Avançado'),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(VaccinesState vaccinesState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(icon: Icon(Icons.dashboard), text: 'Painel'),
          Tab(
            icon: const Icon(Icons.list),
            text: 'Todas (${vaccinesState.totalVaccines})',
          ),
          Tab(
            icon: const Icon(Icons.warning),
            text: 'Vencidas (${vaccinesState.overdueCount})',
          ),
          Tab(
            icon: const Icon(Icons.schedule),
            text: 'Pendentes (${vaccinesState.pendingCount})',
          ),
          Tab(
            icon: const Icon(Icons.check_circle),
            text: 'Concluídas (${vaccinesState.completedCount})',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, VaccinesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar vacinas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(vaccinesProvider.notifier).clearError();
                ref.read(vaccinesProvider.notifier).loadVaccines();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_showCalendarView) {
      return VaccineCalendarWidget(
        onVaccineSelected: (vaccine) => _showVaccineDetails(context, vaccine),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(context, state),
        _buildVaccinesList(context, state.filteredVaccines),
        _buildVaccinesList(
          context,
          state.vaccines.where((v) => v.isOverdue).toList(),
        ),
        _buildVaccinesList(
          context,
          state.vaccines.where((v) => v.isPending).toList(),
        ),
        _buildVaccinesList(
          context,
          state.vaccines.where((v) => v.isCompleted).toList(),
        ),
      ],
    );
  }

  Widget _buildDashboardTab(BuildContext context, VaccinesState state) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          VaccineDashboardCards(),
          SizedBox(height: 8),
          VaccineTimeline(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVaccinesList(BuildContext context, List<Vaccine> vaccines) {
    if (vaccines.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vaccinesProvider.notifier).loadVaccines();
      },
      child: ListView.builder(
        itemCount: vaccines.length,
        itemBuilder: (context, index) {
          final vaccine = vaccines[index];
          return VaccineCard(
            vaccine: vaccine,
            onTap: () => _showVaccineDetails(context, vaccine),
            onEdit: () => _navigateToEditVaccine(context, vaccine),
            onDelete: () => _deleteVaccine(context, vaccine.id),
            showAnimalInfo: true,
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
            'Adicione vacinas para acompanhar o histórico de vacinação dos seus pets',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _navigateToAddVaccine(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeira Vacina'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Vacinas'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Digite o nome da vacina ou veterinário...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            ref.read(vaccinesProvider.notifier).searchVaccines(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
              ref.read(vaccinesProvider.notifier).clearSearch();
            },
            child: const Text('Limpar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(vaccinesProvider.notifier)
                  .searchVaccines(_searchController.text);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddVaccine(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddVaccineDialog(),
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
                        _deleteVaccine(context, vaccine.id);
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

  void _deleteVaccine(BuildContext context, String vaccineId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vacina'),
        content: const Text(
          'Tem certeza que deseja excluir esta vacina? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(vaccinesProvider.notifier).deleteVaccine(vaccineId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vacina excluída com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    final vaccinesState = ref.watch(vaccinesProvider);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: VaccinesFilter.values
              .map(
                (filter) => RadioListTile<VaccinesFilter>.adaptive(
                  title: Text(filter.displayName),
                  value: filter,
                  groupValue: vaccinesState.filter, // ignore: deprecated_member_use
                  onChanged: (value) { // ignore: deprecated_member_use
                    if (value != null) {
                      ref.read(vaccinesProvider.notifier).setFilter(value);
                    }
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Histórico de Vacinas')),
          body: const VaccineHistoryVisualization(showAnalytics: true),
        ),
      ),
    );
  }

  void _navigateToReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const VaccineReminderManagement(),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: (animalId) {
          setState(() {
            _selectedAnimalId = animalId;
          });
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

  void _navigateToAdvancedScheduling(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VaccineSchedulingInterface(
          onScheduled: () {
            ref.read(vaccinesProvider.notifier).loadVaccines();
          },
        ),
      ),
    );
  }
}
