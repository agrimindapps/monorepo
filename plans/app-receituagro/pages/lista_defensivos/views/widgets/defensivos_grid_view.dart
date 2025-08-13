// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/defensivo_model.dart';
import '../../utils/defensivos_constants.dart';
import '../../utils/defensivos_helpers.dart';
import 'defensivo_grid_item.dart';

class DefensivosGridView extends StatelessWidget {
  final List<DefensivoModel> defensivos;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isDark;
  final Function(DefensivoModel) onItemTap;

  const DefensivosGridView({
    super.key,
    required this.defensivos,
    required this.scrollController,
    required this.isLoading,
    required this.isDark,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('defensivos_grid'),
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DefensivosHelpers.calculateCrossAxisCount(
            MediaQuery.of(context).size.width),
        childAspectRatio: DefensivosConstants.gridChildAspectRatio,
        crossAxisSpacing: DefensivosConstants.gridCrossAxisSpacing,
        mainAxisSpacing: DefensivosConstants.gridMainAxisSpacing,
      ),
      shrinkWrap: true,
      itemCount: defensivos.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == defensivos.length) {
          return _buildLoadingIndicator();
        }
        final defensivo = defensivos[index];
        return DefensivoGridItem(
          defensivo: defensivo,
          isDark: isDark,
          onTap: () => onItemTap(defensivo),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.green.shade300 : Colors.green.shade700),
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
