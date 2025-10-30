import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/device_management_notifier.dart';
import 'device_dialog_manager.dart';

/// Handles device management menu actions
/// Centralizes switch logic for menu items
class DeviceMenuActionHandler {
  final WidgetRef ref;
  final DeviceDialogManager dialogManager;

  DeviceMenuActionHandler({required this.ref, required this.dialogManager});

  /// Handles menu action selection
  Future<void> handleMenuAction(
    BuildContext context,
    String action,
    int otherDevicesCount,
  ) async {
    switch (action) {
      case 'refresh':
        await ref.read(deviceManagementNotifierProvider.notifier).refresh();
        break;

      case 'revoke_all':
        final confirmed = await dialogManager.showRevokeAllDialog(
          context,
          otherDevicesCount,
        );
        if (confirmed == true && context.mounted) {
          await ref
              .read(deviceManagementNotifierProvider.notifier)
              .revokeAllOtherDevices(
                reason: 'Logout remoto via interface de gerenciamento',
              );
        }
        break;

      case 'help':
        await dialogManager.showHelpDialog(context);
        break;
    }
  }
}
