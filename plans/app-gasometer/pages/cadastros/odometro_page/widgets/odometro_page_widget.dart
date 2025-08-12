// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/odometro_page_controller.dart';
import '../views/odometro_page_view.dart';

class OdometroPage extends StatefulWidget {
  const OdometroPage({super.key});

  @override
  OdometroPageWidgetState createState() => OdometroPageWidgetState();
}

class OdometroPageWidgetState extends State<OdometroPage> {
  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller if not already present
    if (!Get.isRegistered<OdometroPageController>()) {
      Get.put(OdometroPageController());
    }
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    if (Get.isRegistered<OdometroPageController>()) {
      Get.delete<OdometroPageController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OdometroPageController>(
      builder: (controller) => const OdometroPageView(),
    );
  }
}
