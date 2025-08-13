// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../utils/praga_cultura_constants.dart';

class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabTap;
  final bool isDark;

  const TabBarWidget({
    super.key,
    required this.tabController,
    required this.onTabTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PragaCulturaConstants.tabBarHeight,
      margin: const EdgeInsets.only(
        top: PragaCulturaConstants.smallSpacing * 2,
        bottom: PragaCulturaConstants.smallSpacing,
      ),
      decoration: _buildTabBarDecoration(),
      child: TabBar(
        controller: tabController,
        tabs: _buildTabBarTabs(),
        indicator: _buildTabBarIndicator(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.green.shade800,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: onTabTap,
      ),
    );
  }

  BoxDecoration _buildTabBarDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.green.shade100,
          Colors.green.shade200,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(PragaCulturaConstants.borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.green.shade200.withValues(alpha: PragaCulturaConstants.borderOpacity),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  List<Widget> _buildTabBarTabs() {
    return [
      _buildTab('Plantas', FontAwesome.seedling_solid),
      _buildTab('Doenças', FontAwesome.virus_solid),
      _buildTab('Insetos', FontAwesome.bug_solid),
    ];
  }

  BoxDecoration _buildTabBarIndicator() {
    return BoxDecoration(
      color: Colors.green.shade700,
      borderRadius: BorderRadius.circular(PragaCulturaConstants.smallPadding),
    );
  }

  Widget _buildTab(String title, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: PragaCulturaConstants.tabIconSize),
          const SizedBox(width: PragaCulturaConstants.tabSpacing),
          Text(title),
        ],
      ),
    );
  }
}
