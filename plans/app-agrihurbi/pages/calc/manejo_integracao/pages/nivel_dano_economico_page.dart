// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/nivel_dano_economico_controller.dart';
import '../widgets/nivel_dano_economico/input_fields_widget.dart';
import '../widgets/nivel_dano_economico/result_card_widget.dart';

class NivelDanoEconomicoPage extends StatefulWidget {
  const NivelDanoEconomicoPage({super.key});

  @override
  State<NivelDanoEconomicoPage> createState() => _NivelDanoEconomicoPageState();
}

class _NivelDanoEconomicoPageState extends State<NivelDanoEconomicoPage> {
  final _controller = NivelDanoEconomicoController();

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
