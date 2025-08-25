import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PragaCulturaTabBarWidget extends StatefulWidget {
  final TabController tabController;
  final Function(int) onTabTap;
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDark ? const Color(0xFF222228) : Colors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark 
                ? Colors.grey.shade800 
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: TabBar(
          controller: widget.tabController,
          onTap: widget.onTabTap,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: widget.isDark 
              ? Colors.grey.shade400 
              : Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            _buildTab(
              icon: FontAwesomeIcons.seedling,
              label: 'Plantas',
              index: 0,
            ),
            _buildTab(
              icon: FontAwesomeIcons.virus,
              label: 'Doenças',
              index: 1,
            ),
            _buildTab(
              icon: FontAwesomeIcons.bug,
              label: 'Insetos',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.tabController.index == index;
    
    return Tab(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isSelected 
                  ? const Color(0xFF2E7D32)
                  : (widget.isDark 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? const Color(0xFF2E7D32)
                    : (widget.isDark 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}