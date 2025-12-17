import 'package:core/core.dart'
    hide Column, DeviceManagementState, deviceManagementProvider;
import 'package:flutter/material.dart';

import '../../../device_management/data/models/device_model.dart';
import '../../../device_management/presentation/providers/device_management_notifier.dart';

class DeviceManagementDialog extends ConsumerWidget {
  const DeviceManagementDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceStateAsync = ref.watch(deviceManagementProvider);

    return AlertDialog(
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
        child: deviceStateAsync.when(
          data: (DeviceManagementState state) => Column(
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
                      final isCurrentDevice =
                          state.currentDevice?.uuid == device.uuid;

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
                              int.parse(
                                device.statusColorHex.replaceFirst('#', '0xFF'),
                              ),
                            ),
                          ),
                        ),
                        trailing: isCurrentDevice
                            ? null
                            : IconButton(
                                icon:
                                    state.isRevoking &&
                                        state.revokingDeviceUuid == device.uuid
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                onPressed: state.isRevoking
                                    ? null
                                    : () => _confirmRevokeDevice(
                                        context,
                                        ref,
                                        device,
                                      ),
                              ),
                      );
                    },
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => Center(child: Text('Erro: $error')),
        ),
      ),
      actions: [
        deviceStateAsync.when(
          data: (DeviceManagementState state) => state.devices.length > 1
              ? TextButton.icon(
                  onPressed: state.isRevoking
                      ? null
                      : () => _confirmRevokeAllOtherDevices(context, ref),
                  icon: const Icon(Icons.phonelink_erase, size: 18),
                  label: const Text('Desconectar outros'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  void _confirmRevokeDevice(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
  ) {
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
              final bool success = await ref
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
              final bool success = await ref
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
