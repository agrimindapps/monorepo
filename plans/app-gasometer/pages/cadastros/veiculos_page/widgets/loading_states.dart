// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Estados específicos de carregamento para diferentes operações
enum LoadingState {
  idle, // Nenhuma operação em andamento
  loadingVeiculos, // Carregando lista de veículos
  savingVeiculo, // Salvando um veículo
  updatingVeiculo, // Atualizando um veículo
  deletingVeiculo, // Deletando um veículo
  exportingData, // Exportando dados para CSV
  loadingVehicleDetails, // Carregando detalhes de um veículo específico
  checkingRecords, // Verificando registros associados
  updatingOdometer, // Atualizando odômetro
  validatingData, // Validando dados do veículo
  syncingWithCloud, // Sincronizando com cloud/firestore
}

/// Extension para facilitar uso do LoadingState
extension LoadingStateExtension on LoadingState {
  /// Verifica se está em estado de loading
  bool get isLoading => this != LoadingState.idle;

  /// Verifica se está idle
  bool get isIdle => this == LoadingState.idle;

  /// Obtém mensagem amigável para o usuário
  String get userMessage {
    switch (this) {
      case LoadingState.idle:
        return '';
      case LoadingState.loadingVeiculos:
        return 'Carregando veículos...';
      case LoadingState.savingVeiculo:
        return 'Salvando veículo...';
      case LoadingState.updatingVeiculo:
        return 'Atualizando veículo...';
      case LoadingState.deletingVeiculo:
        return 'Removendo veículo...';
      case LoadingState.exportingData:
        return 'Exportando dados...';
      case LoadingState.loadingVehicleDetails:
        return 'Carregando detalhes...';
      case LoadingState.checkingRecords:
        return 'Verificando registros...';
      case LoadingState.updatingOdometer:
        return 'Atualizando odômetro...';
      case LoadingState.validatingData:
        return 'Validando dados...';
      case LoadingState.syncingWithCloud:
        return 'Sincronizando...';
    }
  }

  /// Obtém descrição técnica para logs
  String get technicalDescription {
    switch (this) {
      case LoadingState.idle:
        return 'No operation in progress';
      case LoadingState.loadingVeiculos:
        return 'Loading vehicles from repository';
      case LoadingState.savingVeiculo:
        return 'Saving vehicle to repository';
      case LoadingState.updatingVeiculo:
        return 'Updating vehicle in repository';
      case LoadingState.deletingVeiculo:
        return 'Deleting vehicle from repository';
      case LoadingState.exportingData:
        return 'Exporting vehicle data to CSV';
      case LoadingState.loadingVehicleDetails:
        return 'Loading specific vehicle details';
      case LoadingState.checkingRecords:
        return 'Checking associated records';
      case LoadingState.updatingOdometer:
        return 'Updating vehicle odometer';
      case LoadingState.validatingData:
        return 'Validating vehicle data';
      case LoadingState.syncingWithCloud:
        return 'Syncing data with cloud storage';
    }
  }

  /// Verifica se é uma operação de longa duração
  bool get isLongRunning {
    switch (this) {
      case LoadingState.exportingData:
      case LoadingState.syncingWithCloud:
      case LoadingState.loadingVeiculos:
        return true;
      default:
        return false;
    }
  }

  /// Verifica se permite cancelamento
  bool get isCancellable {
    switch (this) {
      case LoadingState.exportingData:
      case LoadingState.syncingWithCloud:
      case LoadingState.loadingVeiculos:
        return true;
      default:
        return false;
    }
  }

  /// Obtém ícone representativo
  IconData get icon {
    switch (this) {
      case LoadingState.idle:
        return Icons.check_circle_outline;
      case LoadingState.loadingVeiculos:
        return Icons.directions_car_outlined;
      case LoadingState.savingVeiculo:
        return Icons.save_outlined;
      case LoadingState.updatingVeiculo:
        return Icons.edit_outlined;
      case LoadingState.deletingVeiculo:
        return Icons.delete_outline;
      case LoadingState.exportingData:
        return Icons.download_outlined;
      case LoadingState.loadingVehicleDetails:
        return Icons.info_outline;
      case LoadingState.checkingRecords:
        return Icons.search_outlined;
      case LoadingState.updatingOdometer:
        return Icons.speed_outlined;
      case LoadingState.validatingData:
        return Icons.verified_outlined;
      case LoadingState.syncingWithCloud:
        return Icons.cloud_sync_outlined;
    }
  }

  /// Obtém cor temática do estado
  Color get color {
    switch (this) {
      case LoadingState.idle:
        return Colors.green;
      case LoadingState.deletingVeiculo:
        return Colors.red;
      case LoadingState.savingVeiculo:
      case LoadingState.updatingVeiculo:
        return Colors.blue;
      case LoadingState.exportingData:
        return Colors.orange;
      case LoadingState.syncingWithCloud:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// Widget para exibir skeleton loading durante carregamento inicial
class VeiculosSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final bool isGridView;

  const VeiculosSkeletonLoader({
    super.key,
    this.itemCount = 6,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridSkeleton();
    } else {
      return _buildListSkeleton();
    }
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildSkeletonListItem(),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            _buildShimmerBox(height: 80, width: double.infinity),
            const SizedBox(height: 12),

            // Title placeholder
            _buildShimmerBox(height: 16, width: 120),
            const SizedBox(height: 8),

            // Subtitle placeholder
            _buildShimmerBox(height: 14, width: 100),
            const SizedBox(height: 8),

            // Details placeholder
            _buildShimmerBox(height: 12, width: 80),
            const Spacer(),

            // Button placeholder
            _buildShimmerBox(height: 32, width: double.infinity),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonListItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading icon placeholder
            _buildShimmerBox(height: 48, width: 48, borderRadius: 24),
            const SizedBox(width: 16),

            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(height: 16, width: 150),
                  const SizedBox(height: 8),
                  _buildShimmerBox(height: 14, width: 100),
                  const SizedBox(height: 4),
                  _buildShimmerBox(height: 12, width: 80),
                ],
              ),
            ),

            // Trailing placeholder
            _buildShimmerBox(height: 24, width: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    double borderRadius = 8,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _ShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Widget para exibir indicador de loading com contexto específico
class ContextualLoadingIndicator extends StatelessWidget {
  final LoadingState state;
  final String? customMessage;
  final bool showIcon;
  final bool showProgress;
  final double? progress; // 0.0 to 1.0
  final VoidCallback? onCancel;
  final EdgeInsets padding;

  const ContextualLoadingIndicator({
    super.key,
    required this.state,
    this.customMessage,
    this.showIcon = true,
    this.showProgress = false,
    this.progress,
    this.onCancel,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    if (state.isIdle) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              state.icon,
              size: 32,
              color: state.color,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            customMessage ?? state.userMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: state.color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (showProgress && progress != null) ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: state.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(state.color),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress! * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ] else if (state.isLongRunning) ...[
            LinearProgressIndicator(
              backgroundColor: state.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(state.color),
            ),
            const SizedBox(height: 16),
          ] else ...[
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(state.color),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (state.isCancellable && onCancel != null) ...[
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget overlay para loading em tela cheia
class LoadingOverlay extends StatelessWidget {
  final LoadingState state;
  final String? customMessage;
  final double? progress;
  final VoidCallback? onCancel;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    required this.state,
    this.customMessage,
    this.progress,
    this.onCancel,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isIdle) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: dismissible,
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ContextualLoadingIndicator(
                state: state,
                customMessage: customMessage,
                showProgress: progress != null,
                progress: progress,
                onCancel: onCancel,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para loading inline em botões
class LoadingButton extends StatelessWidget {
  final LoadingState state;
  final VoidCallback? onPressed;
  final String text;
  final String? loadingText;
  final Widget? icon;
  final ButtonStyle? style;
  final bool enabled;

  const LoadingButton({
    super.key,
    required this.state,
    required this.onPressed,
    required this.text,
    this.loadingText,
    this.icon,
    this.style,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = state.isLoading;
    final buttonText = isLoading ? (loadingText ?? state.userMessage) : text;

    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(buttonText),
        ],
      ),
    );
  }
}

/// Widget para timeout handling
class TimeoutHandler extends StatefulWidget {
  final LoadingState state;
  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  const TimeoutHandler({
    super.key,
    required this.state,
    required this.timeout,
    required this.onTimeout,
    required this.child,
  });

  @override
  State<TimeoutHandler> createState() => _TimeoutHandlerState();
}

class _TimeoutHandlerState extends State<TimeoutHandler> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimeoutIfNeeded();
  }

  @override
  void didUpdateWidget(TimeoutHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _startTimeoutIfNeeded();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutIfNeeded() {
    _timeoutTimer?.cancel();

    if (widget.state.isLoading) {
      _timeoutTimer = Timer(widget.timeout, () {
        if (mounted && widget.state.isLoading) {
          widget.onTimeout();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Efeito shimmer para skeleton loading
class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white70,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Extensão para facilitar uso no GetX
extension LoadingStateGetX on Rx<LoadingState> {
  /// Verifica se está carregando
  bool get isLoading => value.isLoading;

  /// Verifica se está idle
  bool get isIdle => value.isIdle;

  /// Define estado para loading específico
  void setLoading(LoadingState state) => value = state;

  /// Volta para idle
  void setIdle() => value = LoadingState.idle;

  /// Executa operação com loading state
  Future<T> withLoading<T>(
    LoadingState state,
    Future<T> Function() operation,
  ) async {
    setLoading(state);
    try {
      return await operation();
    } finally {
      setIdle();
    }
  }
}
