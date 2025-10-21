// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/calc_appbar.dart';
import 'controller/calorias_diarias_controller.dart';
import 'widgets/calorias_diarias_form.dart';
import 'widgets/calorias_diarias_info.dart';
import 'widgets/calorias_diarias_result.dart';

class CaloriasDiariasPage extends StatefulWidget {
  const CaloriasDiariasPage({super.key});

  @override
  State<CaloriasDiariasPage> createState() => _CaloriasDiariasPageState();
}

class _CaloriasDiariasPageState extends State<CaloriasDiariasPage> {
  final _controller = CaloriasDiariasController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalcAppBar(
        title: 'Calorias Diárias',
        onInfoPressed: () => CaloriasDiariasInfo.showInfoDialog(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1020,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Column(
                      children: [
                        CaloriasDiariasForm(controller: _controller),
                        const SizedBox(height: 10),
                        CaloriasDiariasResult(controller: _controller),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
