// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_list_display_widget.dart';
import '../../models/praga_cultura_item_model.dart';
import '../../utils/praga_cultura_constants.dart';
import '../../utils/praga_cultura_utils.dart';
import 'empty_state_widget.dart';
import 'praga_list_item.dart';

class PragaListView extends StatelessWidget {
  final List<PragaCulturaItemModel> pragas;
  final bool isDark;
  final Function(PragaCulturaItemModel) onItemTap;

  const PragaListView({
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
      isGridMode: false,
      onItemTap: onItemTap,
      itemBuilder: (item, index, isDark, onTap) => PragaListItem(
        item: item,
        index: index,
        isDark: isDark,
        onTap: onTap,
      ),
      emptyMessage: 'Nenhum resultado encontrado',
      wrapWithCard: true,
      calculateCrossAxisCount: PragaCulturaUtils.calculateCrossAxisCount,
      cardElevation: 0, // Removida elevação
      borderRadius: PragaCulturaConstants.borderRadius,
      darkContainerColor: PragaCulturaConstants.darkContainerColor,
      cardMargin: const EdgeInsets.only(top: PragaCulturaConstants.gridTopPadding),
      cardPadding: const EdgeInsets.all(PragaCulturaConstants.mediumPadding),
      emptyStateBuilder: (message, isDark) => EmptyStateWidget(
        message: message,
        isDark: isDark,
      ),
    );
  }
}
