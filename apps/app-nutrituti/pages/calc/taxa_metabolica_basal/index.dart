// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/taxa_metabolica_basal_controller.dart';
import 'widgets/components/input_form.dart';
import 'widgets/components/result_card.dart';
import 'widgets/info_dialog.dart';

class TaxaMetabolicaBasalCalcPage extends StatelessWidget {
  const TaxaMetabolicaBasalCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaxaMetabolicaBasalController(),
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
              const Text('Taxa Metabólica Basal'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Mais informações sobre esse cálculo',
              onPressed: () => InfoDialog.show(context),
            ),
          ],
        ),
        body: const SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1020,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputForm(),
                      SizedBox(height: 16),
                      ResultCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
