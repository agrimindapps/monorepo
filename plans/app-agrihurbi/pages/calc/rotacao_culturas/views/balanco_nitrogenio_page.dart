// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/balanco_nitrogenio_controller.dart';
import '../widgets/result_card_widget.dart';

class BalancoNitrogenioPage extends StatefulWidget {
  const BalancoNitrogenioPage({super.key});

  @override
  BalancoNitrogenioPageState createState() => BalancoNitrogenioPageState();
}

class BalancoNitrogenioPageState extends State<BalancoNitrogenioPage> {
  final _controller = BalancoNitrogenioController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exibirMensagem(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  void _calcular() {
    if (!_controller.validarCampos(_exibirMensagem)) return;

    _controller.calcular();
    _exibirMensagem('Cálculo realizado com sucesso!', isError: false);
  }

  void _compartilhar() {
    SharePlus.instance.share(ShareParams(text: _controller.getShareText()));
    _exibirMensagem('Informações compartilhadas!', isError: false);
  }

  Widget _buildInputFields() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VTextField(
              labelText: 'Área de plantio (ha)',
              hintText: '0.0',
              keyboardType: TextInputType.number,
              focusNode: _controller.focus1,
              txEditController: _controller.areaPlantio,
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Produtividade esperada (kg/ha)',
              hintText: '0.0',
              keyboardType: TextInputType.number,
              focusNode: _controller.focus2,
              txEditController: _controller.produtividadeEsperada,
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Teor de nitrogênio no solo (kg/ha)',
              hintText: '0.0',
              keyboardType: TextInputType.number,
              focusNode: _controller.focus3,
              txEditController: _controller.teorNitrogenioSolo,
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _controller.limpar,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                    style: ShadcnStyle.textButtonStyle,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Calcular'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final isDark = ThemeManager().isDark.value;

    return AnimatedOpacity(
      opacity: _controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: _controller.calculado,
        child: ResultCardWidget(
          onShare: _compartilhar,
          resultItems: [
            ResultItemWidget(
              label: 'Necessidade de nitrogênio:',
              value: _controller.formatNumber(_controller.nitrogenioNecessario),
              unit: 'kg',
              icon: Icons.science_outlined,
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
            ),
            ResultItemWidget(
              label: 'Nitrogênio disponível no solo:',
              value: _controller.formatNumber(_controller.nitrogenioSolo),
              unit: 'kg',
              icon: Icons.terrain_outlined,
              color: isDark ? Colors.green.shade300 : Colors.green.shade600,
            ),
            ResultItemWidget(
              label: 'Nitrogênio de fixação biológica:',
              value: _controller.formatNumber(_controller.nitrogenioFixacao),
              unit: 'kg',
              icon: Icons.eco_outlined,
              color: isDark ? Colors.orange.shade300 : Colors.orange.shade600,
            ),
            ResultItemWidget(
              label: 'Nitrogênio a ser adicionado:',
              value: _controller.formatNumber(_controller.nitrogenioAdicionar),
              unit: 'kg',
              icon: Icons.add_circle_outline,
              color: _controller.nitrogenioAdicionar > 0
                  ? (isDark ? Colors.red.shade300 : Colors.red.shade600)
                  : (isDark ? Colors.green.shade300 : Colors.green.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputFields(),
                const SizedBox(height: 12),
                _buildResults(),
              ],
            ),
          ),
        );
      },
    );
  }
}
