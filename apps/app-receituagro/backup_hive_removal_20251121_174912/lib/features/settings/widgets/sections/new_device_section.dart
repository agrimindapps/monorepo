import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../presentation/providers/index.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

/// Device Settings Section
/// Allows users to manage connected devices and sync preferences
class NewDeviceSection extends ConsumerWidget {
  const NewDeviceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceNotifierProvider(initialDeviceId: null));

    return Column(
      children: [
        const SectionHeader(title: 'Sincronização e Dispositivos'),
        SettingsCard(
          child: Column(
            children: [
              _buildSyncToggle(context, ref, deviceState),
              const Divider(height: 1),
              _buildLastSyncInfo(context, ref, deviceState),
              if (deviceState.isLoading || deviceState.error != null)
                const Divider(height: 1),
              if (deviceState.isLoading) _buildLoadingIndicator(),
              if (deviceState.error != null)
                _buildErrorMessage(context, deviceState),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionHeader(
          title:
              'Dispositivos Conectados (${deviceState.settings.deviceCount})',
        ),
        SettingsCard(child: _buildDevicesList(context, ref, deviceState)),
      ],
    );
  }

  Widget _buildSyncToggle(
    BuildContext context,
    WidgetRef ref,
    DeviceState deviceState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sincronização Automática',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Sincronize dados entre dispositivos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: deviceState.settings.syncEnabled,
            onChanged: (value) {
              ref.read(deviceNotifierProvider(initialDeviceId: null).notifier).toggleSync();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLastSyncInfo(
    BuildContext context,
    WidgetRef ref,
    DeviceState deviceState,
  ) {
    final timeSinceSync = deviceState.settings.timeSinceLastSync;
    final timeText = timeSinceSync != null
        ? '${timeSinceSync.inMinutes} minutos atrás'
        : 'Nunca sincronizado';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última Sincronização',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deviceNotifierProvider(initialDeviceId: null).notifier).syncNow();
            },
            child: const Text('Sincronizar Agora'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(
    BuildContext context,
    WidgetRef ref,
    DeviceState deviceState,
  ) {
    final devices = deviceState.settings.connectedDevices;

    if (devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.devices_other,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum dispositivo conectado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sincronize com outros dispositivos para sincronizar dados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        final isCurrent = device == deviceState.settings.currentDeviceId;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        device,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Este dispositivo',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conectado há 2 dias',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (!isCurrent)
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      child: const Text('Remover'),
                      onTap: () {
                        ref
                            .read(deviceNotifierProvider(initialDeviceId: null).notifier)
                            .removeDevice(device);
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, DeviceState deviceState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deviceState.error ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
