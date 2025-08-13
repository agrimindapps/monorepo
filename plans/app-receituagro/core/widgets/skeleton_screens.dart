// Flutter imports:
import 'package:flutter/material.dart';

/// Widget base para animações de skeleton loading
class SkeletonAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonAnimation> createState() => _SkeletonAnimationState();
}

class _SkeletonAnimationState extends State<SkeletonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
    
    final baseColor = widget.baseColor ?? 
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? 
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Widget para criar uma linha de skeleton
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
    );
  }
}

/// Widget para criar um avatar circular de skeleton
class SkeletonAvatar extends StatelessWidget {
  final double radius;

  const SkeletonAvatar({
    super.key,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton screen para lista de defensivos
class DefensivoSkeletonItem extends StatelessWidget {
  const DefensivoSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonAnimation(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone/Avatar
              const SkeletonAvatar(radius: 24),
              const SizedBox(width: 16),
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha principal (nome)
                    const SkeletonLine(
                      width: double.infinity,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    // Linha secundária (ingrediente)
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 14,
                    ),
                    const SizedBox(height: 4),
                    // Tags/classificação
                    Row(
                      children: [
                        const SkeletonLine(
                          width: 60,
                          height: 12,
                        ),
                        const SizedBox(width: 8),
                        SkeletonLine(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ícone trailing
              const SkeletonLine(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton screen para grid de defensivos
class DefensivoSkeletonGridItem extends StatelessWidget {
  const DefensivoSkeletonGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonAnimation(
      child: Card(
        margin: EdgeInsets.all(4),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone centralizado
              Center(
                child: SkeletonAvatar(radius: 30),
              ),
              SizedBox(height: 12),
              // Nome do defensivo
              SkeletonLine(
                width: double.infinity,
                height: 14,
              ),
              SizedBox(height: 6),
              // Ingrediente ativo
              SkeletonLine(
                width: double.infinity,
                height: 12,
              ),
              SizedBox(height: 8),
              // Tag de classificação
              Center(
                child: SkeletonLine(
                  width: 60,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton screen para item de pragas
class PragaSkeletonItem extends StatelessWidget {
  const PragaSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonAnimation(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagem da praga
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da praga
                    const SkeletonLine(
                      width: double.infinity,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    // Nome científico
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 14,
                    ),
                    const SizedBox(height: 4),
                    // Tipo de praga
                    const SkeletonLine(
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton screen para detalhes do defensivo
class DefensivoDetailsSkeletonScreen extends StatelessWidget {
  const DefensivoDetailsSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonAnimation(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const SkeletonLine(
              width: double.infinity,
              height: 24,
            ),
            const SizedBox(height: 16),
            
            // Ingrediente ativo
            const SkeletonLine(
              width: 250,
              height: 18,
            ),
            const SizedBox(height: 24),
            
            // Seção de características
            const SkeletonLine(
              width: 150,
              height: 16,
            ),
            const SizedBox(height: 12),
            
            // Lista de características
            ...List.generate(5, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SkeletonLine(
                    width: 120 + (index * 10).toDouble(),
                    height: 14,
                  ),
                  const SizedBox(width: 16),
                  const SkeletonLine(
                    width: 100,
                    height: 14,
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Seção de diagnósticos
            const SkeletonLine(
              width: 120,
              height: 16,
            ),
            const SizedBox(height: 12),
            
            // Lista de diagnósticos
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(
                        width: double.infinity,
                        height: 16,
                      ),
                      const SizedBox(height: 8),
                      const SkeletonLine(
                        width: 200,
                        height: 14,
                      ),
                      const SizedBox(height: 12),
                      // Múltiplas linhas de descrição
                      ...List.generate(3, (lineIndex) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SkeletonLine(
                          width: double.infinity - (lineIndex * 40).toDouble(),
                          height: 12,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que combina skeleton screens baseado no estado de carregamento
class ProgressiveLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasPartialData;
  final List<dynamic> partialData;
  final Widget Function(List<dynamic> data) dataBuilder;
  final Widget Function()? skeletonBuilder;
  final String loadingMessage;

  const ProgressiveLoadingWidget({
    super.key,
    required this.isLoading,
    required this.hasPartialData,
    required this.partialData,
    required this.dataBuilder,
    this.skeletonBuilder,
    this.loadingMessage = 'Carregando...',
  });

  @override
  Widget build(BuildContext context) {
    if (hasPartialData && partialData.isNotEmpty) {
      // Mostra dados parciais + skeleton para itens ainda carregando
      return Column(
        children: [
          // Dados já carregados
          Expanded(
            child: dataBuilder(partialData),
          ),
          // Skeleton para dados ainda carregando
          if (isLoading) ...[
            const Divider(),
            SizedBox(
              height: 100,
              child: skeletonBuilder?.call() ?? 
                  const Center(child: CircularProgressIndicator()),
            ),
          ],
        ],
      );
    } else if (isLoading) {
      // Apenas skeleton enquanto carrega
      return skeletonBuilder?.call() ?? 
          const Center(child: CircularProgressIndicator());
    } else {
      // Dados completos
      return dataBuilder(partialData);
    }
  }
}

/// Shimmer effect para skeleton (alternativa mais leve)
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.translate(
          offset: Offset(_animation.value * 100, 0),
          child: Opacity(
            opacity: 0.7 + (_animation.value.abs() * 0.3),
            child: widget.child,
          ),
        );
      },
    );
  }
}