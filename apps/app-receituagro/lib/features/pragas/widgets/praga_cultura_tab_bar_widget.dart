import 'package:flutter/material.dart';

import '../../../core/widgets/standard_tab_bar_widget.dart';

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
      child: StandardTabBarWidget(
        tabController: widget.tabController,
        tabs: StandardTabData.pragaCultureTabs,
        onTabTap: () => widget.onTabTap(widget.tabController.index),
      ),
    );
  }
}
