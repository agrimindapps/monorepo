// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_list_display_widget.dart';
import '../../models/praga_item_model.dart';
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';
import 'praga_list_item.dart';

class PragaListView extends StatelessWidget {
  final List<PragaItemModel> pragas;
  final String pragaType;
  final bool isDark;
  final Function(PragaItemModel) onItemTap;

  const PragaListView({
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
      isGridMode: false,
      onItemTap: onItemTap,
      itemBuilder: (item, index, isDark, onTap) => PragaListItem(
        key: ValueKey('list_${item.idReg}'),
        praga: item,
        pragaType: pragaType,
        isDark: isDark,
        onTap: onTap,
        index: index,
      ),
      wrapWithCard: false,
      calculateCrossAxisCount: PragaUtils.calculateCrossAxisCount,
      cardElevation: 0,
      borderRadius: PragaConstants.borderRadius,
      darkContainerColor: PragaConstants.darkContainerColor,
      cardMargin: const EdgeInsets.only(top: PragaConstants.listTopPadding),
      cardPadding: const EdgeInsets.all(PragaConstants.mediumPadding),
    );
  }
}
