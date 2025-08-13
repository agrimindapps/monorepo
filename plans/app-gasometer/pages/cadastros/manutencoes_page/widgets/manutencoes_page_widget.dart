// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../bindings/manutencoes_page_bindings.dart';
import '../controller/manutencoes_page_controller.dart';
import '../views/manutencoes_page_view.dart';

class ManutencoesPage extends StatelessWidget {
  const ManutencoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Garante que o binding foi inicializado
    if (!Get.isRegistered<ManutencoesPageController>()) {
      ManutencoesPageBinding().dependencies();
    }

    return const ManutencoesPageView();
  }
}

// Widget alternativo com estado para compatibilidade
class ManutencoesPageStateful extends StatefulWidget {
  const ManutencoesPageStateful({super.key});

  @override
  ManutencoesPageStatefulState createState() => ManutencoesPageStatefulState();
}

class ManutencoesPageStatefulState extends State<ManutencoesPageStateful>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (!Get.isRegistered<ManutencoesPageController>()) {
      ManutencoesPageBinding().dependencies();
    }
  }

  @override
  void dispose() {
    // Mantém o controller vivo para preservar estado
    // O controller só será destruído quando o app for fechado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const ManutencoesPageView();
  }
}
