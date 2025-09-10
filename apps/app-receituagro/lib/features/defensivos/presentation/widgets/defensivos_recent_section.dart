import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/widgets/content_section_widget.dart';
import '../providers/home_defensivos_provider.dart';

/// Recent access section component for Defensivos home page.
/// 
/// Displays recently accessed defensivos in a list format with
/// proper styling and interaction handling.
/// 
/// Performance: Uses ContentSectionWidget for consistent behavior
/// and optimized list rendering.
class DefensivosRecentSection extends StatelessWidget {
  const DefensivosRecentSection({
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
        title: 'Últimos Acessados',
        actionIcon: Icons.history,
        onActionPressed: () {},
        isLoading: provider.isLoading,
        emptyMessage: 'Nenhum defensivo acessado recentemente',
        isEmpty: provider.recentDefensivos.isEmpty,
        showCard: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.recentDefensivos.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1.2,
            indent: 64, // Aligned with text (icon + reduced space)
            endIndent: 8,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) {
            final defensivo = provider.recentDefensivos[index];
            return ContentListItemWidget(
              title: defensivo.displayName,
              subtitle: defensivo.displayIngredient,
              category: defensivo.displayClass,
              icon: FontAwesomeIcons.leaf,
              iconColor: const Color(0xFF4CAF50),
              onTap: () => onDefensivoTap(
                defensivo.displayName,
                defensivo.displayFabricante,
                defensivo,
              ),
            );
          },
        ),
      ),
    );
  }
}