// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'constants.dart';
import 'widgets/adubacao_organica_page.dart';
import 'widgets/correcao_acidez_page.dart';
import 'widgets/micronutrientes_page.dart';

class BalancoNutricionalPage extends StatefulWidget {
  const BalancoNutricionalPage({super.key});

  @override
  BalancoNutricionalPageState createState() => BalancoNutricionalPageState();
}

class BalancoNutricionalPageState extends State<BalancoNutricionalPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    const _TabItem(
      title: BalancoNutricionalStrings.tabTitleCalcario,
      widget: CorrecaoAcidezPage(),
      icon: BalancoNutricionalIcons.bubbleChartOutlined,
    ),
    const _TabItem(
      title: BalancoNutricionalStrings.tabTitleAdubacaoOrganica,
      widget: AdubacaoOrganicaPage(),
      icon: BalancoNutricionalIcons.compostOutlined,
    ),
    _TabItem(
      title: BalancoNutricionalStrings.tabTitleMicronutrientes,
      widget: MicronutrientesPage.create(),
      icon: BalancoNutricionalIcons.scienceOutlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(_TabItem tab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: tab.widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Balanço Nutricional',
              subtitle: 'Análise de nutrientes do solo',
              icon: Icons.science,
              showBackButton: true,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade100,
                        Colors.green.shade200,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.green.shade800,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: _tabs.map((tab) => Tab(text: tab.title)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        _tabs.map((tab) => _buildTabContent(tab)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final Widget widget;
  final IconData icon;

  const _TabItem({
    required this.title,
    required this.widget,
    this.icon = Icons.calculate,
  });
}
