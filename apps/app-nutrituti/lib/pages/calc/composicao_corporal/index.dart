// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import 'views/gasto_energetico_view.dart';

class ComposicaoCorporalPage extends StatefulWidget {
  const ComposicaoCorporalPage({super.key});

  @override
  ComposicaoCorporalPageState createState() => ComposicaoCorporalPageState();
}

class ComposicaoCorporalPageState extends State<ComposicaoCorporalPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    _TabItem(
      title: 'Gasto Energético Total',
      widgetBuilder: () => const GastoEnergeticoView(),
      icon: Icons.local_fire_department,
      description: 'Cálculo do gasto calórico diário baseado nas atividades',
    ),
    // Adicione aqui as outras tabs conforme necessário
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sobre Composição Corporal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ShadcnStyle.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'O que é Composição Corporal:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A composição corporal refere-se às proporções relativas de gordura, músculo, água e outros tecidos que compõem o corpo humano. Entender a composição corporal é fundamental para avaliar a saúde e planejar estratégias nutricionais e de exercícios.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ShadcnStyle.primaryButtonStyle,
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabDescription(int index) {
    final isDark = ThemeManager().isDark.value;
    final tab = _tabs[index];

    return Card(
      elevation: 0,
      color: isDark ? Colors.black.withAlpha(51) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              tab.icon,
              color: isDark ? Colors.orange.shade300 : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tab.description ?? '',
                style: TextStyle(
                  color: ShadcnStyle.textColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: 20,
              color: isDark ? Colors.orange.shade300 : Colors.orange,
            ),
            const SizedBox(width: 10),
            const Text('Composição Corporal'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: ShadcnStyle.textColor,
            ),
            onPressed: _showInfoDialog,
            tooltip: 'Informações sobre composição corporal',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs
              .map((tab) => Tab(
                    text: tab.title,
                    icon: Icon(tab.icon, size: 20),
                  ))
              .toList(),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          labelColor: isDark ? Colors.orange.shade300 : Colors.orange,
          unselectedLabelColor: ShadcnStyle.textColor,
          indicatorColor: isDark ? Colors.orange.shade300 : Colors.orange,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTabDescription(_currentIndex),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _tabs[_currentIndex].widgetBuilder(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final Widget Function() widgetBuilder;
  final IconData icon;
  final String? description;

  const _TabItem({
    required this.title,
    required this.widgetBuilder,
    required this.icon,
    this.description,
  });
}
