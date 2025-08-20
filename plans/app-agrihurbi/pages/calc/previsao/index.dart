// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/previsao_simples_controller.dart';
import 'pages/previsao_simples_page.dart';
import 'pages/rentabilidade_agricola_page.dart';

class PrevisaoPage extends StatefulWidget {
  const PrevisaoPage({super.key});

  @override
  PrevisaoPageState createState() => PrevisaoPageState();
}

class PrevisaoPageState extends State<PrevisaoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(PrevisaoSimplesController());
    return SafeArea(
        child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(72),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: PageHeaderWidget(
                title: 'Previsão',
                subtitle: 'Previsão de custos agrícolas',
                icon: Icons.calculate,
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
                      tabs: const [
                        Tab(text: 'Previsão Básica'),
                        Tab(text: 'Análise de Rentabilidade'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          PrevisaoSimplesPage(),
                          RentabilidadeAgricolaPage(),
                        ],
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
