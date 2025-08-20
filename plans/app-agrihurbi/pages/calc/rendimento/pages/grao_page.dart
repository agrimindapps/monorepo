// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/grao_controller.dart';
import '../widgets/grao/input_fields_widget.dart';
import '../widgets/grao/result_card_widget.dart';

class GraoPage extends StatelessWidget {
  const GraoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GraoController());
    
    // Carregar dados salvos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.carregarDados();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Rendimento - Grãos'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GraoInputFieldsWidget(),
            SizedBox(height: 16),
            GraoResultCardWidget(),
          ],
        ),
      ),
    );
  }
}
