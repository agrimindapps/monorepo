// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../widgets/page_header_widget.dart';
import 'controller/aproveitamento_carcaca_controller.dart';
import 'widgets/aproveitamento_input_form_widget.dart';
import 'widgets/aproveitamento_result_card_widget.dart';

class AproveitamentoCarcacaPage extends StatefulWidget {
  const AproveitamentoCarcacaPage({super.key});

  @override
  State<AproveitamentoCarcacaPage> createState() =>
      _AproveitamentoCarcacaPageState();
}

class _AproveitamentoCarcacaPageState extends State<AproveitamentoCarcacaPage> {
  late final AproveitamentoCarcacaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AproveitamentoCarcacaController());
    _controller.init();
  }

  @override
  void dispose() {
    Get.delete<AproveitamentoCarcacaController>();
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
                title: 'Aproveitamento de Carcaça',
                subtitle: 'Cálculos de rendimento de carcaça',
                icon: Icons.scale,
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
                        child: AproveitamentoInputFormWidget(),
                      ),
                      SizedBox(height: 10),
                      AproveitamentoResultCardWidget(),
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
