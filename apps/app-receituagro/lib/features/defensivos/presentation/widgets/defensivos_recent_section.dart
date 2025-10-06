import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/widgets/content_section_widget.dart';
import '../providers/home_defensivos_notifier.dart';

/// Recent access section component for Defensivos home page.
///
/// Displays recently accessed defensivos in a list format with
/// proper styling and interaction handling.
///
/// Performance: Uses ContentSectionWidget for consistent behavior
/// and optimized list rendering.
/// Migrated to Riverpod - uses ConsumerWidget.
class DefensivosRecentSection extends ConsumerWidget {
  const DefensivosRecentSection({super.key, required this.onDefensivoTap});

  final void Function(
    String name,
    String fabricante,
    FitossanitarioHive defensivo,
  )
  onDefensivoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDefensivosNotifierProvider);

    return state.when(
      data:
          (data) => RepaintBoundary(
            child: ContentSectionWidget(
              title: 'Últimos Acessados',
              actionIcon: Icons.history,
              onActionPressed: () {},
              isLoading: data.isLoading,
              emptyMessage: 'Nenhum defensivo acessado recentemente',
              isEmpty: data.recentDefensivos.isEmpty,
              showCard: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.recentDefensivos.length,
                itemBuilder: (context, index) {
                  final defensivo = data.recentDefensivos[index];
                  return ContentListItemWidget(
                    title: defensivo.displayName,
                    subtitle: defensivo.displayIngredient,
                    category: defensivo.displayClass,
                    icon: FontAwesomeIcons.leaf,
                    iconColor: const Color(0xFF4CAF50),
                    onTap:
                        () => onDefensivoTap(
                          defensivo.displayName,
                          defensivo.displayFabricante,
                          defensivo,
                        ),
                  );
                },
                separatorBuilder:
                    (context, index) => Divider(
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
