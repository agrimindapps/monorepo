// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/defensivo_item.dart';
import 'defensivos_list_card.dart';
import 'section_title.dart';

class RecentSection extends StatelessWidget {
  final List<DefensivoItem> items;
  final Function(String) onItemTap;

  const RecentSection({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Últimos Acessados',
          icon: Icons.history,
        ),
        DefensivosListCard(
          items: items,
          onItemTap: onItemTap,
          heroTagPrefix: 'recent-defensivo',
        ),
      ],
    );
  }
}
