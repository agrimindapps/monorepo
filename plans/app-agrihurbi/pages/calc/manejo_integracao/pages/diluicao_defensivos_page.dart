// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/diluicao_defensivos_controller.dart';
import '../widgets/diluicao_defensivos/input_fields_widget.dart';
import '../widgets/diluicao_defensivos/result_card_widget.dart';

class DiluicaoDefensivosPage extends StatefulWidget {
  const DiluicaoDefensivosPage({super.key});

  @override
  State<DiluicaoDefensivosPage> createState() => _DiluicaoDefensivosPageState();
}

class _DiluicaoDefensivosPageState extends State<DiluicaoDefensivosPage> {
  final _controller = DiluicaoDefensivosController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputFieldsWidget(controller: _controller),
            const SizedBox(height: 16),
            ResultCardWidget(controller: _controller),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
