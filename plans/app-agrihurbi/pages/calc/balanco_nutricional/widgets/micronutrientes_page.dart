// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/micronutrientes_controller.dart';
import '../models/micronutrientes_model.dart';
import 'micronutrientes_form_new.dart';
import 'micronutrientes_result_new.dart';

class MicronutrientesPage extends StatelessWidget {
  const MicronutrientesPage({super.key});

  static Widget create() {
    Get.put(MicronutrientesController(MicronutrientesModel()));
    return const MicronutrientesPage();
  }

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MicronutrientesFormNew(),
          SizedBox(height: 16),
          MicronutrientesResultNew(),
        ],
      ),
    );
  }
}
