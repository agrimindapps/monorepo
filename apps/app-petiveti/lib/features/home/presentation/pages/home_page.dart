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
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  hasUrgentAlerts ? Icons.notifications_active : Icons.notifications,
                  color: hasUrgentAlerts ? Colors.red : null,
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
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${notificationsState.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Status indicator
          IconButton(
            icon: Icon(
              statusState.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: statusState.isOnline ? Colors.green : Colors.grey,
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
        ],
      ),
      body: statusState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async => _loadHomeData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats summary
                  if (!statusState.isLoading) _buildStatsSection(statsState),
                  const SizedBox(height: 24),
                  
                  // Feature grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.pets,
                        title: 'Meus Pets',
                        subtitle: 'Gerencie seus animais',
                        route: '/animals',
                        color: Colors.blue,
                        badge: statsState.totalAnimals > 0 ? statsState.totalAnimals.toString() : null,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Consultas',
                        subtitle: 'Agende e acompanhe',
                        route: '/appointments',
                        color: Colors.green,
                        badge: statsState.upcomingAppointments > 0 ? statsState.upcomingAppointments.toString() : null,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.vaccines,
                        title: 'Vacinas',
                        subtitle: 'Controle de vacinas',
                        route: '/vaccines',
                        color: Colors.orange,
                        badge: statsState.pendingVaccinations > 0 ? statsState.pendingVaccinations.toString() : null,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.medication,
                        title: 'Medicamentos',
                        subtitle: 'Gerencie medicações',
                        route: '/medications',
                        color: Colors.red,
                        badge: statsState.activeMedications > 0 ? statsState.activeMedications.toString() : null,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.monitor_weight,
                        title: 'Peso',
                        subtitle: 'Controle de peso',
                        route: '/weight',
                        color: Colors.purple,
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.calculate,
                        title: 'Calculadoras',
                        subtitle: 'Ferramentas veterinárias',
                        route: '/calculators',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStatsSection(HomeStatsState stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo',
              style: TextStyle(
                fontSize: 18,
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
    return Card(
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
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}