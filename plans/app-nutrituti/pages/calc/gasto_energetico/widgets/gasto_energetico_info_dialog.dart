// Flutter imports:
import 'package:flutter/material.dart';

class GastoEnergeticoInfoDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _GastoEnergeticoInfoDialogContent(),
    );
  }
}

class _GastoEnergeticoInfoDialogContent extends StatelessWidget {
  const _GastoEnergeticoInfoDialogContent();

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    return Container(); // Implemente conforme o widget original
  }
}
