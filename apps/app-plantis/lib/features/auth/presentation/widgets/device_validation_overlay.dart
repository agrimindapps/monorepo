import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as local;

/// Overlay que mostra o status da validação de dispositivo durante o login
class DeviceValidationOverlay extends ConsumerWidget {
  const DeviceValidationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(local.authProvider);

    return authState.when(
      data: (state) {
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
