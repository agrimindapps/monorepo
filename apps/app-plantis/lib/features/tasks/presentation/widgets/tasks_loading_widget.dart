import 'package:flutter/material.dart';

class TasksLoadingWidget extends StatelessWidget {
  final bool showSkeleton;
  
  const TasksLoadingWidget({super.key, this.showSkeleton = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (showSkeleton) {
      return _buildSkeletonLoading(theme);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicador de carregamento com ícone personalizado
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Icons.local_florist,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Carregando tarefas...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Verificando cuidados necessários para suas plantas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(ThemeData theme) {
    return Column(
      children: [
        // Date header skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _buildShimmer(3, 20, theme),
              const SizedBox(width: 12),
              _buildShimmer(150, 20, theme),
            ],
          ),
        ),
        // Task card skeletons
        ...List.generate(5, (index) => _buildSkeletonTaskCard(theme)),
        const SizedBox(height: 20),
        // Another date section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _buildShimmer(3, 20, theme),
              const SizedBox(width: 12),
              _buildShimmer(120, 20, theme),
            ],
          ),
        ),
        ...List.generate(3, (index) => _buildSkeletonTaskCard(theme)),
      ],
    );
  }

  Widget _buildSkeletonTaskCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon skeleton
          _buildShimmer(40, 40, theme, isCircle: true),
          const SizedBox(width: 16),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(200, 16, theme),
                const SizedBox(height: 8),
                _buildShimmer(120, 14, theme),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Action button skeleton
          _buildShimmer(40, 40, theme, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height, ThemeData theme, {bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: isCircle 
            ? BorderRadius.circular(width / 2)
            : BorderRadius.circular(4),
      ),
      child: _shimmerEffect(),
    );
  }

  Widget _shimmerEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
          colors: [
            Colors.grey.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.3),
            Colors.grey.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
