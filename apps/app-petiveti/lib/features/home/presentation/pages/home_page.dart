import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/home_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_feature_grid.dart';
import '../widgets/home_quick_info.dart';
import '../widgets/home_stats_section.dart';

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
      if (!mounted) return;
      
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
    final statsState = ref.watch(homeStatsProvider);
    final statusState = ref.watch(homeStatusProvider);

    return Scaffold(
      appBar: HomeAppBar(
        onNotificationTap: _showNotifications,
        onStatusTap: () => _showStatusInfo(context, statusState),
      ),
      body: statusState.isLoading
        ? Semantics(
            label: 'Carregando dados da tela inicial',
            child: const Center(child: CircularProgressIndicator()),
          )
        : Semantics(
            label: 'Página inicial do PetiVeti',
            hint: 'Arraste para baixo para atualizar os dados',
            child: RefreshIndicator(
              onRefresh: () async => _loadHomeData(),
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!statusState.isLoading) HomeStatsSection(stats: statsState),
                  const SizedBox(height: 16),
                  if (!statusState.isLoading && statsState.totalAnimals > 0) ...[
                    HomeQuickInfo(stats: statsState),
                    const SizedBox(height: 24),
                  ],
                  HomeFeatureGrid(stats: statsState),
                ],
              ),
            ),
          ),
      ),
    );
  }

  void _showStatusInfo(BuildContext context, HomeStatusState statusState) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          statusState.isOnline 
            ? 'Online - Última atualização: ${_formatTime(statusState.lastUpdated)}'
            : 'Offline - Dados locais',
        ),
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
}