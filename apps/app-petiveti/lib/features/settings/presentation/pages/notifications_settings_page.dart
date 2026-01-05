import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/settings_providers.dart';

/// Página de configurações de notificações
class NotificationsSettingsPage extends ConsumerStatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  ConsumerState<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState
    extends ConsumerState<NotificationsSettingsPage> {
  bool _isCheckingPermission = false;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    if (kIsWeb) return;

    setState(() => _isCheckingPermission = true);

    try {
      final status = await Permission.notification.status;
      setState(() => _permissionStatus = status);
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    } finally {
      setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _requestPermission() async {
    if (kIsWeb) return;

    setState(() => _isCheckingPermission = true);

    try {
      final status = await Permission.notification.request();
      setState(() => _permissionStatus = status);

      if (status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de notificações concedida!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          _showOpenSettingsDialog();
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    } finally {
      setState(() => _isCheckingPermission = false);
    }
  }

  void _showOpenSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Negada'),
        content: const Text(
          'As notificações foram permanentemente negadas. '
          'Abra as configurações do dispositivo para permitir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context, theme),
              const SizedBox(height: 24),
              _buildGeneralSettings(context, theme, settings),
              const SizedBox(height: 24),
              _buildReminderSettings(context, theme, settings),
              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ThemeData theme) {
    const isWeb = kIsWeb;
    final hasPermission = _permissionStatus?.isGranted ?? false;
    final isDenied = _permissionStatus?.isDenied ?? false;
    final isPermanentlyDenied = _permissionStatus?.isPermanentlyDenied ?? false;

    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (isWeb) {
      statusIcon = Icons.web;
      statusColor = Colors.grey;
      statusText = 'Notificações não disponíveis na versão web';
    } else if (_isCheckingPermission) {
      statusIcon = Icons.hourglass_empty;
      statusColor = Colors.orange;
      statusText = 'Verificando permissões...';
    } else if (hasPermission) {
      statusIcon = Icons.notifications_active;
      statusColor = Colors.green;
      statusText = 'Notificações ativadas e funcionando';
    } else if (isPermanentlyDenied) {
      statusIcon = Icons.notifications_off;
      statusColor = Colors.red;
      statusText = 'Permissão negada permanentemente';
    } else if (isDenied) {
      statusIcon = Icons.notifications_paused;
      statusColor = Colors.orange;
      statusText = 'Permissão de notificações negada';
    } else {
      statusIcon = Icons.notification_important;
      statusColor = Colors.orange;
      statusText = 'Permissão de notificações não concedida';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Status das Notificações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
            ),
            if (!isWeb && !hasPermission && !_isCheckingPermission) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isPermanentlyDenied
                      ? () => openAppSettings()
                      : _requestPermission,
                  icon: Icon(
                    isPermanentlyDenied ? Icons.settings : Icons.check_circle,
                  ),
                  label: Text(
                    isPermanentlyDenied
                        ? 'Abrir Configurações'
                        : 'Permitir Notificações',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (isWeb) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use o aplicativo móvel para receber notificações',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(
    BuildContext context,
    ThemeData theme,
    dynamic settings,
  ) {
    final isEnabled = settings.notificationsEnabled as bool;
    const isWeb = kIsWeb;
    final hasPermission = _permissionStatus?.isGranted ?? false;
    final canEnable = !isWeb && hasPermission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações Gerais',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: isEnabled && canEnable,
                onChanged: canEnable
                    ? (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateNotificationsEnabled(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notificações ativadas'
                                  : 'Notificações desativadas',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    : null,
                title: const Text('Notificações Gerais'),
                subtitle: Text(
                  isWeb
                      ? 'Não disponível na versão web'
                      : canEnable
                      ? 'Receber notificações do aplicativo'
                      : 'Permita notificações primeiro',
                ),
                secondary: Icon(
                  isEnabled && canEnable
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: canEnable ? AppColors.primary : Colors.grey,
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: settings.soundsEnabled as bool,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSoundsEnabled(value);
                },
                title: const Text('Sons de Notificação'),
                subtitle: const Text('Reproduzir som ao receber notificação'),
                secondary: Icon(
                  (settings.soundsEnabled as bool)
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              SwitchListTile(
                value: settings.vibrationEnabled as bool,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateVibrationEnabled(value);
                },
                title: const Text('Vibração'),
                subtitle: const Text('Vibrar ao receber notificação'),
                secondary: Icon(
                  (settings.vibrationEnabled as bool)
                      ? Icons.vibration
                      : Icons.mobile_off,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSettings(
    BuildContext context,
    ThemeData theme,
    dynamic settings,
  ) {
    final reminderHours = settings.reminderHoursBefore as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lembretes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alarm, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Antecedência dos Lembretes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Receber lembrete $reminderHours horas antes',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: reminderHours.toDouble(),
                  min: 1,
                  max: 72,
                  divisions: 71,
                  label: '$reminderHours horas',
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateReminderHoursBefore(value.toInt());
                  },
                ),
                Text(
                  'Deslize para ajustar (1 a 72 horas)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
