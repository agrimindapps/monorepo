import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/widgets/content_section_widget.dart';
import '../providers/home_defensivos_provider.dart';

/// New items section component for Defensivos home page.
/// 
/// Displays newly available defensivos in a list format with
/// proper styling and interaction handling.
/// 
/// Performance: Uses ContentSectionWidget for consistent behavior
/// and optimized list rendering.
class DefensivosNewItemsSection extends StatelessWidget {
  const DefensivosNewItemsSection({
    super.key,
    required this.provider,
    required this.onDefensivoTap,
  });

  final HomeDefensivosProvider provider;
  final void Function(String name, String fabricante, FitossanitarioHive defensivo) onDefensivoTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ContentSectionWidget(
        title: 'Novos Defensivos',
        actionIcon: Icons.settings,
        onActionPressed: () {},
        isLoading: provider.isLoading,
        emptyMessage: 'Nenhum novo defensivo disponível',
        isEmpty: provider.newDefensivos.isEmpty,
        showCard: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.newDefensivos.length,
          itemBuilder: (context, index) {
            final defensivo = provider.newDefensivos[index];
            return ContentListItemWidget(
              title: defensivo.displayName,
              subtitle: defensivo.displayIngredient,
              category: defensivo.displayClass,
              icon: FontAwesomeIcons.seedling,
              iconColor: const Color(0xFF4CAF50),
              onTap: () => onDefensivoTap(
                defensivo.displayName,
                defensivo.displayFabricante,
                defensivo,
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}