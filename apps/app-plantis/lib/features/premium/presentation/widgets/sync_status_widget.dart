import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/premium_notifier_improved.dart';

/// Widget que mostra o status de sincronização em tempo real
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(premiumImprovedNotifierProvider);

    return asyncValue.when(
      data: (premiumState) => _buildContent(context, ref, premiumState),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, PremiumImprovedState premiumState) {
    final premiumProvider = premiumState;

    return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      premiumProvider.isSyncing
                          ? Icons.sync
                          : premiumProvider.hasSyncErrors
                          ? Icons.sync_problem
                          : Icons.check_circle,
                      color:
                          premiumProvider.isSyncing
                              ? Colors.orange
                              : premiumProvider.hasSyncErrors
                              ? Colors.red
                              : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status de Sincronização',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (premiumProvider.isSyncing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusItem(
                  'Premium Ativo',
                  premiumProvider.isPremium ? 'Sim' : 'Não',
                  premiumProvider.isPremium ? Colors.green : Colors.grey,
                ),
                _buildStatusItem(
                  'Última Sincronização',
                  premiumProvider.lastSyncAt != null
                      ? _formatDateTime(premiumProvider.lastSyncAt!)
                      : 'Nunca',
                  Colors.blue,
                ),
                _buildStatusItem(
                  'Features Habilitadas',
                  '${premiumProvider.premiumFeaturesEnabled.length}',
                  Colors.purple,
                ),
                if (premiumProvider.plantLimits != null)
                  _buildStatusItem(
                    'Limite de Plantas',
                    ref.read(premiumImprovedNotifierProvider.notifier).canCreateUnlimitedPlants()
                        ? 'Ilimitado'
                        : '${ref.read(premiumImprovedNotifierProvider.notifier).getCurrentPlantLimit()}',
                    Colors.teal,
                  ),
                if (premiumProvider.hasSyncErrors) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Erro de Sincronização',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          premiumProvider.syncErrorMessage ??
                              'Erro desconhecido',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11,
                          ),
                        ),
                        if (premiumProvider.syncRetryCount > 0)
                          Text(
                            'Tentativas de retry: ${premiumProvider.syncRetryCount}',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            premiumProvider.isSyncing
                                ? null
                                : () => ref.read(premiumImprovedNotifierProvider.notifier).forceSyncSubscription(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Sincronizar'),
                      ),
                    ),
                    if (premiumProvider.hasSyncErrors) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref.read(premiumImprovedNotifierProvider.notifier).clearSyncErrors(),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Limpar Erros'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }
}

/// Widget expandido que mostra informações detalhadas de debug
class SyncDebugWidget extends ConsumerWidget {
  const SyncDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(premiumImprovedNotifierProvider);

    return asyncValue.when(
      data: (premiumState) {
        final debugInfo = ref.read(premiumImprovedNotifierProvider.notifier).getDebugInfo();

    return ExpansionTile(
      title: const Text('Debug Info'),
      leading: const Icon(Icons.bug_report),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDebugSection('Subscription', debugInfo['subscription']),
              const SizedBox(height: 16),
              _buildDebugSection('Sync Status', debugInfo['sync']),
              const SizedBox(height: 16),
              _buildDebugSection('Features', debugInfo['features']),
              const SizedBox(height: 16),
              _buildDebugSection('Products', debugInfo['products']),
            ],
          ),
        ),
      ],
    );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildDebugSection(String title, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar features premium disponíveis
class PremiumFeaturesWidget extends ConsumerWidget {
  const PremiumFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(premiumImprovedNotifierProvider);

    return asyncValue.when(
      data: (premiumState) {
        final notifier = ref.read(premiumImprovedNotifierProvider.notifier);
        final features = [
          _FeatureItem(
            'Plantas Ilimitadas',
            'unlimited_plants',
            notifier.canCreateUnlimitedPlants(),
          ),
          _FeatureItem(
            'Lembretes Avançados',
            'advanced_reminders',
            notifier.canUseCustomReminders(),
          ),
          _FeatureItem(
            'Exportar Dados',
            'export_data',
            notifier.canExportData(),
          ),
          _FeatureItem(
            'Temas Personalizados',
            'custom_themes',
            notifier.canAccessPremiumThemes(),
          ),
          _FeatureItem(
            'Backup na Nuvem',
            'cloud_backup',
            notifier.canBackupToCloud(),
          ),
          _FeatureItem(
            'Identificação de Plantas',
            'plant_identification',
            notifier.canIdentifyPlants(),
          ),
          _FeatureItem(
            'Diagnóstico de Doenças',
            'disease_diagnosis',
            notifier.canDiagnoseDiseases(),
          ),
          _FeatureItem(
            'Notificações Meteorológicas',
            'weather_based_notifications',
            notifier.canUseWeatherNotifications(),
          ),
          _FeatureItem(
            'Calendário de Cuidados',
            'care_calendar',
            notifier.canUseCareCalendar(),
          ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features Premium',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => _buildFeatureItem(feature)),
          ],
        ),
      ),
    );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  Widget _buildFeatureItem(_FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            feature.isEnabled ? Icons.check_circle : Icons.circle_outlined,
            color: feature.isEnabled ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.name,
              style: TextStyle(
                color: feature.isEnabled ? Colors.black : Colors.grey,
                fontWeight:
                    feature.isEnabled ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String name;
  final String id;
  final bool isEnabled;

  const _FeatureItem(this.name, this.id, this.isEnabled);
}
