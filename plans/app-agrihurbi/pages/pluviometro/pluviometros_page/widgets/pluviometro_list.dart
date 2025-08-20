// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import 'no_data_state.dart';
import 'pluviometro_card.dart';

class PluviometrosList extends StatelessWidget {
  final List<Pluviometro> pluviometros;
  final Function(String action, Pluviometro pluviometro) onMenuAction;
  final Function(Pluviometro pluviometro) onTap;

  const PluviometrosList({
    super.key,
    required this.pluviometros,
    required this.onMenuAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pluviometros.isEmpty) {
      return const NoDataStateWidget();
    }

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

      return AlignedGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: pluviometros.length,
        itemBuilder: (context, index) {
          return PluviometroCard(
            pluviometro: pluviometros[index],
            onMenuAction: onMenuAction,
            onTap: onTap,
          );
        },
      );
    });
  }
}
