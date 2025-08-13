// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/defensivo_item_model.dart';
import '../../utils/defensivos_category.dart';
import 'defensivo_list_item.dart';

class DefensivosListView extends StatelessWidget {
  final List<DefensivoItemModel> defensivos;
  final bool isDark;
  final DefensivosCategory categoria;
  final Function(DefensivoItemModel) onItemTap;
  final ScrollController? scrollController;
  final bool isLoading;

  const DefensivosListView({
    super.key,
    required this.defensivos,
    required this.isDark,
    required this.categoria,
    required this.onItemTap,
    this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        indent: 65,
      ),
      scrollDirection: Axis.vertical,
      shrinkWrap: false,
      physics: scrollController != null ? null : const NeverScrollableScrollPhysics(),
      itemCount: defensivos.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == defensivos.length && isLoading) {
          return _buildLoadingIndicator();
        }
        return DefensivoListItem(
          item: defensivos[index],
          isDark: isDark,
          categoria: categoria,
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
          const SizedBox(height: 8.0),
          Text(
            'Carregando mais itens...',
            style: TextStyle(
              fontSize: 14.0,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
