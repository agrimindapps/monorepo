// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/manutencoes_page_controller.dart';
import '../views/manutencoes_page_view.dart';

class ManutencoesPage extends StatefulWidget {
  const ManutencoesPage({super.key});

  @override
  ManutencoesPageWidgetState createState() => ManutencoesPageWidgetState();
}

class ManutencoesPageWidgetState extends State<ManutencoesPage> {
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller if not already present
    if (!Get.isRegistered<ManutencoesPageController>()) {
      Get.put(ManutencoesPageController());
    }
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<ManutencoesPageController>()) {
      Get.delete<ManutencoesPageController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManutencoesPageController>(
      builder: (controller) => const ManutencoesPageView(),
    );
  }
}
