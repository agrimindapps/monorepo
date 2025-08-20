// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/peso_ideal_controller.dart';
import 'view/peso_ideal_page.dart';

class PesoIdealCalcPage extends StatelessWidget {
  const PesoIdealCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PesoIdealController(),
      child: const PesoIdealPage(),
    );
  }
}
