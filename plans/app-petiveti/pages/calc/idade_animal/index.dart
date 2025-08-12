// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../../core/themes/manager.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/idade_animal_controller.dart';
import 'widgets/idade_animal_input_form.dart';
import 'widgets/idade_animal_result_card.dart';

class CalcIdadeAnimalPage extends StatelessWidget {
  const CalcIdadeAnimalPage({super.key});

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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Calculadora de Idade Animal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ShadcnStyle.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Como funciona a calculadora:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Esta calculadora converte a idade do seu animal de estimação em uma idade humana equivalente. '
                    'O método utilizado leva em consideração que o desenvolvimento não é linear e varia conforme a espécie e o porte do animal.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Diferenças entre espécies:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Cães: O cálculo considera o porte do animal, pois cães menores tendem a viver mais tempo.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Gatos: O cálculo é baseado apenas na idade, sem considerar o porte.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.shade900.withValues(alpha: 0.2)
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.amber.shade700.withValues(alpha: 0.3)
                            : Colors.amber.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: isDark
                              ? Colors.amber.shade300
                              : Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Importante: Esta é apenas uma estimativa. A longevidade e o desenvolvimento variam entre indivíduos.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ShadcnStyle.primaryButtonStyle,
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IdadeAnimalController(),
      child: Consumer<IdadeAnimalController>(builder: (context, controller, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      IdadeAnimalInputForm(controller: controller),
                      IdadeAnimalResultCard(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: PageHeaderWidget(
            title: 'Calculadora de Idade Animal',
            subtitle: 'Converta a idade do animal para idade humana',
            icon: Icons.pets,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Informações sobre cálculo de idade',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
