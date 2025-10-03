import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../providers/home_defensivos_notifier.dart';

/// Header component for Defensivos home page.
///
/// Displays the title, subtitle based on state, and maintains
/// consistent styling across the application.
///
/// Performance: Lightweight component with minimal rebuilds.
/// Migrated to Riverpod - uses ConsumerWidget.
class HomeDefensivosHeader extends ConsumerWidget {
  const HomeDefensivosHeader({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDefensivosNotifierProvider);

    return state.when(
      data: (data) => ModernHeaderWidget(
        title: 'Defensivos',
        subtitle: data.headerSubtitle,
        leftIcon: Icons.shield_outlined,
        showBackButton: false,
        showActions: false,
        isDark: isDark,
      ),
      loading: () => ModernHeaderWidget(
        title: 'Defensivos',
        subtitle: 'Carregando...',
        leftIcon: Icons.shield_outlined,
        showBackButton: false,
        showActions: false,
        isDark: isDark,
      ),
      error: (_, __) => ModernHeaderWidget(
        title: 'Defensivos',
        subtitle: 'Erro ao carregar',
        leftIcon: Icons.shield_outlined,
        showBackButton: false,
        showActions: false,
        isDark: isDark,
      ),
    );
  }
}