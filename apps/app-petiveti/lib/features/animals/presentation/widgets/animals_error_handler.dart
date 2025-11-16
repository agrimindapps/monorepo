import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/animals_provider.dart';
import 'animals_page_coordinator.dart';

/// Error handler component for Animals page
/// 
/// Responsibilities:
/// - Listen to error states from providers
/// - Display error messages to users
/// - Provide retry mechanisms
/// - Keep error handling logic separate from main UI
class AnimalsErrorHandler extends ConsumerStatefulWidget {
  final AnimalsPageCoordinator coordinator;

  const AnimalsErrorHandler({
    super.key,
    required this.coordinator,
  });

  @override
  ConsumerState<AnimalsErrorHandler> createState() => _AnimalsErrorHandlerState();
}

class _AnimalsErrorHandlerState extends ConsumerState<AnimalsErrorHandler> {

  void _handleError(AnimalsState? previous, AnimalsState next) {
    if (next.error != null && previous?.error != next.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          _showErrorSnackBar(next.error!);
        }
      });
    }
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tentar novamente',
          textColor: Colors.white,
          onPressed: _handleRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(animalsNotifierProvider.notifier).clearError();
      }
    });
  }

  void _handleRetry() {
    widget.coordinator.refreshAnimals();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AnimalsState>(animalsNotifierProvider, (previous, next) {
      _handleError(previous, next);
    });
    return const SizedBox.shrink();
  }
}
