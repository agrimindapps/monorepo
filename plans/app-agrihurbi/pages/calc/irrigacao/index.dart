// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'pages/capacidade_campo_page.dart';
import 'pages/dimensionamento_page.dart';
import 'pages/evapotranspiracao_page.dart';
import 'pages/necessidade_hidrica_page.dart';
import 'widgets/tempo_irrigacao/tempo_irrigacao_page.dart';

class _TabItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget widget;

  _TabItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.widget,
  });
}

class NewIrrigacaoPage extends StatefulWidget {
  const NewIrrigacaoPage({super.key});

  @override
  NewIrrigacaoPageState createState() => NewIrrigacaoPageState();
}

class NewIrrigacaoPageState extends State<NewIrrigacaoPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    _TabItem(
      title: 'Necessidade Hídrica',
      description: 'Calcule a necessidade de água para suas culturas',
      icon: FontAwesome.droplet_solid,
      color: Colors.blue.shade700,
      widget: const NecessidadeHidricaPage(),
    ),
    _TabItem(
      title: 'Dimensionamento',
      description: 'Dimensione seu sistema de irrigação',
      icon: FontAwesome.ruler_solid,
      color: Colors.green.shade700,
      widget: const DimensionamentoPage(),
    ),
    _TabItem(
      title: 'Tempo de Irrigação',
      description: 'Determine o tempo ideal para irrigação',
      icon: FontAwesome.clock_solid,
      color: Colors.orange.shade700,
      widget: const TempoIrrigacaoPage(),
    ),
    _TabItem(
      title: 'Evapotranspiração',
      description: 'Calcule a evapotranspiração da cultura',
      icon: FontAwesome.cloud_sun_solid,
      color: Colors.purple.shade700,
      widget: const EvapotranspiracaoPage(),
    ),
    _TabItem(
      title: 'Capacidade de Campo',
      description: 'Determine a capacidade de água no solo',
      icon: FontAwesome.layer_group_solid,
                    color: Colors.black.withValues(alpha: 0.1),
      widget: const CapacidadeCampoPage(),
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
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cálculos de Irrigação',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Esta seção oferece ferramentas para:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  context,
                  'Calcular a necessidade hídrica das culturas',
                ),
                _buildBulletPoint(
                  context,
                  'Dimensionar sistemas de irrigação',
                ),
                _buildBulletPoint(
                  context,
                  'Determinar o tempo ideal de irrigação',
                ),
                _buildBulletPoint(
                  context,
                  'Calcular a evapotranspiração',
                ),
                _buildBulletPoint(
                  context,
                  'Avaliar a capacidade de campo do solo',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Utilize os valores mais precisos possíveis para obter resultados mais confiáveis.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = ThemeManager().isDark.value;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TabBar(
        controller: _tabController,
        tabs: _tabs.map((tab) => Tab(text: tab.title)).toList(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? Colors.grey.shade700 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: ShadcnStyle.primaryColor,
        unselectedLabelColor: ShadcnStyle.mutedTextColor,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
      ),
    );
  }

  Widget _buildTabContent(_TabItem tab) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tab.widget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Irrigação',
              subtitle: 'Cálculos de irrigação',
              icon: Icons.water_drop,
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: _showInfoDialog,
                  tooltip: 'Informações',
                ),
              ],
            ),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildTabBar(),
                _buildTabBarView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
