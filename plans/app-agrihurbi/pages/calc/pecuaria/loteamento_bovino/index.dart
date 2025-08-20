// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../widgets/page_header_widget.dart';
import 'controller/loteamento_bovino_controller.dart';
import 'widgets/loteamento_input_form_widget.dart';
import 'widgets/loteamento_result_card_widget.dart';

class LoteamentoBovinoPage extends StatefulWidget {
  const LoteamentoBovinoPage({super.key});

  @override
  State<LoteamentoBovinoPage> createState() => _LoteamentoBovinoPageState();
}

class _LoteamentoBovinoPageState extends State<LoteamentoBovinoPage> {
  late final LoteamentoBovinoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LoteamentoBovinoController());
    _controller.init();
  }

  @override
  void dispose() {
    Get.delete<LoteamentoBovinoController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(72),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: PageHeaderWidget(
                title: 'Loteamento Bovino',
                subtitle: 'Cálculos para manejo de bovinos',
                icon: Icons.pets,
                showBackButton: true,
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: LoteamentoInputFormWidget(),
                      ),
                      SizedBox(height: 10),
                      LoteamentoResultCardWidget(),
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
