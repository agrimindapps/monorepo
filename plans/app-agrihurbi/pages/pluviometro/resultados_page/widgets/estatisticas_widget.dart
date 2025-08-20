// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import 'estatistica_item_widget.dart';
import 'pluviometria_models.dart';

class EstatisticasWidget extends StatelessWidget {
  final EstatisticasPluviometria estatisticas;

  const EstatisticasWidget({super.key, required this.estatisticas});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final estatisticasItens =
        EstatisticaItemModel.fromPluviometriaMap(estatisticas.toDisplayMap());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShadcnStyle.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: AlignedGridView.count(
        crossAxisCount: isSmallScreen ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: estatisticasItens.length,
        itemBuilder: (context, index) => EstatisticaItemWidget(
          item: estatisticasItens[index],
          cor: ShadcnStyle.textColor,
        ),
      ),
    );
  }
}
