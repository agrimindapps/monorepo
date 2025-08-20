// Flutter imports:
import 'package:flutter/material.dart';

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
  late MaquinarioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MaquinarioController(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTabContent(Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [content],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: PageHeaderWidget(
                  title: 'Maquinário',
                  subtitle: 'Cálculos de maquinário agrícola',
                  icon: Icons.agriculture,
                  showBackButton: true,
                ),
              ),
              PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 4.0),
                  padding: const EdgeInsets.all(4.0),
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
                    controller: _controller.tabController,
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
                    tabs: _controller.calculos
                        .map((calc) => Tab(text: calc.title))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: TabBarView(
                controller: _controller.tabController,
                children: [
                  _buildTabContent(
                      ConsumoWidget(controller: _controller, index: 0)),
                  _buildTabContent(
                      PatinamentoWidget(controller: _controller, index: 1)),
                  _buildTabContent(
                      PatinamentoNWidget(controller: _controller, index: 2)),
                  _buildTabContent(
                      VelocidadeWidget(controller: _controller, index: 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
