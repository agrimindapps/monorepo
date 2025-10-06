import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Enhanced dashboard cards showing vaccine statistics with visual appeal
class VaccineDashboardCards extends ConsumerWidget {
  const VaccineDashboardCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statisticsAsync = ref.watch(vaccineStatisticsProvider);
    final vaccinesState = ref.watch(vaccinesProvider);

    return statisticsAsync.when(
      loading: () => _buildLoadingCards(),
      error: (error, stackTrace) => _buildErrorCard(theme, error.toString()),
      data: (statistics) => _buildDashboardCards(
        context,
        theme,
        statistics,
        vaccinesState,
      ),
    );
  }

  Widget _buildLoadingCards() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar estatísticas',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards(
    BuildContext context,
    ThemeData theme,
    Map<String, int> statistics,
    VaccinesState state,
  ) {
    final cards = [
      _DashboardCardData(
        title: 'Total',
        value: state.totalVaccines.toString(),
        subtitle: 'vacinas registradas',
        icon: Icons.vaccines,
        color: theme.colorScheme.primary,
        onTap: () => _onCardTap(context, VaccinesFilter.all),
      ),
      _DashboardCardData(
        title: 'Vencidas',
        value: state.overdueCount.toString(),
        subtitle: 'urgente!',
        icon: Icons.warning,
        color: Colors.red,
        onTap: () => _onCardTap(context, VaccinesFilter.overdue),
        isUrgent: state.overdueCount > 0,
      ),
      _DashboardCardData(
        title: 'Pendentes',
        value: state.pendingCount.toString(),
        subtitle: 'aguardando',
        icon: Icons.schedule,
        color: Colors.orange,
        onTap: () => _onCardTap(context, VaccinesFilter.pending),
      ),
      _DashboardCardData(
        title: 'Concluídas',
        value: state.completedCount.toString(),
        subtitle: 'finalizadas',
        icon: Icons.check_circle,
        color: Colors.green,
        onTap: () => _onCardTap(context, VaccinesFilter.completed),
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => _buildDashboardCard(context, theme, cards[index]),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    ThemeData theme,
    _DashboardCardData cardData,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: cardData.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  cardData.color.withValues(alpha: 0.1),
                  cardData.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: cardData.isUrgent
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cardData.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cardData.color,
                      ),
                    ),
                    if (cardData.isUrgent)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.priority_high,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      cardData.icon,
                      size: 32,
                      color: cardData.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardData.value,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cardData.color,
                            ),
                          ),
                          Text(
                            cardData.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTap(BuildContext context, VaccinesFilter filter) {
  }
}

class _DashboardCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isUrgent;

  const _DashboardCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isUrgent = false,
  });
}

/// Enhanced vaccine timeline widget showing upcoming vaccines
class VaccineTimeline extends ConsumerWidget {
  final String? animalId;
  
  const VaccineTimeline({super.key, this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vaccinesState = ref.watch(vaccinesProvider);
    final upcomingVaccines = vaccinesState.vaccines
        .where((vaccine) => 
            (animalId == null || vaccine.animalId == animalId) &&
            (vaccine.isDueSoon || vaccine.isDueToday || vaccine.isOverdue))
        .toList()
      ..sort((a, b) {
        if (a.nextDueDate == null && b.nextDueDate == null) return 0;
        if (a.nextDueDate == null) return 1;
        if (b.nextDueDate == null) return -1;
        return a.nextDueDate!.compareTo(b.nextDueDate!);
      });

    if (upcomingVaccines.isEmpty) {
      return _buildEmptyTimeline(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Próximas Vacinas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: upcomingVaccines.length,
            itemBuilder: (context, index) => _buildTimelineItem(
              theme,
              upcomingVaccines[index],
              index == upcomingVaccines.length - 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTimeline(ThemeData theme) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Todas as vacinas em dia!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nenhuma vacina vencida ou próxima do vencimento',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ThemeData theme, Vaccine vaccine, bool isLast) {
    final isOverdue = vaccine.isOverdue;
    final isDueToday = vaccine.isDueToday;
    final color = isOverdue ? Colors.red : (isDueToday ? Colors.orange : Colors.blue);

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  isOverdue 
                      ? Icons.warning 
                      : isDueToday 
                          ? Icons.today 
                          : Icons.schedule,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.scaffoldBackgroundColor,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
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
                    Expanded(
                      child: Text(
                        vaccine.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vaccine.nextDoseInfo,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      vaccine.veterinarian,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (vaccine.notes != null && vaccine.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vaccine.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
