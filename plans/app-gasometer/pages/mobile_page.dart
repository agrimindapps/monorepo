// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/bottombar_widget.dart';
import 'cadastros/abastecimento_page/bindings/abastecimento_page_bindings.dart';
import 'cadastros/abastecimento_page/index.dart';
import 'cadastros/odometro_page/bindings/odometro_page_bindings.dart';
import 'cadastros/odometro_page/index.dart';
import 'cadastros/veiculos_page/index.dart';
import 'resultados/estatisticas_veiculos_page.dart';
import 'settings/index.dart';

class MobilePageMain extends StatefulWidget {
  const MobilePageMain({super.key});

  @override
  State<MobilePageMain> createState() => _MobilePageMainState();
}

class _MobilePageMainState extends State<MobilePageMain> {
  final PageController _pageControllerMobile = PageController();

  @override
  void initState() {
    super.initState();
    _initializeBindings();
  }

  void _initializeBindings() {
    // Inicializa os bindings das páginas principais
    // VeiculosPageBinding é gerenciado pelo router GetX
    OdometroPageBindings().dependencies();
    AbastecimentoPageBindings().dependencies();
  }

  Widget _buildPageMobile(int index) {
    switch (index) {
      case 0:
        return const VeiculosPage();
      case 1:
        return const OdometroPage();
      case 2:
        return const AbastecimentoPage();
      case 3:
        return const EstatisticasVeiculosPage();
      case 4:
        return const SettingsPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.custom(
              controller: _pageControllerMobile,
              onPageChanged: _pageControllerMobile.jumpToPage,
              physics: const NeverScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                return KeyedSubtree(
                  key: ValueKey(index),
                  child: _buildPageMobile(index),
                );
              }, childCount: 5),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarWidget(controller: _pageControllerMobile),
    );
  }
}
