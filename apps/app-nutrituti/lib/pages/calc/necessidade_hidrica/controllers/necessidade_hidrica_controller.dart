// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../models/necessidade_hidrica_model.dart';

class NecessidadeHidricaController extends ChangeNotifier {
  final _model = NecessidadeHidricaModel();
  bool _calculado = false;

  // Getters
  NecessidadeHidricaModel get model => _model;
  bool get calculado => _calculado;

  // Controller methods
  bool validarCampos() {
    return _model.isValid();
  }

  void calcular(BuildContext context) {
    if (!validarCampos()) {
      _exibirMensagem(
          context, 'Por favor, preencha todos os campos corretamente');
      return;
    }

    _model.peso = double.parse(_model.pesoController.text.replaceAll(',', '.'));

    // Cálculo básico: 35ml por kg de peso corporal
    _model.resultado = _model.peso * 35;

    // Ajuste baseado no nível de atividade física e clima
    final atividadeFator = _model.getNivelAtividadeFator();
    final climaFator = _model.getClimaFator();

    _model.resultadoAjustado =
        _model.resultado * (1 + atividadeFator + climaFator);

    // Converte ml para litros com 2 casas decimais
    _model.resultado = _model.resultado / 1000;
    _model.resultadoAjustado = _model.resultadoAjustado / 1000;

    _calculado = true;
    notifyListeners();

    _exibirMensagem(context, 'Cálculo realizado com sucesso!', isError: false);
  }

  void limpar() {
    _model.limpar();
    _calculado = false;
    notifyListeners();
  }

  void compartilhar() {
    // Template reutilizável otimizado
    const String templateFixo = '''Necessidade Hídrica Diária

Valores''';

    const String templateResultados = '''
Resultados''';

    const String templateAviso = '''
Importante: Esta é uma estimativa. Consulte um profissional de saúde para recomendações personalizadas.''';

    // Pre-formatar valores numéricos
    final pesoFormatado = _model.peso.toStringAsFixed(1);
    final resultadoBasico = _model.resultado.toStringAsFixed(2);
    final resultadoAjustado = _model.resultadoAjustado.toStringAsFixed(2);

    // Buscar textos uma única vez
    final nivelAtividadeTexto = _model.niveisAtividade.firstWhere(
            (nivel) => nivel['id'] == _model.nivelAtividadeSelecionado)['text']
        as String;
    final climaTexto = _model.tiposClima.firstWhere(
        (clima) => clima['id'] == _model.climaSelecionado)['text'] as String;

    // Construção otimizada usando interpolação direta
    final shareText = '''$templateFixo
Peso: $pesoFormatado kg
Nível de Atividade: $nivelAtividadeTexto
Clima: $climaTexto$templateResultados
Ingestão básica recomendada: $resultadoBasico litros/dia
Ingestão ajustada recomendada: $resultadoAjustado litros/dia$templateAviso''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _exibirMensagem(BuildContext context, String message,
      {bool isError = true}) {
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
        backgroundColor: isError ? Colors.red.shade900 : Colors.blue.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
