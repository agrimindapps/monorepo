// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/defensivo_model.dart';
import '../../utils/defensivos_constants.dart';
import 'defensivo_list_item.dart';

class DefensivosListView extends StatelessWidget {
  final List<DefensivoModel> defensivos;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isDark;
  final Function(DefensivoModel) onItemTap;

  const DefensivosListView({
    super.key,
    required this.defensivos,
    required this.scrollController,
    required this.isLoading,
    required this.isDark,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('defensivos_list'),
      controller: scrollController,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        indent: DefensivosConstants.listItemDividerIndent,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: defensivos.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == defensivos.length && isLoading) {
          return _buildLoadingIndicator();
        }
        return DefensivoListItem(
          defensivo: defensivos[index],
          isDark: isDark,
          onTap: () => onItemTap(defensivos[index]),
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.green.shade300 : Colors.green.shade700,
            ),
          ),
          const SizedBox(height: DefensivosConstants.cardPadding),
          Text(
            'Carregando mais itens...',
            style: TextStyle(
              fontSize: DefensivosConstants.titleFontSize,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
