// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controllers/leguminosa_controller.dart';
import '../widgets/leguminosa/input_fields_widget.dart';
import '../widgets/leguminosa/result_card_widget.dart';

class LeguminosaPage extends StatelessWidget {
  const LeguminosaPage({super.key});

  void _showInfoDialog(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.blue.shade300 : Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Calculadora de Rendimento - Leguminosas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Como funciona:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta calculadora estima o rendimento de culturas leguminosas com base nos componentes de rendimento da cultura.',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Componentes considerados:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Número de vagens por planta\n• Número de sementes por vagem\n• Peso de mil grãos (g)\n• Número de plantas por m²',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade700,
                        ),
                        child: const Text('Fechar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    Get.put(LeguminosaController());

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
                Icons.eco,
                size: 20,
                color: isDark ? Colors.green.shade300 : Colors.green,
              ),
              const SizedBox(width: 10),
              const Text('Rendimento - Leguminosas'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: ShadcnStyle.textColor,
              ),
              onPressed: () => _showInfoDialog(context),
              tooltip: 'Informações sobre o cálculo',
            ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputFieldsWidget(),
                    SizedBox(height: 10),
                    ResultCardWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
