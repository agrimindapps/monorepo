// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'widgets/peso_ideal_form.dart';
import 'widgets/peso_ideal_info.dart';
import 'widgets/peso_ideal_result.dart';

class PesoIdealPage extends StatelessWidget {
  const PesoIdealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade300
                  : Colors.blue,
            ),
            const SizedBox(width: 10),
            const Text('Peso Ideal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => PesoIdealInfoDialog.show(context),
            tooltip: 'Informações sobre o Peso Ideal',
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: PesoIdealForm(),
                  ),
                  SizedBox(height: 10),
                  PesoIdealResult(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
