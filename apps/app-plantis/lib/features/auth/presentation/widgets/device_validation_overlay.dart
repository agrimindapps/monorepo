import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/riverpod_providers/auth_providers.dart';

/// Overlay que mostra o status da validação de dispositivo durante o login
class DeviceValidationOverlay extends ConsumerWidget {
  const DeviceValidationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      data: (state) {
        // Só mostra se está validando dispositivo ou houve erro
        if (!state.isValidatingDevice &&
            state.deviceValidationError == null &&
            !state.deviceLimitExceeded) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContent(context, state, ref),
                  const SizedBox(height: 16),
                  _buildActions(context, state, ref),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state, WidgetRef ref) {
    if (state.isValidatingDevice) {
      return _buildValidatingContent(context);
    }

    if (state.deviceLimitExceeded) {
      return _buildLimitExceededContent(context);
    }

    if (state.deviceValidationError != null) {
      return _buildErrorContent(context, state.deviceValidationError!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildValidatingContent(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Validando dispositivo...',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Verificando se este dispositivo está autorizado',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLimitExceededContent(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.block,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Limite de dispositivos atingido',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Você já possui 3 dispositivos registrados. Para usar o Plantis neste dispositivo, é necessário revogar o acesso de um dispositivo existente.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Você será deslogado automaticamente em alguns segundos.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Column(
      children: [
        Icon(
          Icons.warning_amber,
          size: 48,
          color: Theme.of(context).colorScheme.orange,
        ),
        const SizedBox(height: 16),
        Text(
          'Aviso de segurança',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.orange,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Você pode continuar usando o app, mas recomendamos verificar suas configurações de dispositivos.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, AuthState state, WidgetRef ref) {
    if (state.isValidatingDevice) {
      return const SizedBox.shrink(); // Sem ações durante validação
    }

    if (state.deviceLimitExceeded) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              child: const Text('Fazer logout agora'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement device management navigation
                // Should navigate to a page where users can view and remove registered devices
                // Route needs to be defined in app router and page needs to be implemented
                Navigator.of(context).pushNamed('/device-management');
              },
              child: const Text('Gerenciar dispositivos'),
            ),
          ),
        ],
      );
    }

    if (state.deviceValidationError != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).clearDeviceValidationError(),
              child: const Text('Continuar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement device management navigation
                // Should navigate to a page for viewing current device registrations
                // Route needs to be defined in app router and page needs to be implemented
                Navigator.of(context).pushNamed('/device-management');
              },
              child: const Text('Ver dispositivos'),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// Extension para adicionar cor orange ao ColorScheme
extension ColorSchemeExtension on ColorScheme {
  Color get orange => const Color(0xFFFF9800);
}