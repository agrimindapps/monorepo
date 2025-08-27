import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize data loading with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  void _loadHomeData() {
    ref.read(homeNotificationsProvider.notifier).loadNotifications();
    ref.read(homeStatsProvider.notifier).loadStats();
    ref.read(homeStatusProvider.notifier).checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(homeNotificationsProvider);
    final statsState = ref.watch(homeStatsProvider);
    final statusState = ref.watch(homeStatusProvider);
    final hasUnreadNotifications = ref.watch(hasUnreadNotificationsProvider);
    final hasUrgentAlerts = ref.watch(hasUrgentAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetiVeti'),
        centerTitle: true,
        actions: [
          // Notification indicator
          Semantics(
            label: hasUrgentAlerts 
              ? 'Notificações urgentes, ${notificationsState.unreadCount} não lidas'
              : hasUnreadNotifications 
                ? 'Notificações, ${notificationsState.unreadCount} não lidas'
                : 'Notificações',
            hint: 'Toque para visualizar suas notificações',
            button: true,
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    hasUrgentAlerts ? Icons.notifications_active : Icons.notifications,
                    color: hasUrgentAlerts ? Theme.of(context).colorScheme.error : null,
                  ),
                  onPressed: _showNotifications,
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${notificationsState.unreadCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Status indicator
          Semantics(
            label: statusState.isOnline 
              ? 'Online, dados sincronizados'
              : 'Offline, usando dados locais',
            hint: 'Toque para ver detalhes do status de conexão',
            button: true,
            child: IconButton(
              icon: Icon(
                statusState.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: statusState.isOnline 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      statusState.isOnline 
                        ? 'Online - Última atualização: ${_formatTime(statusState.lastUpdated)}'
                        : 'Offline - Dados locais',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: statusState.isLoading
        ? Semantics(
            label: 'Carregando dados da tela inicial',
            child: const Center(child: CircularProgressIndicator()),
          )
        : RefreshIndicator(
            onRefresh: () async => _loadHomeData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health status overview
                  if (!statusState.isLoading) _buildHealthStatusCard(statsState),
                  const SizedBox(height: 16),
                  
                  // Stats summary
                  if (!statusState.isLoading) _buildStatsSection(statsState),
                  const SizedBox(height: 16),
                  
                  // Quick info cards
                  if (!statusState.isLoading && statsState.totalAnimals > 0) 
                    _buildQuickInfoSection(statsState),
                  const SizedBox(height: 24),
                  
                  // Feature grid with accessibility and responsive design
                  Semantics(
                    label: 'Menu de funcionalidades do PetiVeti',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        final isTablet = screenWidth > 600;
                        final crossAxisCount = isTablet ? 4 : 2;
                        final maxCrossAxisExtent = screenWidth / crossAxisCount - 16;
                        
                        return GridView.extent(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          maxCrossAxisExtent: maxCrossAxisExtent.clamp(150, 250),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: isTablet ? 1.2 : 1.0,
                          children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.pets,
                          title: 'Meus Pets',
                          subtitle: 'Gerencie seus animais',
                          route: '/animals',
                          color: Theme.of(context).colorScheme.primary,
                          badge: statsState.totalAnimals > 0 ? statsState.totalAnimals.toString() : null,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Consultas',
                          subtitle: 'Agende e acompanhe',
                          route: '/appointments',
                          color: Theme.of(context).colorScheme.secondary,
                          badge: statsState.upcomingAppointments > 0 ? statsState.upcomingAppointments.toString() : null,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.vaccines,
                          title: 'Vacinas',
                          subtitle: 'Controle de vacinas',
                          route: '/vaccines',
                          color: Theme.of(context).colorScheme.tertiary,
                          badge: statsState.pendingVaccinations > 0 ? statsState.pendingVaccinations.toString() : null,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.medication,
                          title: 'Medicamentos',
                          subtitle: 'Gerencie medicações',
                          route: '/medications',
                          color: Theme.of(context).colorScheme.error,
                          badge: statsState.activeMedications > 0 ? statsState.activeMedications.toString() : null,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.monitor_weight,
                          title: 'Peso',
                          subtitle: 'Controle de peso',
                          route: '/weight',
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.calculate,
                          title: 'Calculadoras',
                          subtitle: 'Ferramentas veterinárias',
                          route: '/calculators',
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHealthStatusCard(HomeStatsState stats) {
    final statusColor = stats.hasUrgentTasks 
        ? Theme.of(context).colorScheme.error 
        : Theme.of(context).colorScheme.primary;
    final statusIcon = stats.hasUrgentTasks ? Icons.warning : Icons.check_circle;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status da Saúde',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stats.healthStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (stats.hasUrgentTasks)
                      Text(
                        '${stats.overdueItems + stats.todayTasks} tarefas precisam de atenção',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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

  Widget _buildQuickInfoSection(HomeStatsState stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas atividades',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Próxima Consulta',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.nextAppointment ?? 'Nenhuma agendada',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.vaccines,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Próxima Vacina',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.nextVaccination ?? 'Nenhuma pendente',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (stats.speciesBreakdown.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seus pets por espécie',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: stats.speciesBreakdown.entries.map((entry) =>
                      Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(HomeStatsState stats) {
    return Semantics(
      label: 'Resumo das informações dos seus pets',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo Geral',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Pets', stats.totalAnimals, Icons.pets),
                  _buildStatItem('Consultas', stats.upcomingAppointments, Icons.calendar_today),
                  _buildStatItem('Vacinas', stats.pendingVaccinations, Icons.vaccines),
                  _buildStatItem('Remédios', stats.activeMedications, Icons.medication),
                ],
              ),
              if (stats.totalReminders > 0) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Lembretes', stats.totalReminders, Icons.notifications),
                    if (stats.averageAge > 0)
                      _buildStatItem(
                        'Idade Média',
                        stats.averageAge.round(),
                        Icons.cake,
                        suffix: stats.averageAge > 12 ? 'a' : 'm',
                      ),
                    _buildStatItem('Hoje', stats.todayTasks, Icons.today),
                    _buildStatItem('Atrasados', stats.overdueItems, Icons.warning, 
                        color: stats.overdueItems > 0 ? Theme.of(context).colorScheme.error : null),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label, 
    int count, 
    IconData icon, {
    String? suffix,
    Color? color,
  }) {
    final displayText = suffix != null ? '$count$suffix' : count.toString();
    final iconColor = color ?? Theme.of(context).primaryColor;
    
    return Semantics(
      label: '$count $label',
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 4),
          Text(
            displayText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    final notifications = ref.read(homeNotificationsProvider);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.recentNotifications.isEmpty
            ? [const Text('Nenhuma notificação')]
            : notifications.recentNotifications
                .map((notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('• $notification'),
                    ))
                .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(homeNotificationsProvider.notifier).markAllAsRead();
              Navigator.pop(context);
            },
            child: const Text('Marcar como lidas'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'agora mesmo';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
    String? badge,
  }) {
    final badgeText = badge != null ? ', $badge itens pendentes' : '';
    return Semantics(
      label: '$title, $subtitle$badgeText',
      hint: 'Toque para acessar $title',
      button: true,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: color,
                    ),
                    if (badge != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}