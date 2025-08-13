// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/controllers/theme_controller.dart';
import '../../core/utils/global_theme_helper.dart';
import '../core/extensions/theme_extensions.dart';

/// Widget de exemplo demonstrando o uso das extensões de tema do app-plantas
/// Baseado nos padrões documentados do app-receituagro
class ThemedPlantCard extends StatelessWidget {
  final String plantName;
  final String species;
  final String status;
  final IconData statusIcon;
  final VoidCallback? onTap;

  const ThemedPlantCard({
    super.key,
    required this.plantName,
    required this.species,
    required this.status,
    required this.statusIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usando as extensões criadas
    return Obx(() {
      final isHealthy = status.toLowerCase().contains('saudável');
      final needsWater = status.toLowerCase().contains('água');
      final needsSun = status.toLowerCase().contains('sol');

      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com status
                _buildHeader(context, isHealthy, needsWater, needsSun),

                const SizedBox(height: 12),

                // Informações da planta
                _buildPlantInfo(context),

                const SizedBox(height: 8),

                // Status da planta
                _buildStatusInfo(context, isHealthy, needsWater, needsSun),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(
      BuildContext context, bool isHealthy, bool needsWater, bool needsSun) {
    Color statusColor;
    if (isHealthy) {
      statusColor = context.plantasSuccess;
    } else if (needsWater) {
      statusColor = Colors.blue;
    } else if (needsSun) {
      statusColor = Colors.orange;
    } else {
      statusColor = context.plantasError;
    }

    return Row(
      children: [
        // Ícone de status
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        // Título
        Expanded(
          child: Text(
            plantName,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Indicador de tema (apenas para demo)
        _buildThemeIndicator(context),
      ],
    );
  }

  Widget _buildPlantInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Espécie',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          species,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatusInfo(
      BuildContext context, bool isHealthy, bool needsWater, bool needsSun) {
    Color statusColor;
    String statusText;

    if (isHealthy) {
      statusColor = context.plantasSuccess;
      statusText = '✓ Planta saudável';
    } else if (needsWater) {
      statusColor = Colors.blue;
      statusText = '💧 Precisa de água';
    } else if (needsSun) {
      statusColor = Colors.orange;
      statusText = '☀️ Precisa de sol';
    } else {
      statusColor = context.plantasError;
      statusText = '⚠️ Precisa de cuidados';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Indicador visual do tema atual (apenas para demonstração)
  Widget _buildThemeIndicator(BuildContext context) {
    if (!Get.isRegistered<ThemeController>()) {
      return const SizedBox.shrink();
    }

    final themeController = Get.find<ThemeController>();

    return Obx(() => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            themeController.isDark.value ? Icons.dark_mode : Icons.light_mode,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
        ));
  }
}

/// Widget de demonstração para mostrar todas as cores customizadas
class PlantasColorPalette extends StatelessWidget {
  const PlantasColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palette de Cores - App Plantas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildColorRow(
            context,
            'Cores Principais',
            [
              ('Primary', Theme.of(context).primaryColor),
              ('Plant Color', Colors.green),
              ('Surface', Theme.of(context).colorScheme.surface),
              ('Text', Theme.of(context).colorScheme.onSurface),
            ],
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            context,
            'Cores de Status',
            [
              ('Saudável', context.plantasSuccess),
              ('Doente', context.plantasError),
              ('Precisa Água', Colors.blue),
              ('Precisa Sol', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          _buildColorRow(
            context,
            'Cores de Ação',
            [
              ('Adubar', Colors.brown),
              ('Replantar', Colors.purple),
              ('Sucesso', context.plantasSuccess),
              ('Erro', context.plantasError),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(
    BuildContext context,
    String title,
    List<(String, Color)> colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((colorInfo) {
            final (name, color) = colorInfo;
            return _buildColorSwatch(context, name, color);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(BuildContext context, String name, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget de debug para tema (apenas para desenvolvimento)
class PlantasThemeDebugWidget extends StatelessWidget {
  const PlantasThemeDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔧 Debug de Tema',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          // Informações básicas
          GlobalThemeHelper.debugThemeInfo(),

          const SizedBox(height: 12),

          // Botões de controle
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: GlobalThemeHelper.toggleTheme,
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  size: 16,
                ),
                label: Text(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'Tema Claro'
                      : 'Tema Escuro',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: GlobalThemeHelper.logThemeInfo,
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('Log Debug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
