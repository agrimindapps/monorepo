import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../../core/providers/settings_providers.dart';
import '../../../../../core/theme/plantis_colors.dart';
import '../../providers/settings_notifier.dart';
import '../sections/device_list_item.dart';

/// Dialog para gerenciamento completo de dispositivos
class DeviceManagementDialog extends ConsumerStatefulWidget {
  const DeviceManagementDialog({super.key});

  @override
  ConsumerState<DeviceManagementDialog> createState() =>
      _DeviceManagementDialogState();
}

class _DeviceManagementDialogState
    extends ConsumerState<DeviceManagementDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PlantisColors.primary,
                    PlantisColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.devices,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispositivos Conectados',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        settingsState.when<Widget>(
                          data: (SettingsState state) => Text(
                            '${state.activeDeviceCount} de 3 dispositivos ativos',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (Object error, StackTrace _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: settingsState.when<Widget>(
                data: (SettingsState state) => _buildDeviceList(context, state),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (Object error, StackTrace _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar dispositivos',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  Widget _buildDeviceList(BuildContext context, SettingsState state) {
    final currentDevice = state.currentDevice;
    final otherDevices = state.connectedDevices
        .where((DeviceEntity d) => d.uuid != currentDevice?.uuid)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dispositivo Atual
          if (currentDevice != null) ...[
            _buildSectionHeader(context, 'Dispositivo Atual'),
            const SizedBox(height: 12),
            DeviceListItem(
              device: currentDevice,
              isCurrent: true,
            ),
            const SizedBox(height: 24),
          ],

          // Outros Dispositivos
          if (otherDevices.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, 'Outros Dispositivos'),
                if (otherDevices.where((DeviceEntity d) => d.isActive).length > 1)
                  TextButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _revokeAllOthers(context),
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Revogar Todos'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...otherDevices.map<Widget>(
              (DeviceEntity device) => DeviceListItem(
                device: device,
                isCurrent: false,
                onRevoke: _isProcessing
                    ? null
                    : () => _revokeDevice(context, device),
              ),
            ),
          ],

          // Empty State
          if (currentDevice == null && otherDevices.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum dispositivo conectado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Info Footer
          const SizedBox(height: 16),
          _buildInfoFooter(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: PlantisColors.primary,
          ),
    );
  }

  Widget _buildInfoFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Você pode conectar até 3 dispositivos. Remova dispositivos antigos para liberar espaço.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _revokeDevice(BuildContext context, DeviceEntity device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Dispositivo?'),
        content: Text(
          'Deseja revogar o acesso de "${device.name}"?\n\n'
          'Este dispositivo será desconectado e precisará fazer login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);

      await ref.read(settingsNotifierProvider.notifier).revokeDevice(
            device.uuid,
          );

      if (mounted) {
        setState(() => _isProcessing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dispositivo "${device.name}" revogado'),
            backgroundColor: PlantisColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _revokeAllOthers(BuildContext context) async {
    final settingsState = ref.read(settingsNotifierProvider).valueOrNull;
    final otherDevicesCount = settingsState?.connectedDevices
            .where((DeviceEntity d) =>
                d.uuid != settingsState.currentDevice?.uuid && d.isActive)
            .length ??
        0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Todos os Outros?'),
        content: Text(
          'Deseja revogar o acesso de $otherDevicesCount dispositivo(s)?\n\n'
          'Todos os outros dispositivos serão desconectados e precisarão fazer login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Revogar Todos'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);

      await ref.read(settingsNotifierProvider.notifier).revokeAllOtherDevices();

      if (mounted) {
        setState(() => _isProcessing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os outros dispositivos foram revogados'),
            backgroundColor: PlantisColors.primary,
          ),
        );
      }
    }
  }
}
