import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/petiveti_page_header.dart';
import '../providers/home_providers.dart';
import '../services/home_actions_service.dart';
import '../widgets/home_feature_grid.dart';
import '../widgets/home_quick_info.dart';
import '../widgets/home_stats_section.dart';

/// Home Page - Main dashboard for PetiVeti app
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles UI layout and navigation
/// - **Dependency Inversion**: Depends on HomeActionsService abstraction
///
/// Displays:
/// - Quick stats and health status
/// - Notifications and system status
/// - Feature grid for navigation
/// - Quick info cards for upcoming activities
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Service instance (injectable via constructor in real app)
  final HomeActionsService _actionsService = HomeActionsService();

  @override
  void initState() {
    super.initState();
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
    final notificationsState = ref.watch(homeNotificationsProvider);
    final hasUnreadNotifications = ref.watch(hasUnreadNotificationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PetivetiPageHeader(
              icon: Icons.home,
              title: 'Início',
              subtitle: 'Bem-vindo ao PetiVeti',
              actions: [
                // Notificações
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        hasUnreadNotifications ? Icons.notifications_active : Icons.notifications,
                        color: Colors.white,
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
                // Status
                IconButton(
                  icon: Icon(
                    statusState.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: Colors.white,
                  ),
                  onPressed: () => _actionsService.showStatusInfo(context, statusState),
                ),
              ],
            ),
            Expanded(
              child: statusState.isLoading
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
                              if (!statusState.isLoading)
                                HomeStatsSection(stats: statsState),
                              const SizedBox(height: 16),
                              if (!statusState.isLoading &&
                                  statsState.totalAnimals > 0) ...[
                                HomeQuickInfo(stats: statsState),
                                const SizedBox(height: 24),
                              ],
                              HomeFeatureGrid(stats: statsState),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    final notifications = ref.read(homeNotificationsProvider);

    _actionsService.showNotifications(
      context,
      notifications,
      onMarkAllAsRead: () {
        ref.read(homeNotificationsProvider.notifier).markAllAsRead();
      },
    );
  }
}
