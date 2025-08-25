// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';

class NoPlantsWidget extends StatelessWidget {
  final VoidCallback? onAddPlant;

  const NoPlantsWidget({
    super.key,
    this.onAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    final textStyles = PlantasDesignTokens.textStyles(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(dimensoes['paddingXL']! + 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 80,
              color: cores['textoTerciario'],
            ),
            SizedBox(height: dimensoes['marginL']),
            Text(
              'Nenhuma planta cadastrada',
              style: textStyles['h3']!.copyWith(
                color: cores['textoSecundario'],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimensoes['marginM']),
            Text(
              'Adicione sua primeira planta para começar a cuidar dela com o Grow',
              style: textStyles['bodyLarge']!.copyWith(
                color: cores['textoTerciario'],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimensoes['marginXL']),
            if (onAddPlant != null)
              ElevatedButton.icon(
                onPressed: onAddPlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cores['primaria'],
                  foregroundColor: cores['textoClaro'],
                  padding: EdgeInsets.symmetric(
                    horizontal: dimensoes['paddingL']!,
                    vertical: dimensoes['paddingM']!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(dimensoes['radiusCircular']! / 2),
                  ),
                  elevation: dimensoes['elevationS'],
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Adicionar primeira planta',
                  style: textStyles['button'],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
