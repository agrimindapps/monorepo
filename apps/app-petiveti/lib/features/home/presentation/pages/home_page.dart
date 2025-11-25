import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../providers/home_providers.dart';
import '../services/home_actions_service.dart';
import '../widgets/home_app_bar.dart';
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

    return Scaffold(
      appBar: HomeAppBar(
        onNotificationTap: _showNotifications,
        onStatusTap: () => _actionsService.showStatusInfo(context, statusState),
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
