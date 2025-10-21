// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'controllers/vista_vs_parcelado_controller.dart';
import 'models/vista_vs_parcelado_model.dart';
import 'widgets/custom_widgets.dart';

class VistaVsParceladoPage extends StatefulWidget {
  const VistaVsParceladoPage({super.key});

  @override
  State<VistaVsParceladoPage> createState() => _VistaVsParceladoPageState();
}

class _VistaVsParceladoPageState extends State<VistaVsParceladoPage> {
  final _controller = VistaVsParceladoController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  TextInputFormatter _criarFormatadorMoeda() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      String onlyDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      double value = double.tryParse(onlyDigits) ?? 0;
      value = value / 100;
      String formatted = VistaVsParceladoModel.formatadorMoeda.format(value);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
              Icons.calculate_outlined,
              size: 20,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            const SizedBox(width: 10),
            const Text('Valor à Vista vs. Parcelado'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Implementar diálogo de informações
            },
            tooltip: 'Informações sobre o cálculo',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _controller.valorVistaController,
                              focusNode: _controller.valorVistaFocus,
                              label: 'Valor à vista',
                              hint: 'R\$ 0,00',
                              icon: Icons.monetization_on_outlined,
                              iconColor:
                                  isDark ? Colors.green.shade300 : Colors.green,
                              inputFormatters: [_criarFormatadorMoeda()],
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _controller.valorParceladoController,
                              focusNode: _controller.valorParceladoFocus,
                              label: 'Valor da parcela',
                              hint: 'R\$ 0,00',
                              icon: Icons.payment_outlined,
                              iconColor:
                                  isDark ? Colors.amber.shade300 : Colors.amber,
                              inputFormatters: [_criarFormatadorMoeda()],
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _controller.numeroParcelasController,
                              focusNode: _controller.numeroParcelasFocus,
                              label: 'Número de parcelas',
                              hint: '12',
                              icon: Icons.format_list_numbered,
                              iconColor:
                                  isDark ? Colors.blue.shade300 : Colors.blue,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _controller.taxaJurosController,
                              focusNode: _controller.taxaJurosFocus,
                              label: 'Taxa de juros mensal (%)',
                              hint: '0,8',
                              icon: Icons.percent,
                              iconColor: isDark
                                  ? Colors.deepPurple.shade300
                                  : Colors.deepPurple,
                              inputFormatters: [
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  if (newValue.text.isEmpty) return newValue;
                                  String text = newValue.text;
                                  if (!RegExp(r'^\d*,?\d{0,2}$')
                                      .hasMatch(text)) {
                                    return oldValue;
                                  }
                                  return newValue;
                                }),
                              ],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _controller.limparCampos();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Limpar'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    String? erro =
                                        _controller.calcular(context);
                                    if (erro != null) {
                                      _mostrarMensagem(erro, isError: true);
                                    } else {
                                      _mostrarMensagem(
                                          'Cálculo realizado com sucesso!');
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.calculate_outlined),
                                  label: const Text('Calcular'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_controller.model.resultadoVisivel) ...[
                    const SizedBox(height: 16),
                    ResultadoCard(
                      melhorOpcao: _controller.model.melhorOpcao,
                      economiaFormatada: VistaVsParceladoModel.formatadorMoeda
                          .format(_controller.model.economiaOuCustoAdicional),
                      taxaImplicitaFormatada:
                          '${VistaVsParceladoModel.formatadorPercentual.format(_controller.model.taxaImplicita.abs())}${_controller.model.taxaImplicita < 0 ? ' (desconto)' : ''}/mês',
                      detalhesCalculo: _controller.model.detalhesCalculo,
                      onCompartilhar: () async {
                        try {
                          await _controller.compartilhar();
                          _mostrarMensagem('Compartilhado com sucesso!');
                        } catch (e) {
                          _mostrarMensagem(
                              'Erro ao compartilhar. Tente novamente.',
                              isError: true);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
