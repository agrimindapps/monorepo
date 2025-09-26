import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Comprehensive vaccine history visualization with analytics
class VaccineHistoryVisualization extends ConsumerStatefulWidget {
  final String? animalId;
  final bool showAnalytics;

  const VaccineHistoryVisualization({
    super.key,
    this.animalId,
    this.showAnalytics = true,
  });

  @override
  ConsumerState<VaccineHistoryVisualization> createState() => _VaccineHistoryVisualizationState();
}

class _VaccineHistoryVisualizationState extends ConsumerState<VaccineHistoryVisualization>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'all';
  String _selectedVaccineType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vaccinesState = ref.watch(vaccinesProvider);

    final filteredVaccines = _filterVaccines(vaccinesState.vaccines);

    return Column(
      children: [
        if (widget.showAnalytics) _buildAnalyticsHeader(theme, filteredVaccines),
        _buildFilterControls(theme),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTimelineView(theme, filteredVaccines),
              _buildCalendarView(theme, filteredVaccines),
              _buildAnalyticsView(theme, filteredVaccines),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsHeader(ThemeData theme, List<Vaccine> vaccines) {
    final stats = _calculateStatistics(vaccines);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              'Total',
              stats['total'].toString(),
              Icons.vaccines,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Este Ano',
              stats['thisYear'].toString(),
              Icons.calendar_today,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Vencidas',
              stats['overdue'].toString(),
              Icons.warning,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Eficácia',
              '${stats['effectiveness']}%',
              Icons.shield,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Calendário'),
              Tab(icon: Icon(Icons.analytics), text: 'Análise'),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all', _selectedTimeRange, (value) {
                  setState(() => _selectedTimeRange = value);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Este Ano', 'thisYear', _selectedTimeRange, (value) {
                  setState(() => _selectedTimeRange = value);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('6 Meses', '6months', _selectedTimeRange, (value) {
                  setState(() => _selectedTimeRange = value);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('30 Dias', '30days', _selectedTimeRange, (value) {
                  setState(() => _selectedTimeRange = value);
                }),
                const SizedBox(width: 16),
                Container(
                  height: 24,
                  width: 1,
                  color: theme.dividerColor,
                ),
                const SizedBox(width: 16),
                _buildFilterChip('Todas Vacinas', 'all', _selectedVaccineType, (value) {
                  setState(() => _selectedVaccineType = value);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Essenciais', 'required', _selectedVaccineType, (value) {
                  setState(() => _selectedVaccineType = value);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Opcionais', 'optional', _selectedVaccineType, (value) {
                  setState(() => _selectedVaccineType = value);
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentValue, ValueChanged<String> onChanged) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
    );
  }

  Widget _buildTimelineView(ThemeData theme, List<Vaccine> vaccines) {
    final groupedVaccines = _groupVaccinesByDate(vaccines);
    final sortedDates = groupedVaccines.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    if (sortedDates.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final vaccinesOnDate = groupedVaccines[date]!;
        final isLastItem = index == sortedDates.length - 1;

        return _buildTimelineItem(theme, date, vaccinesOnDate, isLastItem);
      },
    );
  }

  Widget _buildTimelineItem(ThemeData theme, DateTime date, List<Vaccine> vaccines, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDateHeader(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...vaccines.map((vaccine) => _buildVaccineHistoryCard(theme, vaccine)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineHistoryCard(ThemeData theme, Vaccine vaccine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getVaccineIcon(vaccine),
                  color: _getVaccineColor(vaccine),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vaccine.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getVaccineColor(vaccine).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vaccine.displayStatus,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getVaccineColor(vaccine),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  vaccine.veterinarian,
                  style: theme.textTheme.bodySmall,
                ),
                if (vaccine.batch != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Lote: ${vaccine.batch}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (vaccine.nextDueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Próxima: ${_formatDate(vaccine.nextDueDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: vaccine.isOverdue ? Colors.red : null,
                      fontWeight: vaccine.isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ],
            if (vaccine.notes != null && vaccine.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                vaccine.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(ThemeData theme, List<Vaccine> vaccines) {
    // Implementation for calendar view would go here
    // This would show vaccines in a monthly calendar format
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Visualização de Calendário'),
          Text('Em desenvolvimento...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView(ThemeData theme, List<Vaccine> vaccines) {
    final analytics = _generateAdvancedAnalytics(vaccines);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard(
            theme,
            'Eficácia por Tipo',
            _buildEffectivenessChart(theme, analytics['effectiveness'] as Map<String, double>),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            theme,
            'Tendências Anuais',
            _buildTrendChart(theme, analytics['trends'] as Map<String, int>),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            theme,
            'Distribuição de Veterinários',
            _buildVeterinarianDistribution(theme, analytics['veterinarians'] as Map<String, int>),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            theme,
            'Próximas Ações Recomendadas',
            _buildRecommendations(theme, vaccines),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(ThemeData theme, String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildEffectivenessChart(ThemeData theme, Map<String, double> effectiveness) {
    return Column(
      children: effectiveness.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(entry.key, style: theme.textTheme.bodyMedium),
              ),
              Expanded(
                flex: 5,
                child: LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(
                    entry.value >= 80 ? Colors.green : 
                    entry.value >= 60 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${entry.value.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart(ThemeData theme, Map<String, int> trends) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Gráfico de Tendências\n(Implementação futura)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildVeterinarianDistribution(ThemeData theme, Map<String, int> distribution) {
    return Column(
      children: distribution.entries.take(5).map((entry) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(entry.key.substring(0, 1).toUpperCase()),
          ),
          title: Text(entry.key),
          trailing: Text('${entry.value} vacinas'),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations(ThemeData theme, List<Vaccine> vaccines) {
    final recommendations = _generateRecommendations(vaccines);

    return Column(
      children: recommendations.map((recommendation) {
        return ListTile(
          leading: Icon(
            recommendation['icon'] as IconData,
            color: recommendation['color'] as Color,
          ),
          title: Text(recommendation['title'] as String),
          subtitle: Text(recommendation['description'] as String),
          trailing: recommendation['urgent'] as bool 
              ? const Icon(Icons.priority_high, color: Colors.red)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma vacina encontrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou adicionar vacinas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<Vaccine> _filterVaccines(List<Vaccine> vaccines) {
    List<Vaccine> filtered = widget.animalId != null 
        ? vaccines.where((v) => v.animalId == widget.animalId).toList()
        : vaccines;

    // Filter by time range
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case 'thisYear':
        filtered = filtered.where((v) => v.date.year == now.year).toList();
        break;
      case '6months':
        final sixMonthsAgo = now.subtract(const Duration(days: 180));
        filtered = filtered.where((v) => v.date.isAfter(sixMonthsAgo)).toList();
        break;
      case '30days':
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        filtered = filtered.where((v) => v.date.isAfter(thirtyDaysAgo)).toList();
        break;
    }

    // Filter by vaccine type
    switch (_selectedVaccineType) {
      case 'required':
        filtered = filtered.where((v) => v.isRequired).toList();
        break;
      case 'optional':
        filtered = filtered.where((v) => !v.isRequired).toList();
        break;
    }

    return filtered;
  }

  Map<String, int> _calculateStatistics(List<Vaccine> vaccines) {
    final now = DateTime.now();
    final thisYear = vaccines.where((v) => v.date.year == now.year).length;
    final overdue = vaccines.where((v) => v.isOverdue).length;
    final total = vaccines.length;
    
    // Calculate effectiveness (simplified)
    final completed = vaccines.where((v) => v.isCompleted).length;
    final effectiveness = total > 0 ? ((completed / total) * 100).round() : 0;

    return {
      'total': total,
      'thisYear': thisYear,
      'overdue': overdue,
      'effectiveness': effectiveness,
    };
  }

  Map<DateTime, List<Vaccine>> _groupVaccinesByDate(List<Vaccine> vaccines) {
    final Map<DateTime, List<Vaccine>> grouped = {};
    
    for (final vaccine in vaccines) {
      final dateKey = DateTime(vaccine.date.year, vaccine.date.month, vaccine.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(vaccine);
    }
    
    return grouped;
  }

  Map<String, dynamic> _generateAdvancedAnalytics(List<Vaccine> vaccines) {
    // Effectiveness by vaccine type
    final Map<String, List<Vaccine>> byType = {};
    for (final vaccine in vaccines) {
      byType.putIfAbsent(vaccine.name, () => []).add(vaccine);
    }
    
    final effectiveness = byType.map((key, value) {
      final completed = value.where((v) => v.isCompleted).length;
      final rate = value.isNotEmpty ? (completed / value.length * 100) : 0.0;
      return MapEntry(key, rate);
    });

    // Trends (simplified)
    final trends = <String, int>{};
    for (int year = DateTime.now().year - 2; year <= DateTime.now().year; year++) {
      trends[year.toString()] = vaccines.where((v) => v.date.year == year).length;
    }

    // Veterinarian distribution
    final veterinarians = <String, int>{};
    for (final vaccine in vaccines) {
      veterinarians[vaccine.veterinarian] = 
          (veterinarians[vaccine.veterinarian] ?? 0) + 1;
    }

    return {
      'effectiveness': effectiveness,
      'trends': trends,
      'veterinarians': veterinarians,
    };
  }

  List<Map<String, dynamic>> _generateRecommendations(List<Vaccine> vaccines) {
    final recommendations = <Map<String, dynamic>>[];
    
    final overdue = vaccines.where((v) => v.isOverdue).toList();
    if (overdue.isNotEmpty) {
      recommendations.add({
        'icon': Icons.warning,
        'color': Colors.red,
        'title': 'Vacinas em Atraso',
        'description': '${overdue.length} vacinas precisam de atenção urgente',
        'urgent': true,
      });
    }

    final dueSoon = vaccines.where((v) => v.isDueSoon).toList();
    if (dueSoon.isNotEmpty) {
      recommendations.add({
        'icon': Icons.schedule,
        'color': Colors.orange,
        'title': 'Vacinas Próximas',
        'description': '${dueSoon.length} vacinas vencem em breve',
        'urgent': false,
      });
    }

    recommendations.add({
      'icon': Icons.analytics,
      'color': Colors.blue,
      'title': 'Revisar Protocolo',
      'description': 'Analise a eficácia do protocolo atual',
      'urgent': false,
    });

    return recommendations;
  }

  IconData _getVaccineIcon(Vaccine vaccine) {
    if (vaccine.isCompleted) return Icons.check_circle;
    if (vaccine.isOverdue) return Icons.warning;
    if (vaccine.isDueSoon) return Icons.schedule;
    return Icons.vaccines;
  }

  Color _getVaccineColor(Vaccine vaccine) {
    if (vaccine.isCompleted) return Colors.green;
    if (vaccine.isOverdue) return Colors.red;
    if (vaccine.isDueSoon) return Colors.orange;
    return Colors.blue;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateHeader(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }
}