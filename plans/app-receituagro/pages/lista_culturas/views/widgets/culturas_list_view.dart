// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/cultura_model.dart';
import 'cultura_list_item.dart';

class CulturasListView extends StatelessWidget {
  final List<CulturaModel> culturas;
  final bool isDark;
  final Function(CulturaModel) onCulturaTap;

  const CulturasListView({
    super.key,
    required this.culturas,
    required this.isDark,
    required this.onCulturaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: ListView.separated(
        itemCount: culturas.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 65,
          endIndent: 10,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final cultura = culturas[index];
          return CulturaListItem(
            cultura: cultura,
            isDark: isDark,
            onTap: () => onCulturaTap(cultura),
            index: index,
          );
        },
      ),
    );
  }
}
