// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/atividade_fisica_model.dart';
import '../repository/atividade_fisica_repository.dart';

class CaloriasExercicioController extends ChangeNotifier {
  final _repository = AtividadeFisicaRepository();
  late AtividadeFisicaModel _atividadeSelecionada;

  final tempoController = TextEditingController();
  final tempoFocus = FocusNode();

  int _tempo = 0;
  num _resultado = 0;
  bool _calculado = false;

  CaloriasExercicioController() {
    _atividadeSelecionada = AtividadeFisicaModel.fromMap(
        _repository.obterTodasAtividadesComoMap()[0]);
  }

  AtividadeFisicaModel get atividadeSelecionada => _atividadeSelecionada;
  List<AtividadeFisicaModel> get atividades =>
      _repository.obterTodasAtividades();
  int get tempo => _tempo;
  num get resultado => _resultado;
  bool get calculado => _calculado;

  void setAtividade(AtividadeFisicaModel atividade) {
    _atividadeSelecionada = atividade;
    notifyListeners();
  }

  void calcular(BuildContext context) {
    if (tempoController.text.isEmpty) {
      _exibirMensagem(context, 'Tempo não informado.');
      tempoFocus.requestFocus();
      return;
    }

    _tempo = int.parse(tempoController.text);
    _resultado = (_tempo * _atividadeSelecionada.value);
    _calculado = true;
    notifyListeners();
  }

  void limpar() {
    tempoController.clear();
    _tempo = 0;
    _resultado = 0;
    _calculado = false;
    notifyListeners();
  }

  void compartilhar() {
    StringBuffer t = StringBuffer();
    t.writeln('Calorias por Exercicio');
    t.writeln();
    t.writeln('Valores');
    t.writeln('Tempo: $_tempo min');
    t.writeln('Atividade: ${_atividadeSelecionada.text}');
    t.writeln();
    t.writeln('Resultados');
    t.writeln('Calorias Consumidas: $_resultado kCal');
    t.writeln(
        '${_atividadeSelecionada.text} consome ${_atividadeSelecionada.value} kCal por minuto');

    Share.share(t.toString());
  }

  void _exibirMensagem(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.red.shade900);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    tempoController.dispose();
    tempoFocus.dispose();
    super.dispose();
  }
}
