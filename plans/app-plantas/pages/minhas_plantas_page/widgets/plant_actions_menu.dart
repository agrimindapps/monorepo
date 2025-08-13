// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../planta_detalhes_page/services/i18n_service.dart';

class PlantActionsMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const PlantActionsMenu({
    super.key,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    final textStyles = PlantasDesignTokens.textStyles(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: cores['textoSecundario'],
        size: dimensoes['iconS']!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
      ),
      color: cores['fundoCard'], // Cor temática do fundo
      elevation: dimensoes['elevationL']!,
      offset: Offset(0, dimensoes['marginS']!),
      surfaceTintColor: cores['fundoCard'], // Remove tinta de superfície
      shadowColor: cores['sombra'], // Cor temática da sombra
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: cores['info'],
                size: dimensoes['iconS']!,
              ),
              SizedBox(width: dimensoes['paddingM']!),
              Text(
                I18nService.editPlantAction,
                style: textStyles['labelLarge']!,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: cores['erro'],
                size: dimensoes['iconS']!,
              ),
              SizedBox(width: dimensoes['paddingM']!),
              Text(
                I18nService.removePlantAction,
                style: textStyles['labelLarge']!,
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
        }
      },
    );
  }
}
