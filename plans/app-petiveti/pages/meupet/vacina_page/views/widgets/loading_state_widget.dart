// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/vacina_colors.dart';
import '../styles/vacina_constants.dart';

/// A reusable widget for displaying loading states in the vaccine module.
/// 
/// This widget provides a consistent and user-friendly way to display
/// loading states throughout the vaccine management interface. It includes
/// customizable loading indicators, messages, and progress tracking.
/// 
/// Features:
/// - Multiple loading indicator types (circular, linear, custom)
/// - Customizable loading message and styling
/// - Progress tracking support
/// - Responsive design with proper spacing
/// - Theme-aware styling
/// - Accessibility support
/// - Different loading scenarios (data, refresh, upload)
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final Widget? customIndicator;
  final Color? indicatorColor;
  final Color? textColor;
  final double? indicatorSize;
  final EdgeInsets? padding;
  final bool showMessage;
  final MainAxisAlignment mainAxisAlignment;
  final double? progress;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.customIndicator,
    this.indicatorColor,
    this.textColor,
    this.indicatorSize,
    this.padding,
    this.showMessage = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.progress,
  });

  /// Creates a loading widget for data loading operations.
  factory LoadingStateWidget.data({
    String? message,
  }) {
    return LoadingStateWidget(
      message: message ?? 'Carregando vacinas...',
      customIndicator: const CircularProgressIndicator(),
    );
  }

  /// Creates a loading widget for refresh operations.
  factory LoadingStateWidget.refresh({
    String? message,
  }) {
    return LoadingStateWidget(
      message: message ?? 'Atualizando dados...',
      customIndicator: const CircularProgressIndicator(),
    );
  }

  /// Creates a loading widget for upload operations.
  factory LoadingStateWidget.upload({
    String? message,
    double? progress,
  }) {
    return LoadingStateWidget(
      message: message ?? 'Enviando dados...',
      progress: progress,
    );
  }

  /// Creates a loading widget for search operations.
  factory LoadingStateWidget.search({
    String? message,
  }) {
    return LoadingStateWidget(
      message: message ?? 'Buscando vacinas...',
      customIndicator: const CircularProgressIndicator(),
    );
  }

  /// Creates a minimal loading widget with just an indicator.
  factory LoadingStateWidget.minimal() {
    return const LoadingStateWidget(
      showMessage: false,
      customIndicator: CircularProgressIndicator(),
    );
  }

  /// Creates a loading widget with linear progress indicator.
  factory LoadingStateWidget.linear({
    String? message,
    double? progress,
  }) {
    return LoadingStateWidget(
      message: message ?? 'Processando...',
      progress: progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(VacinaConstants.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIndicator(context),
            if (showMessage && message != null) ...[
              const SizedBox(height: VacinaConstants.espacamentoPadrao * 2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? VacinaColors.cinza(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (progress != null) ...[
              const SizedBox(height: VacinaConstants.espacamentoPadrao),
              Text(
                '${(progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor ?? VacinaColors.cinza(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate loading indicator based on configuration.
  Widget _buildIndicator(BuildContext context) {
    if (customIndicator != null) {
      return customIndicator!;
    }

    if (progress != null) {
      return SizedBox(
        width: indicatorSize ?? 200,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: VacinaColors.cinzaClaro(context),
          valueColor: AlwaysStoppedAnimation<Color>(
            indicatorColor ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return CircularProgressIndicator(
      strokeWidth: 3.0,
      valueColor: AlwaysStoppedAnimation<Color>(
        indicatorColor ?? Theme.of(context).primaryColor,
      ),
    );
  }
}

/// A specialized loading widget for list operations.
class ListLoadingWidget extends StatelessWidget {
  final String? message;
  final bool isRefreshing;
  final VoidCallback? onRefresh;

  const ListLoadingWidget({
    super.key,
    this.message,
    this.isRefreshing = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isRefreshing) {
      return SliverToBoxAdapter(
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: VacinaConstants.espacamentoIconeTexto),
              Text(
                'Atualizando...',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverFillRemaining(
      child: LoadingStateWidget.data(message: message),
    );
  }
}

/// A loading widget with shimmer effect for better UX.
class ShimmerLoadingWidget extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const ShimmerLoadingWidget({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
        return Column(
          children: List.generate(
            widget.itemCount,
            (index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: VacinaConstants.espacamentoPadrao,
                vertical: VacinaConstants.espacamentoPadrao / 2,
              ),
              child: Card(
                child: Container(
                  height: widget.itemHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        VacinaColors.cinzaClaro(context).withValues(alpha: 0.3),
                        VacinaColors.cinzaClaro(context).withValues(alpha: 0.1),
                        VacinaColors.cinzaClaro(context).withValues(alpha: 0.3),
                      ],
                      stops: [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                    ),
                    borderRadius: BorderRadius.circular(VacinaConstants.bordaCircularPadrao),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
