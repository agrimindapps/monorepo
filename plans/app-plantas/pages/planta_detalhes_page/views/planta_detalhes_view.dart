// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/planta_detalhes_controller.dart';
import '../widgets/comentarios_tab.dart';
import '../widgets/cuidados_tab.dart';
import '../widgets/planta_detalhes_app_bar.dart';
import '../widgets/planta_detalhes_tab_bar.dart';
import '../widgets/tarefas_tab.dart';
import '../widgets/visao_geral_tab.dart';

class PlantaDetalhesView extends GetView<PlantaDetalhesController> {
  const PlantaDetalhesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: PlantasColors.backgroundColor,
            body: controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: PlantasColors.primaryColor,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      PlantaDetalhesAppBar(controller: controller),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const PlantaDetalhesTabBar(),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: TabBarView(
                                children: [
                                  VisaoGeralTab(controller: controller),
                                  TarefasTab(controller: controller),
                                  CuidadosTab(controller: controller),
                                  ComentariosTab(controller: controller),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
