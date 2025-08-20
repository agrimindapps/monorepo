// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controllers/maquinario_controller.dart';
import 'widgets/consumo_widget.dart';
import 'widgets/patinamento_n_widget.dart';
import 'widgets/patinamento_widget.dart';
import 'widgets/velocidade_widget.dart';

class MaquinarioPage extends StatefulWidget {
  const MaquinarioPage({super.key});

  @override
  MaquinarioPageState createState() => MaquinarioPageState();
}

class MaquinarioPageState extends State<MaquinarioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    _TabItem(
      title: 'Consumo Lt/H',
      widget: const ConsumoWidget(),
    ),
    _TabItem(
      title: 'Patinamento',
      widget: const PatinamentoWidget(),
    ),
    _TabItem(
      title: 'Patinamento N',
      widget: const PatinamentoNWidget(),
    ),
    _TabItem(
      title: 'Velocidade',
      widget: const VelocidadeWidget(),
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

  @override
  Widget build(BuildContext context) {
    Get.put(MaquinarioController());
    return SafeArea(
        child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(72),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: PageHeaderWidget(
                title: 'Maquinário',
                subtitle: 'Cálculos de maquinário agrícola',
                icon: Icons.agriculture,
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
                    padding: const EdgeInsets.all(1.0),
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
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabs
                            .map((tab) => Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                  child: tab.widget,
                                ))
                            .toList(),
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
}

class _TabItem {
  final String title;
  final Widget widget;

  _TabItem({
    required this.title,
    required this.widget,
  });
}
