// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controllers/gasto_energetico_controller.dart';
import '../widgets/gasto_energetico/atividades_widget.dart';
import '../widgets/gasto_energetico/input_fields_widget.dart';

class GastoEnergeticoView extends StatefulWidget {
  const GastoEnergeticoView({super.key});

  @override
  State<GastoEnergeticoView> createState() => _GastoEnergeticoViewState();
}

class _GastoEnergeticoViewState extends State<GastoEnergeticoView> {
  final _controller = GastoEnergeticoController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
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
                          'Sobre o Gasto Energético Total',
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
                    'O que é GET:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O Gasto Energético Total (GET) é a quantidade total de energia que seu corpo utiliza ao longo do dia. Este cálculo considera tanto o metabolismo basal quanto a energia gasta em diferentes atividades físicas ao longo do dia.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
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

  void _calcular() {
    String? error = _controller.calcular(context);
    if (error != null) {
      _showMessage(error);
    } else {
      _showMessage('Cálculo realizado com sucesso!', isError: false);
      setState(() {}); // Atualiza a UI
    }
  }

  void _showMessage(String message, {bool isError = true}) {
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

  void _compartilhar() {
    SharePlus.instance.share(ShareParams(text: _controller.gerarTextoCompartilhamento()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputFieldsWidget(
            controller: _controller,
            onCalcular: _calcular,
            onLimpar: () {
              setState(() {
                _controller.limpar();
              });
            },
            onInfoPressed: _showInfoDialog,
          ),
          AtividadesWidget(controller: _controller),
          if (_controller.model.calculado) ...[
            const SizedBox(height: 16),
            _buildResultCard(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado do GET',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _compartilhar,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartilhar'),
                  style: ShadcnStyle.textButtonStyle,
                ),
              ],
            ),
            const Divider(thickness: 1),
            // Resultado principal
            Card(
              margin: const EdgeInsets.symmetric(vertical: 16),
              color: isDark ? Colors.amber.withAlpha(26) : Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isDark
                      ? Colors.amber.withAlpha(77)
                      : Colors.amber.shade100,
                ),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gasto Energético Total:',
                      style: TextStyle(
                        fontSize: 16,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_controller.numberFormat.format(_controller.model.gastoTotal)} kcal/dia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.amber.shade300
                            : Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taxa Metabólica Basal (TMB): ${_controller.numberFormat.format(_controller.model.tmb)} kcal/dia',
                      style: TextStyle(
                        fontSize: 14,
                        color: ShadcnStyle.mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
