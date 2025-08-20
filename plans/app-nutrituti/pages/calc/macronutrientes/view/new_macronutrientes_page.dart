// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../widgets/calc_appbar.dart';
import '../controller/new_macronutrientes_controller.dart';
import '../model/macronutrientes_model.dart';
import 'widgets/macronutrientes_info_widget.dart';
import 'widgets/new_macronutrientes_form_widget.dart';
import 'widgets/new_macronutrientes_result_widget.dart';

class NewMacronutrientesPage extends StatelessWidget {
  const NewMacronutrientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MacronutrientesController(MacronutrientesModel()),
      child: const _MacronutrientesPageContent(),
    );
  }
}

class _MacronutrientesPageContent extends StatelessWidget {
  const _MacronutrientesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalcAppBar(
        title: 'Distribuição de Macronutrientes',
        onInfoPressed: () => MacronutrientesInfoWidget.show(context),
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        NewMacronutrientesFormWidget(),
                        SizedBox(height: 10),
                        NewMacronutrientesResultWidget(),
                      ],
                    ),
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
