// STUB - FASE 0.7
// TODO FASE 1: Implementar widget de feedback de configuração

import 'package:flutter/material.dart';

class FeedbackConfigOptionWidget extends StatelessWidget {
  const FeedbackConfigOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.feedback),
      title: const Text('Enviar Feedback'),
      onTap: () {
        // TODO: Implementar feedback
      },
    );
  }
}
