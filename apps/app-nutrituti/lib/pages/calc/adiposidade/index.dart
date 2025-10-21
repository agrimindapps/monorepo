// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/adiposidade_controller.dart';
import 'views/adiposidade_view.dart';

class AdiposidadePage extends StatelessWidget {
  const AdiposidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdipososidadeController(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Text('Índice de Adiposidade Corporal'),
            ],
          ),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: AdipososidadeView(),
            ),
          ),
        ),
      ),
    );
  }
}
