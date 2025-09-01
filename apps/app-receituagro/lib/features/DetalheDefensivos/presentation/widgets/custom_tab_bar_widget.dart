import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget personalizado para TabBar com animações
/// Responsabilidade única: exibir tabs responsivas com ícones e texto
class CustomTabBarWidget extends StatelessWidget {
  final TabController tabController;

  const CustomTabBarWidget({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade200],
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
      child: TabBar(
        controller: tabController,
        tabs: _buildTabsWithIcons(),
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
      ),
    );
  }

  List<Widget> _buildTabsWithIcons() {
    final tabData = [
      {'icon': FontAwesomeIcons.info, 'text': 'Informações'},
      {'icon': FontAwesomeIcons.magnifyingGlass, 'text': 'Diagnóstico'},
      {'icon': FontAwesomeIcons.gear, 'text': 'Tecnologia'},
      {'icon': FontAwesomeIcons.comment, 'text': 'Comentários'},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return Tab(
        child: AnimatedBuilder(
          animation: tabController,
          builder: (context, _) {
            final isActive = tabController.index == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? null : 40,
              child: Row(
                mainAxisSize: isActive ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(data['icon'] as IconData, size: isActive ? 18 : 16),
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
            );
          },
        ),
      );
    }).toList();
  }
}