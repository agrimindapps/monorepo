// index.dart: Página principal que une controller, widgets e lógica

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/densidade_nutrientes_controller.dart';
import 'widgets/densidade_nutrientes_info_dialog.dart';

// Importe outros widgets conforme forem migrados

class ZNewDensidadeNutrientesPage extends StatelessWidget {
  const ZNewDensidadeNutrientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DensidadeNutrientesController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Densidade de Nutrientes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => DensidadeNutrientesInfoDialog.show(context),
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Aqui vão os widgets de formulário e resultado
                // Exemplo:
                // DensidadeNutrientesInputForm(),
                // DensidadeNutrientesResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
