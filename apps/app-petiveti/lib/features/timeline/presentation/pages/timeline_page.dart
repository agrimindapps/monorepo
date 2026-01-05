import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../../appointments/presentation/providers/appointments_providers.dart';
import '../../../medications/presentation/providers/medications_providers.dart';
import '../../../vaccines/presentation/providers/vaccines_providers.dart';
import '../../../weight/presentation/providers/weight_providers.dart';
import '../../domain/entities/timeline_item.dart';
import '../providers/timeline_providers.dart';
import '../widgets/timeline_date_group.dart';

/// Timeline Page - Página principal mostrando timeline de atividades dos pets
/// 
/// Exibe todos os eventos (vacinas, medicamentos, consultas, peso, despesas) em ordem 
/// cronológica, agrupados por data. Timeline unificada sem filtros por tipo.
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  String? _selectedAnimalId;
  bool _showAllAnimals = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Carrega preferências salvas
    final prefs = await SharedPreferences.getInstance();
    final savedAnimalId = prefs.getString('selected_animal_id');
    
    if (mounted) {
      setState(() {
        _selectedAnimalId = savedAnimalId;
        _showAllAnimals = savedAnimalId == null;
      });
      _loadAllData();
    }
  }

  void _loadAllData() {
    // Carrega dados de cada provider
    ref.read(vaccinesProvider.notifier).loadVaccines();
    ref.read(medicationsProvider.notifier).loadMedications();
    ref.read(weightsProvider.notifier).loadWeights();
    
    // Carrega appointments se um animal estiver selecionado
    if (_selectedAnimalId != null) {
      ref.read(appointmentsProvider.notifier).loadAppointments(_selectedAnimalId!);
    }
    
    // Carrega timeline
    ref.read(timelineProvider.notifier).loadTimeline(
      animalId: _showAllAnimals ? null : _selectedAnimalId,
    );
  }

  void _onAnimalChanged(String? animalId) {
    setState(() {
      _selectedAnimalId = animalId;
      _showAllAnimals = animalId == null;
    });
    
    if (animalId != null) {
      ref.read(appointmentsProvider.notifier).loadAppointments(animalId);
    }
    
    ref.read(timelineProvider.notifier).loadTimeline(
      animalId: _showAllAnimals ? null : animalId,
    );
  }

  void _onItemTap(TimelineItem item) {
    // Navega para a página correspondente
    switch (item.type) {
      case TimelineEventType.vaccine:
        context.go('/vaccines');
        break;
      case TimelineEventType.medication:
        context.go('/medications');
        break;
      case TimelineEventType.appointment:
        context.go('/appointments');
        break;
      case TimelineEventType.weight:
        context.go('/weight');
        break;
      case TimelineEventType.expense:
        context.go('/expenses');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    final timelineState = ref.watch(timelineProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Animal Selector
            _buildAnimalSelector(context),

            // Content
            Expanded(
              child: _buildContent(context, animalsState, timelineState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: PetivetiPageHeader(
        icon: Icons.timeline,
        title: 'Timeline',
        subtitle: 'Histórico completo dos seus pets',
        actions: [
          // Toggle all animals
          IconButton(
            icon: Icon(
              _showAllAnimals ? Icons.pets : Icons.filter_alt,
              color: Colors.white,
            ),
            tooltip: _showAllAnimals ? 'Mostrando todos' : 'Filtrado por pet',
            onPressed: () {
              setState(() {
                _showAllAnimals = !_showAllAnimals;
              });
              ref.read(timelineProvider.notifier).loadTimeline(
                animalId: _showAllAnimals ? null : _selectedAnimalId,
              );
            },
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalSelector(BuildContext context) {
    if (_showAllAnimals) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.pets,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mostrando todos os pets',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllAnimals = false;
                  });
                },
                child: const Text('Filtrar'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        onAnimalChanged: _onAnimalChanged,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AnimalsState animalsState,
    TimelineState timelineState,
  ) {
    // Loading state
    if (timelineState.isLoading && timelineState.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (timelineState.error != null) {
      return _buildErrorState(context, timelineState.error!);
    }

    // No animals
    if (animalsState.animals.isEmpty) {
      return _buildEmptyAnimalsState(context);
    }

    // Empty state
    if (timelineState.items.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group items by date
    final groupedItems = _groupItemsByDate(timelineState.items);
    final sortedDates = groupedItems.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () async => _loadAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dateItems = groupedItems[date]!;

          return TimelineDateGroup(
            date: date,
            items: dateItems,
            isFirstGroup: index == 0,
            onItemTap: _onItemTap,
          );
        },
      ),
    );
  }

  Map<DateTime, List<TimelineItem>> _groupItemsByDate(List<TimelineItem> items) {
    final grouped = <DateTime, List<TimelineItem>>{};
    for (final item in items) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(item);
      } else {
        grouped[dateKey] = [item];
      }
    }
    return grouped;
  }

  Widget _buildEmptyAnimalsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum pet cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre seu primeiro pet para começar a acompanhar as atividades',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/animals'),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Pet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade encontrada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Comece a registrar vacinas, consultas, medicamentos e outras atividades',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
