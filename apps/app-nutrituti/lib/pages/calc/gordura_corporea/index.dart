// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import 'widgets/gordura_corporea_info_dialog.dart';
import 'widgets/gordura_corporea_widget.dart';

/// Página principal do cálculo de gordura corporal (MVC)
class GorduraCorporeaCalcPage extends StatelessWidget {
  const GorduraCorporeaCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: Row(
          children: [
            Icon(
              Icons.percent_outlined,
              size: 20,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            const SizedBox(width: 10),
            const Text('Gordura Corporal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => GorduraCorporeaInfoDialog.show(context),
            tooltip: 'Informações sobre o cálculo',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: GorduraCorporeaWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
