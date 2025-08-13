// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_list_display_widget.dart';
import '../../models/praga_item_model.dart';
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';
import 'praga_grid_item.dart';

class PragaGridView extends StatelessWidget {
  final List<PragaItemModel> pragas;
  final String pragaType;
  final bool isDark;
  final Function(PragaItemModel) onItemTap;

  const PragaGridView({
    super.key,
    required this.pragas,
    required this.pragaType,
    required this.isDark,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GenericListDisplayWidget<PragaItemModel>(
      items: pragas,
      isDark: isDark,
      isGridMode: true,
      onItemTap: onItemTap,
      itemBuilder: (item, index, isDark, onTap) => PragaGridItem(
        key: ValueKey('grid_${item.idReg}'),
        praga: item,
        pragaType: pragaType,
        isDark: isDark,
        onTap: onTap,
        index: index,
      ),
      wrapWithCard: false,
      calculateCrossAxisCount: PragaUtils.calculateCrossAxisCount,
      gridSpacing: PragaConstants.gridSpacing,
      cardElevation: 0,
      borderRadius: PragaConstants.borderRadius,
      darkContainerColor: PragaConstants.darkContainerColor,
      cardMargin: const EdgeInsets.only(top: PragaConstants.gridTopPadding),
      cardPadding: const EdgeInsets.all(PragaConstants.mediumPadding),
    );
  }
}
