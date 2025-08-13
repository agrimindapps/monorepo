// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'loading_state.dart';

class LoadingWidget extends StatefulWidget {
  final LoadingState state;
  final VoidCallback? onRetry;

  const LoadingWidget({
    super.key,
    required this.state,
    this.onRetry,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final standardColor =
        isDark ? Colors.green.shade300 : Colors.green.shade700;
    final backgroundOpacity = isDark ? 0.16 : 1.0;
    final backgroundColor = isDark
        ? Colors.green.withValues(alpha: backgroundOpacity)
        : Colors.green.shade50;
    final borderColor = isDark
        ? Colors.green.shade700.withValues(alpha: 0.39)
        : Colors.green.shade100;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animado com efeito de escala
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: standardColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/imagens/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Icon(
                  widget.state == LoadingState.error
                      ? Icons.error_outline
                      : Icons.agriculture,
                  size: 60,
                  color: widget.state == LoadingState.error
                      ? theme.colorScheme.error
                      : standardColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Barra de progresso estilizada
          if (widget.state != LoadingState.error) ...[
            SizedBox(
              width: 240,
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Barra de fundo
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.green.shade900.withValues(alpha: 0.2)
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Barra de progresso animada
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 12,
                        width: 240 * widget.state.progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [
                              standardColor.withValues(alpha: 0.7),
                              standardColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: standardColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // Indicador de progresso pulsante
                      Positioned(
                        left: (240 * widget.state.progress) - 8,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: standardColor,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: standardColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Percentual de progresso
                  Text(
                    '${(widget.state.progress * 100).toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: standardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Mensagem de status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: widget.state == LoadingState.error
                  ? isDark
                      ? Colors.red.shade900.withValues(alpha: 0.2)
                      : Colors.red.shade50
                  : backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.state == LoadingState.error
                    ? isDark
                        ? Colors.red.shade300.withValues(alpha: 0.3)
                        : Colors.red.shade200
                    : borderColor,
              ),
            ),
            child: Text(
              widget.state.message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: widget.state == LoadingState.error
                    ? isDark
                        ? Colors.red.shade300
                        : Colors.red.shade700
                    : isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Botão de retry em caso de erro
          if (widget.state == LoadingState.error && widget.onRetry != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.red.shade900.withValues(alpha: 0.3)
                    : Colors.red.shade50,
                foregroundColor:
                    isDark ? Colors.red.shade300 : Colors.red.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark
                        ? Colors.red.shade300.withValues(alpha: 0.3)
                        : Colors.red.shade200,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
