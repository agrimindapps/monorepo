// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'controller/proteinas_diarias_controller.dart';
import 'model/proteinas_diarias_model.dart';
import 'widgets/proteinas_diarias_form.dart';
import 'widgets/proteinas_diarias_info.dart';
import 'widgets/proteinas_diarias_result.dart';

class ProteinasDiariasPage extends StatefulWidget {
  const ProteinasDiariasPage({super.key});

  @override
  State<ProteinasDiariasPage> createState() => _ProteinasDiariasPageState();
}

class _ProteinasDiariasPageState extends State<ProteinasDiariasPage> {
  final _unfocusNode = FocusNode();
  final _model = ProteinasDiariasModel();
  late final _controller = ProteinasDiariasController(_model);
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _unfocusNode.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade300
                  : Colors.blue,
            ),
            const SizedBox(width: 10),
            const Text('Proteínas Diárias'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => ProteinasDiariasInfo.show(context),
            tooltip: 'Informações sobre Proteínas Diárias',
          ),
        ],
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: ProteinasDiariasForm(
                      model: _model,
                      controller: _controller,
                      setState: setState,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ProteinasDiariasResult(
                    model: _model,
                    controller: _controller,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
