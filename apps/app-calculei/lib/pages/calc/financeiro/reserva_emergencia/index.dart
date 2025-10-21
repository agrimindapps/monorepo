// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/themes/manager.dart';
import 'controller/reserva_emergencia_controller.dart';
import 'widgets/reserva_emergencia_info_dialog.dart';
import 'widgets/reserva_emergencia_input_form.dart';
import 'widgets/reserva_emergencia_result_card.dart';

class ReservaEmergenciaPage extends StatelessWidget {
  const ReservaEmergenciaPage({super.key});

  void _mostrarInfoDialog(BuildContext context) {
    ReservaEmergenciaInfoDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return ChangeNotifierProvider(
      create: (_) => ReservaEmergenciaController(),
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
                  Icons.savings_outlined,
                  size: 20,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                ),
                const SizedBox(width: 10),
                const Text('Reserva de Emergência'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _mostrarInfoDialog(context),
                tooltip: 'Informações sobre reserva de emergência',
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ReservaEmergenciaInputForm(),
                              SizedBox(height: 16),
                              ReservaEmergenciaResultCard(),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
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
