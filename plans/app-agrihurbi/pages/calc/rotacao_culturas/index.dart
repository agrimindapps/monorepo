// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'views/balanco_nitrogenio_page.dart';
import 'views/planejamento_rotacao_page.dart';

class RotacaoCulturasPage extends StatefulWidget {
  const RotacaoCulturasPage({super.key});

  @override
  RotacaoCulturasPageState createState() => RotacaoCulturasPageState();
}

class RotacaoCulturasPageState extends State<RotacaoCulturasPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    const _TabItem(
      title: 'Planejamento de Rotação',
      icon: Icons.calendar_view_month_outlined,
      widget: PlanejamentoRotacaoPage(),
    ),
    const _TabItem(
      title: 'Balanço de Nitrogênio',
      icon: Icons.science_outlined,
      widget: BalancoNitrogenioPage(),
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
    final currentTab = _tabs[currentIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                currentTab.icon,
                color: Colors.green.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentTab.title,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentIndex == 0) ...[
                  // Planejamento de Rotação info
                  const Text(
                    'Esta ferramenta ajuda você a planejar a distribuição das culturas na sua área, mantendo uma proporção adequada entre elas para uma rotação eficiente.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use os controles deslizantes para ajustar a porcentagem de área destinada a cada cultura. A soma deve totalizar 100%.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Uma boa rotação de culturas ajuda a manter a saúde do solo, reduz problemas com pragas e doenças, e diversifica sua produção.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Balanço de Nitrogênio info
                  const Text(
                    'Este cálculo ajuda a determinar a quantidade de nitrogênio necessária para a cultura, considerando a área de plantio, a produtividade esperada e o teor de nitrogênio já disponível no solo.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A ferramenta considera também o nitrogênio que pode ser obtido por fixação biológica, especialmente importante para leguminosas como a soja.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'O nitrogênio é essencial para o crescimento vegetativo e para a formação de proteínas nas plantas. Uma adubação adequada melhora significativamente a produtividade.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              title: 'Rotação de Culturas',
              subtitle: 'Planejamento e balanço nutricional',
              icon: Icons.autorenew,
              showBackButton: true,
              actions: [
                IconButton(
                  onPressed: _showInfoDialog,
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Informações',
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
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) => tab.widget).toList(),
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
  final IconData icon;
  final Widget widget;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.widget,
  });
}
