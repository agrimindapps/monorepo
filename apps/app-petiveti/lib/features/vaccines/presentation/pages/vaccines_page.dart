import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';
import '../widgets/add_vaccine_form.dart';
import '../widgets/vaccine_card.dart';

class VaccinesPage extends ConsumerStatefulWidget {
  const VaccinesPage({super.key});

  @override
  ConsumerState<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends ConsumerState<VaccinesPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load vaccines on page initialization
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
    final theme = Theme.of(context);
    final vaccinesState = ref.watch(vaccinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<VaccinesFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(vaccinesProvider.notifier).setFilter(filter);
            },
            itemBuilder: (context) => VaccinesFilter.values
                .map((filter) => PopupMenuItem(
                      value: filter,
                      child: Row(
                        children: [
                          Icon(
                            filter == vaccinesState.filter 
                                ? Icons.radio_button_checked 
                                : Icons.radio_button_unchecked,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(filter.displayName),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
      ),
      body: _buildBody(context, vaccinesState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVaccine(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Vacina',
      ),
    );
  }

  Widget _buildBody(BuildContext context, VaccinesState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildVaccinesList(context, state.filteredVaccines),
        _buildVaccinesList(context, state.vaccines.where((v) => v.isOverdue).toList()),
        _buildVaccinesList(context, state.vaccines.where((v) => v.isPending).toList()),
        _buildVaccinesList(context, state.vaccines.where((v) => v.isCompleted).toList()),
      ],
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
    showDialog(
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
              ref.read(vaccinesProvider.notifier).searchVaccines(_searchController.text);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddVaccine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AddVaccineForm(),
      ),
    );
  }

  void _navigateToEditVaccine(BuildContext context, Vaccine vaccine) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AddVaccineForm(vaccine: vaccine),
      ),
    );
  }

  void _showVaccineDetails(BuildContext context, Vaccine vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vacina'),
        content: const Text('Tem certeza que deseja excluir esta vacina? Esta ação não pode ser desfeita.'),
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
}