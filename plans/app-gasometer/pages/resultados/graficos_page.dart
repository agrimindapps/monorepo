// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../widgets/appbar_widget.dart';
import 'graficos_abastecimentos_widgets.dart';
import 'graficos_geral_widget.dart';
import 'graficos_manutencoes_widget.dart';
import 'graficos_odometro_widget.dart';

class GraficosCarPage extends StatefulWidget {
  const GraficosCarPage({super.key});

  @override
  State<GraficosCarPage> createState() => _GraficosCarPageState();
}

class _GraficosCarPageState extends State<GraficosCarPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int _selectedIndex = 0;

  final List<Widget> _graficos = const [
    GraficoGeral(),
    GraficoAbastecimento(),
    GraficoManutencao(),
    GraficoOdometro(),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      setState(() {
        _selectedIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomLocalAppBar(
        title: 'Gráficos',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 1020,
              child: Column(
                children: [
                  _tabbar(),
                  const SizedBox(height: 16),
                  _graficos[_selectedIndex],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabbar() {
    int width = MediaQuery.of(context).size.width < 1020
        ? MediaQuery.of(context).size.width.toInt()
        : 1020;

    return Container(
      height: kToolbarHeight - 8.0,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorPadding: const EdgeInsets.all(0),
        tabs: [
          SizedBox(
            width: width / 4,
            child: const Tab(text: 'Geral'),
          ),
          SizedBox(
            width: width / 4,
            child: const Tab(text: 'Abastecimento'),
          ),
          SizedBox(
            width: width / 4,
            child: const Tab(text: 'Manutenções'),
          ),
          SizedBox(
            width: width / 4,
            child: const Tab(text: 'Odometro'),
          ),
        ],
        controller: tabController,
      ),
    );
  }
}
