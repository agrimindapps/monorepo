import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/plant.dart';
import '../../../domain/usecases/update_plant_usecase.dart';
import '../../providers/plant_details_provider.dart';
import '../../providers/plants_notifier.dart';

/// Widget responsável por exibir as informações básicas da planta
class PlantInfoSection extends ConsumerWidget {
  final Plant plant;

  const PlantInfoSection({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfo(context),
        const SizedBox(height: 24),
        _buildNotesCard(context, ref),
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          if (plant.species?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plant.displaySpecies,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Plantada há',
                  value:
                      plant.plantingDate != null
                          ? '${plant.ageInDays} dias'
                          : 'Data não informada',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Localização',
                  value: plant.spaceId != null ? 'Definida' : 'Não definida',
                ),
              ),
            ],
          ),

          if (plant.config != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.wb_sunny_outlined,
                    label: 'Luz',
                    value: _getLightRequirementText(
                      plant.config!.lightRequirement,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.water_drop_outlined,
                    label: 'Água',
                    value: _getWaterAmountText(plant.config!.waterAmount),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                theme.brightness == Brightness.dark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFFFFFFF), // Branco puro
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone de edição
              Row(
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plant.notes?.isNotEmpty == true
                          ? 'Notas da planta'
                          : 'Adicionar notas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => _showEditNotesDialog(context, ref),
                    tooltip: 'Editar observações',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Conteúdo das notas
              Text(
                plant.notes?.isNotEmpty == true
                    ? plant.notes!
                    : 'Nenhuma observação registrada para esta planta.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      plant.notes?.isNotEmpty == true
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                  fontStyle:
                      plant.notes?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditNotesDialog(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController(text: plant.notes ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, size: 24),
            SizedBox(width: 12),
            Text('Editar Observações'),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: notesController,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Digite suas observações sobre a planta...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNotes = notesController.text.trim();

              // Cria os parâmetros de atualização
              final updateParams = UpdatePlantParams(
                id: plant.id,
                name: plant.name,
                species: plant.species,
                spaceId: plant.spaceId,
                imageUrls: plant.imageUrls,
                plantingDate: plant.plantingDate,
                notes: newNotes.isEmpty ? null : newNotes,
                config: plant.config,
                isFavorited: plant.isFavorited,
              );

              // Chama o provider para atualizar
              final notifier = ref.read(plantsNotifierProvider.notifier);
              final success = await notifier.updatePlant(updateParams);

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();

                // Atualiza o provider de detalhes para refletir as mudanças
                if (success) {
                  ref.read(plantDetailsNotifierProvider.notifier).loadPlant(plant.id);
                }

                // Mostra feedback
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Observações atualizadas com sucesso'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao atualizar observações'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose do controller após o dialog fechar
      notesController.dispose();
    });
  }

  String _getLightRequirementText(String? lightRequirement) {
    switch (lightRequirement?.toLowerCase()) {
      case 'low':
        return 'Pouca luz';
      case 'medium':
        return 'Luz moderada';
      case 'high':
        return 'Muita luz';
      default:
        return 'Não definido';
    }
  }

  String _getWaterAmountText(String? waterAmount) {
    switch (waterAmount?.toLowerCase()) {
      case 'little':
        return 'Pouca água';
      case 'moderate':
        return 'Água moderada';
      case 'plenty':
        return 'Muita água';
      default:
        return 'Não definido';
    }
  }
}
