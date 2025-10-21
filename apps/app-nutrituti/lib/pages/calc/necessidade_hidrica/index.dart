// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controllers/necessidade_hidrica_controller.dart';
import 'widgets/necessidade_hidrica_view.dart';

class NecessidadeHidricaCalcPage extends StatelessWidget {
  const NecessidadeHidricaCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NecessidadeHidricaController(),
      child: const NecessidadeHidricaView(),
    );
  }
}
