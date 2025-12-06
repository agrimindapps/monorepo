import 'package:core/core.dart' hide Column, DeviceManagementState, deviceManagementProvider;
import 'package:flutter/material.dart';

import '../../../device_management/data/models/device_model.dart';
import '../../../device_management/presentation/providers/device_management_notifier.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(settingsProvider),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (AppSettings settings) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              SettingsSection(
                title: 'Aparência',
                icon: Icons.palette,
                children: [
                  SettingsToggle(
                    title: 'Modo Escuro',
                    subtitle: 'Usar tema escuro no aplicativo',
                    value: settings.darkMode,
                    icon: Icons.dark_mode,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateDarkMode(value);
                    },
                  ),
                ],
              ),

              // Notifications Section
              SettingsSection(
                title: 'Notificações',
                icon: Icons.notifications,
                children: [
                  SettingsToggle(
                    title: 'Notificações',
                    subtitle: 'Receber notificações do aplicativo',
                    value: settings.notificationsEnabled,
                    icon: Icons.notifications_active,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateNotificationsEnabled(value);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Antecedência dos Lembretes'),
                    subtitle: Text('${settings.reminderHoursBefore} horas antes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showReminderHoursDialog(context, ref, settings.reminderHoursBefore),
                  ),
                ],
              ),

              // Sound & Haptics Section
              SettingsSection(
                title: 'Som e Feedback',
                icon: Icons.volume_up,
                children: [
                  SettingsToggle(
                    title: 'Sons',
                    subtitle: 'Reproduzir sons no aplicativo',
                    value: settings.soundsEnabled,
                    icon: Icons.music_note,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSoundsEnabled(value);
                    },
                  ),
                  const Divider(),
                  SettingsToggle(
                    title: 'Vibração',
                    subtitle: 'Feedback háptico ao interagir',
                    value: settings.vibrationEnabled,
                    icon: Icons.vibration,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateVibrationEnabled(value);
                    },
                  ),
                ],
              ),

              // Language Section
              SettingsSection(
                title: 'Idioma',
                icon: Icons.language,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.translate),
                    title: const Text('Idioma do Aplicativo'),
                    subtitle: Text(_getLanguageName(settings.language)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, ref, settings.language),
                  ),
                ],
              ),

              // Sync Section
              SettingsSection(
                title: 'Sincronização',
                icon: Icons.sync,
                children: [
                  SettingsToggle(
                    title: 'Sincronização Automática',
                    subtitle: 'Sincronizar dados automaticamente',
                    value: settings.autoSync,
                    icon: Icons.cloud_sync,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateAutoSync(value);
                    },
                  ),
                  if (settings.lastSyncAt != null) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: const Text('Última Sincronização'),
                      subtitle: Text(_formatDateTime(settings.lastSyncAt!)),
                    ),
                  ],
                ],
              ),

              // Device Management Section
              _buildDeviceManagementSection(context, ref),

              // Reset Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetConfirmation(context, ref),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restaurar Padrões'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Erro ao carregar configurações'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      default:
        return code;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showReminderHoursDialog(BuildContext context, WidgetRef ref, int currentValue) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antecedência dos Lembretes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [6, 12, 24, 48, 72].map((hours) {
            return RadioListTile<int>.adaptive(
              title: Text('$hours horas antes'),
              value: hours,
              groupValue: currentValue, // ignore: deprecated_member_use
              onChanged: (value) { // ignore: deprecated_member_use
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateReminderHoursBefore(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLanguage) {
    final languages = [
      {'code': 'pt_BR', 'name': 'Português (Brasil)'},
      {'code': 'en_US', 'name': 'English (US)'},
      {'code': 'es_ES', 'name': 'Español'},
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma do Aplicativo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>.adaptive(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: currentLanguage, // ignore: deprecated_member_use
              onChanged: (value) { // ignore: deprecated_member_use
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrões'),
        content: const Text(
          'Tem certeza que deseja restaurar todas as configurações para os valores padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementSection(BuildContext context, WidgetRef ref) {
    final deviceStateAsync = ref.watch(deviceManagementProvider);

    return SettingsSection(
      title: 'Dispositivos',
      icon: Icons.devices,
      children: [
        deviceStateAsync.when(
          data: (state) => Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(state.statusIcon, color: state.statusColor),
                title: const Text('Dispositivos Conectados'),
                subtitle: Text(state.deviceLimitText),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDevicesDialog(context, ref, state),
              ),
              if (state.hasReachedDeviceLimit) ...[
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Limite de dispositivos atingido. Remova um dispositivo para adicionar outro.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          loading: () => const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Carregando dispositivos...'),
          ),
          error: (error, _) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text('Erro ao carregar dispositivos'),
            subtitle: Text(
              error.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(deviceManagementProvider),
            ),
          ),
        ),
      ],
    );
  }

  void _showDevicesDialog(BuildContext context, WidgetRef ref, DeviceManagementState state) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.devices, size: 24),
            const SizedBox(width: 12),
            const Text('Dispositivos'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                ref.read(deviceManagementProvider.notifier).refresh();
              },
              tooltip: 'Atualizar',
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Limite info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(state.statusIcon, color: state.statusColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      state.deviceLimitText,
                      style: TextStyle(
                        color: state.statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Device list
              if (state.devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhum dispositivo registrado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.devices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final device = state.devices[index];
                      final isCurrentDevice = state.currentDevice?.uuid == device.uuid;
                      
                      return ListTile(
                        leading: Text(
                          device.platformIcon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                device.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentDevice)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Este',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${device.platform} • ${device.statusText}',
                          style: TextStyle(
                            color: Color(
                              int.parse(device.statusColorHex.replaceFirst('#', '0xFF')),
                            ),
                          ),
                        ),
                        trailing: isCurrentDevice
                            ? null
                            : IconButton(
                                icon: state.isRevoking && state.revokingDeviceUuid == device.uuid
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: state.isRevoking
                                    ? null
                                    : () => _confirmRevokeDevice(context, ref, device),
                              ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (state.devices.length > 1)
            TextButton.icon(
              onPressed: state.isRevoking
                  ? null
                  : () => _confirmRevokeAllOtherDevices(context, ref),
              icon: const Icon(Icons.phonelink_erase, size: 18),
              label: const Text('Desconectar outros'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _confirmRevokeDevice(BuildContext context, WidgetRef ref, DeviceModel device) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar Dispositivo'),
        content: Text(
          'Deseja desconectar "${device.name}" da sua conta?\n\n'
          'O dispositivo precisará fazer login novamente para acessar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(deviceManagementProvider.notifier)
                  .revokeDevice(device.uuid);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Dispositivo desconectado'
                          : 'Erro ao desconectar dispositivo',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  void _confirmRevokeAllOtherDevices(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar Outros Dispositivos'),
        content: const Text(
          'Deseja desconectar todos os outros dispositivos da sua conta?\n\n'
          'Apenas este dispositivo permanecerá conectado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(deviceManagementProvider.notifier)
                  .revokeAllOtherDevices();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Outros dispositivos desconectados'
                          : 'Erro ao desconectar dispositivos',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desconectar Todos'),
          ),
        ],
      ),
    );
  }
}
