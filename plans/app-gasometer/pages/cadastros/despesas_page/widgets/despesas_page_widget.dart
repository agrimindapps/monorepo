// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/despesas_page_controller.dart';
import '../views/despesas_page_view.dart';

class DespesasPage extends StatefulWidget {
  const DespesasPage({super.key});

  @override
  DespesasPageWidgetState createState() => DespesasPageWidgetState();
}

class DespesasPageWidgetState extends State<DespesasPage> {
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller if not already present
    if (!Get.isRegistered<DespesasPageController>()) {
      Get.put(DespesasPageController());
    }
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<DespesasPageController>()) {
      Get.delete<DespesasPageController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DespesasPageController>(
      builder: (controller) => const DespesasPageView(),
    );
  }
}
