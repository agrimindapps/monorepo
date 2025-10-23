import 'package:core/core.dart' show ConnectivityService;
import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';

/// Banner widget that displays connectivity status
///
/// Shows a warning banner when the device is offline
/// Provides a retry button to force connectivity check
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = getIt<ConnectivityService>();

    return StreamBuilder<bool>(
      stream: connectivityService.connectivityStream,
      initialData: true, // Assume online initially
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          content: const Row(
            children: [
              Icon(Icons.cloud_off, size: 20, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sem conexão. Trabalhando offline.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[700],
          actions: [
            TextButton(
              onPressed: () async {
                // Force connectivity check
                await connectivityService.forceConnectivityCheck();
              },
              child: const Text(
                'TENTAR NOVAMENTE',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                // Dismiss banner
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text(
                'FECHAR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Extension to show connectivity banner easily
extension ConnectivityBannerExtension on BuildContext {
  /// Show connectivity banner if offline
  void showConnectivityBanner() {
    final connectivityService = getIt<ConnectivityService>();

    connectivityService.isOnline().then((result) {
      result.fold(
        (_) => null, // Ignore errors
        (isOnline) {
          if (!isOnline && mounted) {
            ScaffoldMessenger.of(this).showMaterialBanner(
              MaterialBanner(
                content: const Row(
                  children: [
                    Icon(Icons.cloud_off, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sem conexão. Trabalhando offline.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange[700],
                actions: [
                  TextButton(
                    onPressed: () async {
                      await connectivityService.forceConnectivityCheck();
                      if (mounted) {
                        ScaffoldMessenger.of(this)
                            .hideCurrentMaterialBanner();
                      }
                    },
                    child: const Text(
                      'TENTAR NOVAMENTE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
                    },
                    child: const Text(
                      'FECHAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    });
  }

  /// Hide connectivity banner
  void hideConnectivityBanner() {
    ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
  }
}
