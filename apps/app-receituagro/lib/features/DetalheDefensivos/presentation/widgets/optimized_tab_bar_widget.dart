import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tab_controller_notifier.dart';

/// Widget otimizado para TabBar sem AnimatedBuilder desnecessário
/// Foca em performance usando apenas mudanças de estado necessárias
/// Migrated to Riverpod - uses ConsumerWidget
class OptimizedTabBarWidget extends ConsumerWidget {
  const OptimizedTabBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabControllerNotifierProvider);
    final notifier = ref.read(tabControllerNotifierProvider.notifier);

    return state.when(
      data: (data) => Container(
        height: 44,
        margin: const EdgeInsets.only(
          top: 8,
          bottom: 4,
          left: 8,
          right: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100,
              Colors.green.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200.withValues(alpha: 0.5),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: notifier.tabController != null
            ? TabBar(
                controller: notifier.tabController,
                tabs: _buildTabs(data.selectedTabIndex),
                indicator: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.green.shade800,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              )
            : const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Constrói tabs otimizadas sem AnimatedBuilder
  List<Widget> _buildTabs(int selectedIndex) {
    final tabData = [
      {'icon': Icons.info_outlined, 'text': 'Informações'},
      {'icon': Icons.search_outlined, 'text': 'Diagnóstico'},
      {'icon': Icons.settings_outlined, 'text': 'Tecnologia'},
      {'icon': Icons.comment_outlined, 'text': 'Comentários'},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isActive = selectedIndex == index;

      return Tab(
        child: SizedBox(
          width: isActive ? null : 40,
          child: Row(
            mainAxisSize: isActive ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data['icon'] as IconData,
                size: isActive ? 18 : 16,
                color: isActive ? Colors.white : Colors.green.shade800,
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    data['text'] as String,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}
