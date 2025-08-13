// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/layout_constants.dart';
import '../models/defensivo_item.dart';
import 'defensivo_list_item.dart';

class DefensivosListCard extends StatelessWidget {
  final List<DefensivoItem> items;
  final Function(String) onItemTap;
  final String? heroTagPrefix;

  const DefensivosListCard({
    super.key,
    required this.items,
    required this.onItemTap,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ElevationConstants.cardElevation,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(LayoutConstants.defaultBorderRadius)),
      child: items.isEmpty ? _buildEmptyState() : _buildListView(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(LayoutConstants.cardPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesome.box_open_solid,
                size: LayoutConstants.backgroundIconSize / 2,
                color: Colors.grey[ColorConstants.greyShade400]),
            const SizedBox(height: LayoutConstants.defaultSpacing),
            Text(
              'Nenhum registro encontrado',
              style: TextStyle(color: Colors.grey[ColorConstants.greyShade600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: LayoutConstants.defaultSpacing),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(
            height: LayoutConstants.listSeparatorHeight,
            indent: LayoutConstants.listSeparatorIndent),
        itemBuilder: (_, index) => DefensivoListItem(
          item: items[index],
          onTap: onItemTap,
          heroTagPrefix: heroTagPrefix,
        ),
      ),
    );
  }
}
