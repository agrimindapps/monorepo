import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../animals/presentation/providers/animals_provider.dart';
import '../../domain/entities/weight.dart';
import '../providers/weights_provider.dart';
import '../widgets/add_weight_form.dart';
import '../widgets/body_condition_correlation.dart';
import '../widgets/weight_card.dart';
import '../widgets/weight_chart_visualization.dart';
import '../widgets/weight_goal_management.dart';

class WeightPage extends ConsumerStatefulWidget {
  const WeightPage({super.key});

  @override
  ConsumerState<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends ConsumerState<WeightPage> {
  String? _selectedAnimalId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weightsProvider.notifier).loadWeights();
      ref.read(animalsProvider.notifier).loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightsState = ref.watch(weightsProvider);
    final animalsState = ref.watch(animalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Peso'),
        actions: [
          if (animalsState.animals.isNotEmpty)
            PopupMenuButton<String?>(
              icon: Icon(
                _selectedAnimalId != null ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _selectedAnimalId != null ? theme.colorScheme.primary : null,
              ),
              onSelected: (animalId) {
                setState(() {
                  _selectedAnimalId = animalId;
                });
                
                if (animalId != null) {
                  ref.read(weightsProvider.notifier).loadWeightsByAnimal(animalId);
                } else {
                  ref.read(weightsProvider.notifier).loadWeights();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.pets),
                      SizedBox(width: 8),
                      Text('Todos os animais'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...animalsState.animals.map((animal) => PopupMenuItem<String>(
                      value: animal.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primary.withAlpha(51),
                            child: Text(
                              animal.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(animal.name)),
                          if (_selectedAnimalId == animal.id)
                            Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              switch (action) {
                case 'sort':
                  _showSortMenu(context, weightsState);
                  break;
                case 'charts':
                  _navigateToCharts(context);
                  break;
                case 'goals':
                  _navigateToGoals(context);
                  break;
                case 'correlation':
                  _navigateToCorrelation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: Icon(Icons.sort),
                  title: Text('Ordenar'),
                ),
              ),
              const PopupMenuItem(
                value: 'charts',
                child: ListTile(
                  leading: Icon(Icons.show_chart),
                  title: Text('Gráficos Avançados'),
                ),
              ),
              const PopupMenuItem(
                value: 'goals',
                child: ListTile(
                  leading: Icon(Icons.track_changes),
                  title: Text('Metas de Peso'),
                ),
              ),
              const PopupMenuItem(
                value: 'correlation',
                child: ListTile(
                  leading: Icon(Icons.fitness_center),
                  title: Text('Correlação BCS'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, weightsState, animalsState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddWeight(context),
        tooltip: 'Adicionar Registro de Peso',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeightsState weightsState, AnimalsState animalsState) {
    if (weightsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (weightsState.error != null) {
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
              'Erro ao carregar registros',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              weightsState.error!,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(weightsProvider.notifier).clearError();
                if (_selectedAnimalId != null) {
                  ref.read(weightsProvider.notifier).loadWeightsByAnimal(_selectedAnimalId!);
                } else {
                  ref.read(weightsProvider.notifier).loadWeights();
                }
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (animalsState.animals.isEmpty) {
      return _buildNoAnimalsState(context);
    }

    final weights = weightsState.sortedWeights;

    if (weights.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (weightsState.statistics != null && weights.isNotEmpty)
          _buildStatisticsHeader(context, weightsState),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_selectedAnimalId != null) {
                await ref.read(weightsProvider.notifier).loadWeightsByAnimal(_selectedAnimalId!);
              } else {
                await ref.read(weightsProvider.notifier).loadWeights();
              }
            },
            child: ListView.builder(
              itemCount: weights.length,
              itemBuilder: (context, index) {
                final weight = weights[index];
                final previousWeight = index < weights.length - 1 ? weights[index + 1] : null;
                
                return WeightCard(
                  weight: weight,
                  previousWeight: previousWeight,
                  onTap: () => _showWeightDetails(context, weight),
                  onEdit: () => _navigateToEditWeight(context, weight),
                  onDelete: () => _deleteWeight(context, weight.id),
                  showAnimalInfo: _selectedAnimalId == null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsHeader(BuildContext context, WeightsState state) {
    final theme = Theme.of(context);
    final statistics = state.statistics!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(76)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Peso Atual',
                  statistics.currentWeight?.toStringAsFixed(1) ?? 'N/A',
                  'kg',
                  Icons.monitor_weight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Média',
                  statistics.averageWeight?.toStringAsFixed(1) ?? 'N/A',
                  'kg',
                  Icons.timeline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Registros',
                  statistics.totalRecords.toString(),
                  '',
                  Icons.history,
                ),
              ),
            ],
          ),
          if (statistics.overallTrend != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getTrendIcon(statistics.overallTrend!),
                  color: _getTrendColor(statistics.overallTrend!),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tendência: ${statistics.overallTrend!.displayName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getTrendColor(statistics.overallTrend!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, String unit, IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoAnimalsState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum animal cadastrado',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre um animal primeiro para começar o controle de peso',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
            },
            icon: const Icon(Icons.pets),
            label: const Text('Cadastrar Animal'),
          ),
        ],
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
            Icons.monitor_weight_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedAnimalId != null 
                ? 'Nenhum registro de peso encontrado'
                : 'Nenhum registro de peso',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedAnimalId != null
                ? 'Adicione o primeiro registro de peso para este animal'
                : 'Comece a acompanhar o peso dos seus pets',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _navigateToAddWeight(context),
            icon: const Icon(Icons.add),
            label: const Text('Primeiro Registro'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddWeight(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AddWeightForm(
          initialAnimalId: _selectedAnimalId,
        ),
      ),
    );
  }

  void _navigateToEditWeight(BuildContext context, Weight weight) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AddWeightForm(weight: weight),
      ),
    );
  }

  void _showWeightDetails(BuildContext context, Weight weight) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => DecoratedBox(
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
                    WeightCard(
                      weight: weight,
                      onEdit: () {
                        Navigator.pop(context);
                        _navigateToEditWeight(context, weight);
                      },
                      onDelete: () {
                        Navigator.pop(context);
                        _deleteWeight(context, weight.id);
                      },
                      showTrend: false,
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

  void _deleteWeight(BuildContext context, String weightId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: const Text('Tem certeza que deseja excluir este registro de peso? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(weightsProvider.notifier).deleteWeight(weightId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registro de peso excluído com sucesso'),
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

  Color _getTrendColor(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Colors.blue;
      case WeightTrend.losing:
        return Colors.orange;
      case WeightTrend.stable:
        return Colors.green;
    }
  }

  IconData _getTrendIcon(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Icons.trending_up;
      case WeightTrend.losing:
        return Icons.trending_down;
      case WeightTrend.stable:
        return Icons.trending_flat;
    }
  }

  void _showSortMenu(BuildContext context, WeightsState weightsState) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WeightSortOrder.values
              .map((order) => RadioListTile<WeightSortOrder>(
                    title: Text(order.displayName),
                    value: order,
                    groupValue: weightsState.sortOrder,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(weightsProvider.notifier).setSortOrder(value);
                      }
                      Navigator.pop(context);
                    },
                  ))
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

  void _navigateToCharts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Gráficos de Peso'),
          ),
          body: WeightChartVisualization(
            animalId: _selectedAnimalId,
            showInteractiveMode: true,
          ),
        ),
      ),
    );
  }

  void _navigateToGoals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => WeightGoalManagement(
          animalId: _selectedAnimalId,
          onGoalsUpdated: () {
            if (_selectedAnimalId != null) {
              ref.read(weightsProvider.notifier).loadWeightsByAnimal(_selectedAnimalId!);
            } else {
              ref.read(weightsProvider.notifier).loadWeights();
            }
          },
        ),
      ),
    );
  }

  void _navigateToCorrelation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Correlação Peso vs BCS'),
          ),
          body: BodyConditionCorrelation(
            animalId: _selectedAnimalId,
            showInteractiveMode: true,
          ),
        ),
      ),
    );
  }
}
