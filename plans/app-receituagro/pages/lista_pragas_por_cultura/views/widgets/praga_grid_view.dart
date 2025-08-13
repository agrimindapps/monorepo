// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_list_display_widget.dart';
import '../../models/praga_cultura_item_model.dart';
import '../../utils/praga_cultura_constants.dart';
import '../../utils/praga_cultura_utils.dart';
import 'empty_state_widget.dart';
import 'praga_grid_item.dart';

class PragaGridView extends StatelessWidget {
  final List<PragaCulturaItemModel> pragas;
  final bool isDark;
  final Function(PragaCulturaItemModel) onItemTap;

  const PragaGridView({
    super.key,
    required this.pragas,
    required this.isDark,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GenericListDisplayWidget<PragaCulturaItemModel>(
      items: pragas,
      isDark: isDark,
      isGridMode: true,
      onItemTap: onItemTap,
      itemBuilder: (item, index, isDark, onTap) => PragaGridItem(
        key: ValueKey('grid_${item.idReg}'),
        item: item,
        index: index,
        isDark: isDark,
        onTap: onTap,
      ),
      emptyMessage: 'Nenhum resultado encontrado',
      wrapWithCard: true,
      calculateCrossAxisCount: PragaCulturaUtils.calculateCrossAxisCount,
      gridSpacing: PragaCulturaConstants.gridSpacing,
      cardElevation: 0, // Removida elevação
      borderRadius: PragaCulturaConstants.borderRadius,
      darkContainerColor: PragaCulturaConstants.darkContainerColor,
      cardMargin:
          const EdgeInsets.only(top: PragaCulturaConstants.gridTopPadding),
      cardPadding: const EdgeInsets.all(PragaCulturaConstants.smallPadding),
      emptyStateBuilder: (message, isDark) => EmptyStateWidget(
        message: message,
        isDark: isDark,
      ),
    );
  }
}
