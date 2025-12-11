import 'package:core/core.dart' show Skeletonizer, Bone;
import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';

/// Widget de skeleton para a lista de tarefas
/// Simula o layout de grupos de tarefas agrupadas por data
class TasksListSkeleton extends StatelessWidget {
  const TasksListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primeiro grupo - "Hoje" com 2 tarefas
            _buildDateGroupSkeleton(context, 2),
            const SizedBox(height: 16),
            // Segundo grupo - "Amanhã" com 1 tarefa
            _buildDateGroupSkeleton(context, 1),
            const SizedBox(height: 16),
            // Terceiro grupo - data futura com 2 tarefas
            _buildDateGroupSkeleton(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroupSkeleton(BuildContext context, int taskCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header do grupo de data
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: const BoxDecoration(
                  color: PlantisColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              // Texto do header (skeleton)
              const Bone.text(
                words: 3,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        // Tarefas do grupo
        ...List.generate(taskCount, (index) => _buildTaskCardSkeleton(context)),
      ],
    );
  }

  Widget _buildTaskCardSkeleton(BuildContext context) {
    return PlantisCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar/Ícone da planta
          const Bone.circle(size: 48),
          const SizedBox(width: 12),
          // Textos (título e subtítulo)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(
                  words: 2,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Bone.text(words: 2, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          // Checkbox circular
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PlantisColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de skeleton para os filtros de tarefas
class TasksFiltersSkeleton extends StatelessWidget {
  const TasksFiltersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChipSkeleton('Atrasadas', hasCount: true),
              const SizedBox(width: 12),
              _buildFilterChipSkeleton(
                'Hoje',
                hasCount: true,
                isSelected: true,
              ),
              const SizedBox(width: 12),
              _buildFilterChipSkeleton('Próxima', hasCount: true),
              const SizedBox(width: 12),
              _buildFilterChipSkeleton('Futuras', hasCount: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipSkeleton(
    String label, {
    bool hasCount = false,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? PlantisColors.primary.withValues(alpha: 0.2)
            : PlantisColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            const Icon(Icons.check, size: 18, color: PlantisColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? PlantisColors.primary : Colors.grey[700],
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (hasCount) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: PlantisColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
