// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/loading_state.dart';

/// Widget para exibir diferentes estados de loading padronizados
class LoadingStateWidget extends StatelessWidget {
  final LoadingStateManager loadingManager;
  final LoadingStateType type;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showOverlay;

  const LoadingStateWidget({
    super.key,
    required this.loadingManager,
    required this.type,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = loadingManager.getState(type);
    
    if (showOverlay && state.isLoading) {
      return Stack(
        children: [
          child,
          _buildLoadingOverlay(context, state),
        ],
      );
    }

    if (state.isLoading) {
      return loadingWidget ?? _buildDefaultLoading(context, state);
    }

    if (state.error != null) {
      return errorWidget ?? _buildDefaultError(context, state);
    }

    return child;
  }

  Widget _buildLoadingOverlay(BuildContext context, LoadingState state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E22) 
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (state.message != null) ...[
                  const SizedBox(height: 8),
                  Text(state.message!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLoading(BuildContext context, LoadingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (state.message != null) ...[
            const SizedBox(height: 16),
            Text(
              state.message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultError(BuildContext context, LoadingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            state.message ?? 'Ocorreu um erro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Detalhes: ${state.error.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Aqui você pode implementar lógica de retry
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}

/// Widget específico para loading de diagnóstico
class DiagnosticLoadingWidget extends StatelessWidget {
  final String? message;

  const DiagnosticLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
              ),
              Icon(
                Icons.medical_services,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Carregando diagnóstico...',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget específico para loading de favoritos
class FavoriteLoadingWidget extends StatelessWidget {
  final String? message;

  const FavoriteLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget específico para loading de TTS
class TtsLoadingWidget extends StatelessWidget {
  final String? message;

  const TtsLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para indicar loading em linha
class InlineLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const InlineLoadingWidget({
    super.key,
    this.message,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
