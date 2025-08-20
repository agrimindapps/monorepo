// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/fertilizantes_controller.dart';
import 'widgets/fertilizante_input_card.dart';
import 'widgets/fertilizante_result_card.dart';

class FertilizantesPage extends StatelessWidget {
  const FertilizantesPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FertilizantesController());
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(72),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: PageHeaderWidget(
                title: 'Fertilizantes',
                subtitle: 'Cálculos de fertilização',
                icon: Icons.science_outlined,
                showBackButton: true,
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: FertilizanteInputCard(),
                      ),
                      const SizedBox(height: 10),
                      FertilizanteResultCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
