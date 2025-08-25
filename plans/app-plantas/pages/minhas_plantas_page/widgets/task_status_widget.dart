// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../planta_detalhes_page/services/i18n_service.dart';

class TaskStatusWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tarefasPendentes;

  const TaskStatusWidget({
    super.key,
    required this.tarefasPendentes,
  });

  @override
  Widget build(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    final textStyles = PlantasDesignTokens.textStyles(context);

    if (tarefasPendentes.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: dimensoes['paddingS']!,
          vertical: dimensoes['paddingXS']!,
        ),
        decoration: BoxDecoration(
          color: cores['sucessoClaro'],
          borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
          border: Border.all(
            color: cores['sucesso']!.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: cores['sucesso'],
              size: dimensoes['iconXS'],
            ),
            SizedBox(width: dimensoes['paddingXS']),
            Text(
              I18nService.allCareUpToDate,
              style: textStyles['caption']!.copyWith(
                color: cores['sucesso'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final pendingCount = tarefasPendentes.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensoes['paddingS']!,
        vertical: dimensoes['paddingXS']!,
      ),
      decoration: BoxDecoration(
        color: cores['avisoClaro'],
        borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
        border: Border.all(
          color: cores['aviso']!.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color: cores['aviso'],
            size: dimensoes['iconXS'],
          ),
          SizedBox(width: dimensoes['paddingXS']),
          Text(
            I18nService.pendingCareCount(pendingCount),
            style: textStyles['caption']!.copyWith(
              color: cores['aviso'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
