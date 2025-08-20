// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'pages/diluicao_defensivos_page.dart';
import 'pages/nivel_dano_economico_page.dart';
import 'widgets/diluicao_defensivos/info_dialog_widget.dart' as diluicao_info;
import 'widgets/nivel_dano_economico/info_dialog_widget.dart' as nivel_info;

class ManejoIntegradoPage extends StatefulWidget {
  const ManejoIntegradoPage({super.key});

  @override
  ManejoIntegradoPageState createState() => ManejoIntegradoPageState();
}

class ManejoIntegradoPageState extends State<ManejoIntegradoPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    const _TabItem(
      title: 'Nível de Dano Econômico',
      widget: NivelDanoEconomicoPage(),
      icon: Icons.radar,
      description: 'Cálculo do limiar econômico para controle de pragas',
    ),
    const _TabItem(
      title: 'Diluição de Defensivos',
      widget: DiluicaoDefensivosPage(),
      icon: Icons.opacity,
      description: 'Calculadora para diluição correta de defensivos agrícolas',
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

  void _showInfoDialog() {
    final currentIndex = _tabController.index;
    if (currentIndex == 0) {
      // Nível de Dano Econômico
      nivel_info.InfoDialogWidget.show(context);
    } else {
      // Diluição de Defensivos
      diluicao_info.InfoDialogWidget.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Manejo Integrado',
              subtitle: 'Controle de pragas e defensivos',
              icon: Icons.bug_report,
              showBackButton: true,
              actions: [
                IconButton(
                  onPressed: _showInfoDialog,
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Informações sobre o cálculo',
                ),
              ],
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: TabBarView(
                      controller: _tabController,
                      children:
                          _tabs.map((tab) => _buildTabContent(tab)).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(_TabItem tab) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tab.description != null) _buildDescriptionCard(tab),
          const SizedBox(height: 16),
          tab.widget,
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(_TabItem tab) {
    return Card(
      elevation: 0,
      color: Colors.deepOrange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.deepOrange.shade100,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tab.description ?? '',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final Widget widget;
  final IconData icon;
  final String? description;

  const _TabItem({
    required this.title,
    required this.widget,
    this.icon = Icons.calculate,
    this.description,
  });
}
