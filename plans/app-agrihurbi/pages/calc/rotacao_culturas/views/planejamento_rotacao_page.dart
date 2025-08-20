// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/planejamento_rotacao_controller.dart';
import '../widgets/cultura_slider_widget.dart';
import '../widgets/result_card_widget.dart';

class PlanejamentoRotacaoPage extends StatefulWidget {
  const PlanejamentoRotacaoPage({super.key});

  @override
  PlanejamentoRotacaoPageState createState() => PlanejamentoRotacaoPageState();
}

class PlanejamentoRotacaoPageState extends State<PlanejamentoRotacaoPage> {
  final _controller = PlanejamentoRotacaoController();

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
            Text(
              'Informe a área total disponível',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 16),
            VTextField(
              labelText: 'Área total (ha)',
              hintText: '0.0',
              keyboardType: TextInputType.number,
              focusNode: _controller.focus1,
              txEditController: _controller.areaTotal,
              showClearButton: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Distribua a área entre as culturas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _controller.culturas.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CulturaSliderWidget(
                  cultura: _controller.culturas[index],
                  onChanged: (value) =>
                      _controller.atualizarPercentual(index, value),
                ),
              ),
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
          resultItems: _controller.culturas
              .map(
                (cultura) => ResultItemWidget(
                  label: cultura.nome,
                  value: _controller.formatNumber(cultura.areaCultura),
                  unit: 'ha',
                  icon: cultura.icon,
                  color: cultura.cor,
                ),
              )
              .toList(),
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
            padding: const EdgeInsets.all(12),
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
