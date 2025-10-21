// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'controllers/custo_efetivo_total_controller.dart';
import 'widgets/custo_efetivo_total_form.dart';
import 'widgets/custo_efetivo_total_result.dart';
import 'widgets/info_dialog.dart';

class CustoEfetivoTotalPage extends StatefulWidget {
  const CustoEfetivoTotalPage({super.key});

  @override
  State<CustoEfetivoTotalPage> createState() => _CustoEfetivoTotalPageState();
}

class _CustoEfetivoTotalPageState extends State<CustoEfetivoTotalPage> {
  late final CustoEfetivoTotalController controller;

  @override
  void initState() {
    super.initState();
    controller = CustoEfetivoTotalController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.calculate_outlined,
              size: 20,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(width: 10),
            const Text('Custo Efetivo Total'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => InfoDialog.show(context),
            tooltip: 'Informações sobre o CET',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return Column(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 24, 16, 16),
                          child: CustoEfetivoTotalForm(controller: controller),
                        ),
                      ),
                      if (controller.resultadoVisivel) ...[
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: controller.resultadoVisivel ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child:
                              CustoEfetivoTotalResult(controller: controller),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
