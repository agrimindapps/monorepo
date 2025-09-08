import 'package:flutter/material.dart';

class PragaCulturaTabBarWidget extends StatefulWidget {
  final TabController tabController;
  final void Function(int) onTabTap;
  final bool isDark;

  const PragaCulturaTabBarWidget({
    super.key,
    required this.tabController,
    required this.onTabTap,
    required this.isDark,
  });

  @override
  State<PragaCulturaTabBarWidget> createState() => _PragaCulturaTabBarWidgetState();
}

class _PragaCulturaTabBarWidgetState extends State<PragaCulturaTabBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildTabBar(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: widget.tabController,
        onTap: widget.onTabTap,
        tabs: _buildFavoritesStyleTabs(),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 0, // Hide text in inactive tabs
          fontWeight: FontWeight.w400,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        dividerColor: Colors.transparent,
      ),
    );
  }

  List<Widget> _buildFavoritesStyleTabs() {
    final tabData = [
      {'icon': Icons.grass_outlined, 'text': 'Plantas Daninhas'},
      {'icon': Icons.coronavirus_outlined, 'text': 'Doenças'},
      {'icon': Icons.bug_report_outlined, 'text': 'Insetos'},
    ];

    return tabData.map((data) => Tab(
      child: AnimatedBuilder(
        animation: widget.tabController,
        builder: (context, child) {
          final isActive = widget.tabController.index == tabData.indexOf(data);

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data['icon'] as IconData,
                size: 16,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Text(
                  data['text'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    )).toList();
  }
}