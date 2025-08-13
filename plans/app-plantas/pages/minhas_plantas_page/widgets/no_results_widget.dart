// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';

class NoResultsWidget extends StatelessWidget {
  final String searchTerm;

  const NoResultsWidget({
    super.key,
    required this.searchTerm,
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
              Icons.search_off,
              size: 80,
              color: cores['textoTerciario'],
            ),
            SizedBox(height: dimensoes['marginL']!),
            Text(
              'Nenhum resultado encontrado',
              style: textStyles['h3']!.copyWith(
                color: cores['textoSecundario'],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimensoes['marginM']!),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textStyles['bodyLarge']!.copyWith(
                  color: cores['textoTerciario'],
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Não encontramos plantas com '),
                  TextSpan(
                    text: '"$searchTerm"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cores['primaria'],
                    ),
                  ),
                  const TextSpan(text: '.\nTente buscar por outro termo.'),
                ],
              ),
            ),
            SizedBox(height: dimensoes['marginL']!),
            Container(
              padding: EdgeInsets.all(dimensoes['paddingM']!),
              decoration: BoxDecoration(
                color: cores['infoClaro'],
                borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
                border: Border.all(
                  color: cores['info']!.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: cores['info'],
                    size: dimensoes['iconS']!,
                  ),
                  SizedBox(width: dimensoes['paddingM']!),
                  Expanded(
                    child: Text(
                      'Dica: Tente buscar pelo nome da planta ou espécie',
                      style: textStyles['labelLarge']!.copyWith(
                        color: cores['info'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
