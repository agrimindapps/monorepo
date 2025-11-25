import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/extensions/fitossanitario_drift_extension.dart';
import '../../../../core/widgets/content_section_widget.dart';
import '../../../../database/receituagro_database.dart';
import '../providers/home_defensivos_notifier.dart';

/// New items section component for Defensivos home page.
///
/// Displays newly available defensivos in a list format with
/// proper styling and interaction handling.
///
/// Performance: Uses ContentSectionWidget for consistent behavior
/// and optimized list rendering.
/// Migrated to Riverpod - uses ConsumerWidget.
class DefensivosNewItemsSection extends ConsumerWidget {
  const DefensivosNewItemsSection({super.key, required this.onDefensivoTap});

  final void Function(String name, String fabricante, Fitossanitario defensivo)
  onDefensivoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDefensivosProvider);

    return state.when(
      data: (data) => RepaintBoundary(
        child: ContentSectionWidget(
          title: 'Novos Defensivos',
          actionIcon: Icons.settings,
          onActionPressed: () {},
          isLoading: data.isLoading,
          emptyMessage: 'Nenhum novo defensivo disponível',
          isEmpty: data.newDefensivos.isEmpty,
          showCard: true,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.newDefensivos.length,
            itemBuilder: (context, index) {
              final defensivo = data.newDefensivos[index];
              return ContentListItemWidget(
                title: defensivo.displayName,
                subtitle: defensivo.displayIngredient,
                category: defensivo.displayIngredient,
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
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
