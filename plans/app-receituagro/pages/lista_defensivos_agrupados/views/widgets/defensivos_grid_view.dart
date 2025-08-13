// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/defensivo_item_model.dart';
import '../../utils/defensivos_category.dart';
import '../../utils/defensivos_helpers.dart';
import 'defensivo_grid_item.dart';

class DefensivosGridView extends StatelessWidget {
  final List<DefensivoItemModel> defensivos;
  final bool isDark;
  final DefensivosCategory categoria;
  final Function(DefensivoItemModel) onItemTap;
  final ScrollController? scrollController;
  final bool isLoading;

  const DefensivosGridView({
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
    return GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DefensivosHelpers.calculateCrossAxisCount(
            MediaQuery.of(context).size.width),
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      shrinkWrap: false,
      physics: scrollController != null ? null : const NeverScrollableScrollPhysics(),
      itemCount: defensivos.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == defensivos.length && isLoading) {
          return _buildLoadingIndicator();
        }
        final item = defensivos[index];
        return DefensivoGridItem(
          item: item,
          isDark: isDark,
          categoria: categoria,
          onTap: () => onItemTap(item),
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isDark ? Colors.green.shade300 : Colors.green.shade700,
        ),
      ),
    );
  }
}
