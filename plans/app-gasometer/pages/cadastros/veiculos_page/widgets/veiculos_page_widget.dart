// Flutter

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../bindings/veiculos_page_binding.dart';
import '../controller/veiculos_page_controller.dart';
import '../views/veiculos_page_view.dart';

// External packages

// Local imports

class VeiculosPage extends StatelessWidget {
  const VeiculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que os bindings estão inicializados quando a página é construída diretamente
    // (não através de navegação GetX)
    if (!Get.isRegistered<VeiculosPageController>()) {
      VeiculosPageBinding().dependencies();
    }

    return const VeiculosPageView();
  }
}
