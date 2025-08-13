// Flutter imports

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/bootstrap/bootstrap_phase.dart';
import 'grid_painter.dart';
import 'loading_state.dart';
import 'loading_widget.dart';

// Package imports

// Project imports

class CarregandoPage extends StatefulWidget {
  final BootstrapPhase? currentPhase;
  final bool? hasError;
  final VoidCallback? onRetry;
  
  const CarregandoPage({
    super.key,
    this.currentPhase,
    this.hasError,
    this.onRetry,
  });

  @override
  State<CarregandoPage> createState() => _CarregandoPageState();
}

class _CarregandoPageState extends State<CarregandoPage>
    with SingleTickerProviderStateMixin {
  final _currentState = LoadingState.initial.obs;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(begin: 0, end: 2 * 3.14159)
        .animate(_backgroundController);

    // Define estado inicial baseado nos parâmetros recebidos
    _updateStateFromPhase();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  /// Atualiza o estado visual baseado na fase do bootstrapper
  void _updateStateFromPhase() {
    if (widget.hasError == true) {
      _currentState.value = LoadingState.error;
      return;
    }
    
    if (widget.currentPhase != null) {
      _currentState.value = bootstrapPhaseToLoadingState(widget.currentPhase!);
    }
  }
  
  /// Atualiza estado quando recebe novos parâmetros
  void updatePhase(BootstrapPhase? phase, bool? error) {
    if (!mounted) return;
    
    if (error == true) {
      _currentState.value = LoadingState.error;
      return;
    }
    
    if (phase != null) {
      _currentState.value = bootstrapPhaseToLoadingState(phase);
    }
  }

  void _handleRetry() {
    // Não faz mais inicialização aqui - apenas notifica que retry foi solicitado
    // O app.dart deve escutar este callback e reinicializar o bootstrapper
    _currentState.value = LoadingState.initial;
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final standardColor =
        isDark ? Colors.green.shade300 : Colors.green.shade700;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Gradiente de fundo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.green.shade900.withValues(alpha: 0.16)
                        : Colors.green.shade50,
                    isDark ? Colors.grey.shade900 : Colors.white,
                  ],
                ),
              ),
            ),
            // Grid animado
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(
                        _backgroundAnimation.value * 0.02), // Rotação suave
                  alignment: Alignment.center,
                  child: CustomPaint(
                    painter: GridPainter(
                      isDark: isDark,
                      color: standardColor.withValues(alpha: 0.05),
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
            // Conteúdo principal com blur
            BackdropFilter(
              filter: const ColorFilter.matrix([
                1,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                0.9,
                0,
              ]),
              child: Center(
                child: Obx(() => LoadingWidget(
                      state: _currentState.value,
                      onRetry: _currentState.value == LoadingState.error
                          ? _handleRetry
                          : null,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
