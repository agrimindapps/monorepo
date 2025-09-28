import 'package:flutter/material.dart';
import '../../../../../../core/theme/plantis_colors.dart';
import '../../../../domain/entities/plant.dart';
import '../../../../domain/entities/plant_task.dart';

/// Aba de timeline com filtros por tipo e período, busca e agrupamento temporal
class PlantTaskHistoryTimelineTab extends StatefulWidget {
  final Plant plant;
  final List<PlantTask> completedTasks;

  const PlantTaskHistoryTimelineTab({
    super.key,
    required this.plant,
    required this.completedTasks,
  });

  @override
  State<PlantTaskHistoryTimelineTab> createState() =>
      _PlantTaskHistoryTimelineTabState();
}

class _PlantTaskHistoryTimelineTabState
    extends State<PlantTaskHistoryTimelineTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TextEditingController _searchController;

  // Filtros
  TaskType? _selectedType;
  String _selectedPeriod = 'all'; // all, week, month, quarter, year
  String _searchQuery = '';

  // Paginação
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra e ordena as tarefas baseado nos critérios
  List<PlantTask> _getFilteredTasks() {
    List<PlantTask> filtered = [...widget.completedTasks];

    // Filtro por tipo
    if (_selectedType != null) {
      filtered = filtered.where((task) => task.type == _selectedType).toList();
    }

    // Filtro por período
    if (_selectedPeriod != 'all') {
      final now = DateTime.now();
      DateTime? startDate;

      switch (_selectedPeriod) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'quarter':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
      }

      if (startDate != null) {
        filtered = filtered.where((task) {
          return task.completedDate != null &&
              task.completedDate!.isAfter(startDate!);
        }).toList();
      }
    }

    // Filtro por busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Ordenar por data de conclusão (mais recente primeiro)
    filtered.sort((a, b) => (b.completedDate ?? DateTime(1970))
        .compareTo(a.completedDate ?? DateTime(1970)));

    return filtered;
  }

  /// Agrupa tarefas por data
  Map<String, List<PlantTask>> _groupTasksByDate(List<PlantTask> tasks) {
    final grouped = <String, List<PlantTask>>{};

    for (final task in tasks) {
      if (task.completedDate == null) continue;

      final dateKey = _formatDateKey(task.completedDate!);
      grouped.putIfAbsent(dateKey, () => []).add(task);
    }

    return grouped;
  }

  /// Obtém tarefas para a página atual
  List<PlantTask> _getPaginatedTasks(List<PlantTask> tasks) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, tasks.length);
    return tasks.sublist(startIndex, endIndex);
  }

  /// Carrega mais tarefas
  void _loadMoreTasks() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Simular delay de carregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  /// Limpa todos os filtros
  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedPeriod = 'all';
      _searchQuery = '';
      _currentPage = 0;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTasks = _getFilteredTasks();
    final paginatedTasks = _getPaginatedTasks(filteredTasks);
    final groupedTasks = _groupTasksByDate(paginatedTasks);
    final hasMoreTasks = (_currentPage + 1) * _itemsPerPage < filteredTasks.length;

    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          // Seção de filtros e busca
          _buildFiltersSection(context),

          // Timeline de tarefas
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState(context)
                : _buildTimelineContent(context, groupedTasks, hasMoreTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Barra de busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por título ou descrição...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _currentPage = 0;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filtros por chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filtro por período
                      _buildPeriodFilter(context),

                      const SizedBox(width: 8),

                      // Filtro por tipo
                      _buildTypeFilter(context),

                      const SizedBox(width: 8),

                      // Botão limpar filtros
                      if (_selectedType != null || _selectedPeriod != 'all' || _searchQuery.isNotEmpty)
                        ActionChip(
                          label: const Text('Limpar'),
                          onPressed: _clearFilters,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                          labelStyle: const TextStyle(color: Colors.red),
                          avatar: const Icon(Icons.clear, size: 16, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      initialValue: _selectedPeriod,
      onSelected: (value) {
        setState(() {
          _selectedPeriod = value;
          _currentPage = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedPeriod != 'all'
              ? PlantisColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: _selectedPeriod != 'all'
                ? PlantisColors.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: _selectedPeriod != 'all'
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _getPeriodLabel(_selectedPeriod),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _selectedPeriod != 'all'
                    ? PlantisColors.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _selectedPeriod != 'all'
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('Todos os períodos')),
        const PopupMenuItem(value: 'week', child: Text('Última semana')),
        const PopupMenuItem(value: 'month', child: Text('Último mês')),
        const PopupMenuItem(value: 'quarter', child: Text('Últimos 3 meses')),
        const PopupMenuItem(value: 'year', child: Text('Último ano')),
      ],
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<TaskType?>(
      initialValue: _selectedType,
      onSelected: (value) {
        setState(() {
          _selectedType = value;
          _currentPage = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedType != null
              ? PlantisColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: _selectedType != null
                ? PlantisColors.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedType != null ? _getTaskTypeIcon(_selectedType!) : Icons.category,
              size: 16,
              color: _selectedType != null
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedType?.displayName ?? 'Todos os tipos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _selectedType != null
                    ? PlantisColors.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _selectedType != null
                  ? PlantisColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('Todos os tipos')),
        ...TaskType.values.map((type) => PopupMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_getTaskTypeIcon(type), size: 16),
                  const SizedBox(width: 8),
                  Text(type.displayName),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum cuidado encontrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou realizar alguns cuidados com sua planta.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedType != null || _selectedPeriod != 'all' || _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineContent(
    BuildContext context,
    Map<String, List<PlantTask>> groupedTasks,
    bool hasMoreTasks,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Timeline agrupada por data
          ...groupedTasks.entries.map((entry) {
            final dateKey = entry.key;
            final dayTasks = entry.value;

            return _buildTimelineGroup(context, dateKey, dayTasks);
          }),

          // Botão carregar mais
          if (hasMoreTasks) ...[
            const SizedBox(height: 24),
            _buildLoadMoreButton(context),
          ],

          // Indicador final
          if (!hasMoreTasks && groupedTasks.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildTimelineEnd(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineGroup(
    BuildContext context,
    String dateKey,
    List<PlantTask> dayTasks,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da data
        Container(
          margin: const EdgeInsets.only(bottom: 16, top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                PlantisColors.primary.withValues(alpha: 0.1),
                PlantisColors.primaryLight.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PlantisColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: PlantisColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                dateKey,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PlantisColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayTasks.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PlantisColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tarefas do dia
        ...dayTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          final isLast = index == dayTasks.length - 1;

          return _buildTimelineItem(context, task, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, PlantTask task, bool isLast) {
    final theme = Theme.of(context);
    final color = _getTaskTypeColor(task.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Task card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getTaskTypeIcon(task.type),
                        color: color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (task.completedDate != null)
                      Text(
                        _formatTime(task.completedDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: OutlinedButton.icon(
        onPressed: _isLoadingMore ? null : _loadMoreTasks,
        icon: _isLoadingMore
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more),
        label: Text(_isLoadingMore ? 'Carregando...' : 'Carregar mais'),
        style: OutlinedButton.styleFrom(
          foregroundColor: PlantisColors.primary,
          side: BorderSide(color: PlantisColors.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTimelineEnd(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Início do histórico',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'all':
        return 'Período';
      case 'week':
        return 'Semana';
      case 'month':
        return 'Mês';
      case 'quarter':
        return '3 meses';
      case 'year':
        return 'Ano';
      default:
        return 'Período';
    }
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == yesterday) {
      return 'Ontem';
    } else {
      final months = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ];

      if (date.year == now.year) {
        return '${date.day} de ${months[date.month - 1]}';
      } else {
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return PlantisColors.water;
      case TaskType.fertilizing:
        return PlantisColors.soil;
      case TaskType.pruning:
        return PlantisColors.leaf;
      case TaskType.sunlightCheck:
        return PlantisColors.sun;
      case TaskType.pestInspection:
        return Colors.red;
      case TaskType.replanting:
        return PlantisColors.primary;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlightCheck:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.replanting:
        return Icons.change_circle;
    }
  }
}