// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/massa_corporea_controller.dart';
import 'widgets/massa_corporea_form.dart';
import 'widgets/massa_corporea_info.dart';
import 'widgets/massa_corporea_result.dart';

class MassaCorporeaPage extends StatefulWidget {
  const MassaCorporeaPage({super.key});

  @override
  State<MassaCorporeaPage> createState() => _MassaCorporeaPageState();
}

class _MassaCorporeaPageState extends State<MassaCorporeaPage> {
  late MassaCorporeaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MassaCorporeaController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
            title: Row(
              children: [
                Icon(
                  Icons.monitor_weight_outlined,
                  size: 20,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.green.shade300
                      : Colors.green,
                ),
                const SizedBox(width: 10),
                const Text('Índice de Massa Corporal'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => MassaCorporeaInfoDialog.show(context),
                tooltip: 'Informações sobre o IMC',
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: MassaCorporeaForm(isMobile: isMobile),
                        ),
                        const SizedBox(height: 16),
                        MassaCorporeaResult(isMobile: isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
