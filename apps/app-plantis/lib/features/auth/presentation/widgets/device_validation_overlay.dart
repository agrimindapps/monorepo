import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/riverpod_providers/auth_providers.dart' as local;

/// Overlay que mostra o status da validação de dispositivo durante o login
class DeviceValidationOverlay extends ConsumerWidget {
  const DeviceValidationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(local.authProvider);

    return authState.when(
      data: (state) {
        // Sempre retorna vazio por enquanto já que device validation não está implementado
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}