import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../device_management/presentation/providers/device_management_provider.dart';
import '../../../device_management/domain/entities/device_info.dart';

/// Seção de gerenciamento de dispositivos otimizada para UX na página de perfil
/// Integra de forma coesa o controle de dispositivos conectados
class DevicesSectionWidget extends StatefulWidget {
  const DevicesSectionWidget({super.key});

  @override
  State<DevicesSectionWidget> createState() => _DevicesSectionWidgetState();
}

class _DevicesSectionWidgetState extends State<DevicesSectionWidget> {

  @override
  void initState() {
    super.initState();
    // Carregar dispositivos quando o widget for inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceManagementProvider>().loadUserDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManagementProvider>(
      builder: (context, provider, _) {
        return _buildSection(
          context,
          title: 'Dispositivos Conectados',
          icon: Icons.devices,
          children: [
            _buildDevicesOverview(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: GasometerDesignTokens.iconSizeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/devices');
                  },
                  icon: const Icon(Icons.open_in_new, size: 20),
                  tooltip: 'Ver todos os dispositivos',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesOverview(BuildContext context, DeviceManagementProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState(context);
    }

    if (provider.hasError) {
      return _buildErrorState(context, provider);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          // Current device as ListTile
          if (provider.currentDevice != null)
            _buildCurrentDeviceListTile(context, provider.currentDevice!),
          
          // Other devices
          ...provider.devices
              .where((device) => device.uuid != provider.currentDevice?.uuid)
              .map((device) => _buildDeviceListTile(context, device, provider)),
          
          // Quick actions as ListTiles
          if (provider.devices.length > 1) ...[
            _buildDivider(),
            _buildRevokeAllListTile(context, provider),
          ],
          
          _buildDivider(),
          _buildViewAllDevicesListTile(context),
        ],
      ),
    );
  }






  Widget _buildCurrentDeviceListTile(BuildContext context, DeviceInfo device) {
    return Semantics(
      label: 'Dispositivo atual: ${device.name}',
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDeviceIcon(device.platform),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${device.platform} • Este dispositivo',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GasometerDesignTokens.colorSuccess,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ATIVO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceListTile(BuildContext context, DeviceInfo device, DeviceManagementProvider provider) {
    return Semantics(
      label: 'Dispositivo: ${device.name}, ${device.platform}',
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: device.isActive 
                ? GasometerDesignTokens.colorSuccess.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDeviceIcon(device.platform),
            color: device.isActive 
                ? GasometerDesignTokens.colorSuccess
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${device.platform} • ${_formatLastAccess(device.lastActiveAt)}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleDeviceAction(context, device, action, provider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'revoke',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Desconectar'),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRevokeAllListTile(BuildContext context, DeviceManagementProvider provider) {
    return Semantics(
      label: 'Desconectar todos os outros dispositivos',
      button: true,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
        ),
        title: Text(
          'Desconectar Outros Dispositivos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        subtitle: Text(
          'Remove acesso de ${provider.devices.length - 1} dispositivo(s)',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          _showRevokeAllDialog(context, provider);
        },
      ),
    );
  }

  Widget _buildViewAllDevicesListTile(BuildContext context) {
    return Semantics(
      label: 'Ver todos os dispositivos',
      button: true,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.devices,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          'Gerenciar Dispositivos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Ver detalhes e configurações avançadas',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.open_in_new,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/devices');
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Carregando dispositivos...',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DeviceManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar dispositivos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.errorMessage ?? 'Erro desconhecido',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.refresh();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Tentar Novamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }


  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatLastAccess(DateTime lastAccess) {
    final now = DateTime.now();
    final difference = now.difference(lastAccess);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d atrás';
    } else {
      return '${lastAccess.day}/${lastAccess.month}/${lastAccess.year}';
    }
  }

  void _handleDeviceAction(
    BuildContext context,
    DeviceInfo device,
    String action,
    DeviceManagementProvider provider,
  ) async {
    switch (action) {
      case 'revoke':
        final confirmed = await _showRevokeDeviceDialog(context, device);
        if (confirmed == true && mounted) {
          final success = await provider.revokeDevice(device.uuid);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${device.name} foi desconectado'),
                backgroundColor: GasometerDesignTokens.colorSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        break;
    }
  }

  Future<bool?> _showRevokeDeviceDialog(BuildContext context, DeviceInfo device) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        ),
        title: const Text('Desconectar Dispositivo'),
        content: Text(
          'Deseja desconectar "${device.name}"?\n\n'
          'Este dispositivo perderá acesso à sua conta e precisará fazer login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  void _showRevokeAllDialog(BuildContext context, DeviceManagementProvider provider) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        ),
        title: const Text('Desconectar Outros Dispositivos'),
        content: const Text(
          'Isso irá desconectar todos os outros dispositivos, '
          'mantendo apenas este. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.revokeAllOtherDevices();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Outros dispositivos desconectados'),
                    backgroundColor: GasometerDesignTokens.colorSuccess,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }
}