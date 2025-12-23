import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget para gerenciamento de dispositivos conectados
/// Usa providers do core para consistência cross-app
class ProfileDevicesSection extends ConsumerWidget {
  const ProfileDevicesSection({
    required this.settingsData,
    required this.onManageDevices,
    super.key,
  });

  final dynamic settingsData;
  final VoidCallback onManageDevices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Usa providers do core para device management
    final currentDeviceAsync = ref.watch(currentDeviceProvider);
    final userDevicesAsync = ref.watch(userDevicesProvider);
    final deviceCount = ref.watch(deviceCountProvider);
    final maxDevices = ref.watch(maxDevicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Dispositivos Conectados',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              currentDeviceAsync.when(
                data: (device) => _buildDeviceInfo(context, device, deviceCount, maxDevices),
                loading: () => const ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: Text('Carregando dispositivo...'),
                ),
                error: (_, __) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  ),
                  title: const Text('Erro ao carregar dispositivo'),
                  subtitle: const Text('Toque para tentar novamente'),
                  onTap: () => ref.invalidate(currentDeviceProvider),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onManageDevices,
                        icon: const Icon(Icons.devices, size: 18),
                        label: const Text('Gerenciar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: userDevicesAsync.when(
                        data: (devices) => OutlinedButton(
                          onPressed: devices.length > 1 
                              ? () => _showRevokeAllDialog(context, ref)
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Desconectar outros'),
                        ),
                        loading: () => const OutlinedButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Desconectar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(
    BuildContext context,
    DeviceEntity device,
    int deviceCount,
    int maxDevices,
  ) {
    final theme = Theme.of(context);
    final limitText = maxDevices == -1 ? 'ilimitado' : '$deviceCount/$maxDevices';
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getPlatformColor(device.platform).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getPlatformIcon(device.platform),
          color: _getPlatformColor(device.platform),
          size: 20,
        ),
      ),
      title: Text(
        device.name.isNotEmpty ? device.name : device.model,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${device.platform} • $limitText dispositivos',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onManageDevices,
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.android;
      case 'web':
        return Icons.language;
      case 'macos':
      case 'windows':
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Colors.grey.shade700;
      case 'android':
        return Colors.green;
      case 'web':
        return Colors.blue;
      case 'macos':
      case 'windows':
      case 'linux':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showRevokeAllDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar outros dispositivos?'),
        content: const Text(
          'Todos os outros dispositivos serão desconectados. '
          'Você precisará fazer login novamente neles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final actions = ref.read(deviceActionsProvider);
              final success = await actions.revokeAllOtherDevices();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Outros dispositivos desconectados'
                          : 'Erro ao desconectar dispositivos',
                    ),
                  ),
                );
              }
            },
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
