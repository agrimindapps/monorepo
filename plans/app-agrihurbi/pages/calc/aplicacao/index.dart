// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'constants.dart';
import 'controllers/aplicacao_controller.dart';
import 'widgets/aplicacao_form_widget.dart';
import 'widgets/aplicacao_result_card.dart';

class AplicacaoPage extends StatefulWidget {
  const AplicacaoPage({super.key});

  @override
  AplicacaoPageState createState() => AplicacaoPageState();
}

class AplicacaoPageState extends State<AplicacaoPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    const _TabItem(
      title: AplicacaoStrings.volumeAplicacaoTitle,
      widget: AplicacaoFormWidget(
        tipo: 'Volume',
        labelVolume: AplicacaoStrings.labelVolumeCalda,
        volumeIcon: AplicacaoIcons.waterDropOutlined,
        volumeColor: AplicacaoColors.blue,
      ),
      resultCard: AplicacaoResultCard(
        tipo: 'Volume',
        cardColor: AplicacaoColors.blue,
        resultIcon: AplicacaoIcons.waterDrop,
      ),
    ),
    const _TabItem(
      title: AplicacaoStrings.vazaoBicoTitle,
      widget: AplicacaoFormWidget(
        tipo: 'Vazão',
        labelVolume: AplicacaoStrings.labelVazaoBico,
        volumeIcon: AplicacaoIcons.water,
        volumeColor: AplicacaoColors.green,
      ),
      resultCard: AplicacaoResultCard(
        tipo: 'Vazão',
        cardColor: AplicacaoColors.green,
        resultIcon: AplicacaoIcons.water,
      ),
    ),
    const _TabItem(
      title: AplicacaoStrings.quantidadeTitle,
      widget: AplicacaoFormWidget(
        tipo: 'Quantidade',
        labelVolume: AplicacaoStrings.labelCapacidadeTanque,
        volumeIcon: AplicacaoIcons.waterDrop,
        volumeColor: AplicacaoColors.purple,
      ),
      resultCard: AplicacaoResultCard(
        tipo: 'Quantidade',
        cardColor: AplicacaoColors.purple,
        resultIcon: AplicacaoIcons.waterDrop,
      ),
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

  Widget _buildTabContent(Widget form, Widget result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          form,
          const SizedBox(height: 10),
          result,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AplicacaoController());
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Aplicação',
              subtitle: 'Cálculos de aplicação de insumos',
              icon: Icons.water_drop_outlined,
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: TabBarView(
                      controller: _tabController,
                      children: _tabs
                          .map((tab) =>
                              _buildTabContent(tab.widget, tab.resultCard))
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
  final Widget resultCard;

  const _TabItem({
    required this.title,
    required this.widget,
    required this.resultCard,
  });
}
