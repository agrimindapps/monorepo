// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/exercicio_model.dart';
import '../repository/exercicio_repository.dart';

class CaloriasExercicioController extends ChangeNotifier {
  final ExercicioRepository _repository;
  ExercicioModel? _atividadeSelecionada;
  int _tempo = 0;
  double _resultado = 0;
  bool _calculado = false;

  CaloriasExercicioController(this._repository) {
    _atividadeSelecionada = _repository.obterTodasAtividades().first;
  }

  ExercicioModel? get atividadeSelecionada => _atividadeSelecionada;
  int get tempo => _tempo;
  double get resultado => _resultado;
  bool get calculado => _calculado;
  List<ExercicioModel> get atividades => _repository.obterTodasAtividades();

  void selecionarAtividade(ExercicioModel atividade) {
    _atividadeSelecionada = atividade;
    notifyListeners();
  }

  void setTempo(String valor) {
    _tempo = int.tryParse(valor) ?? 0;
  }

  bool calcular() {
    if (_tempo <= 0 || _atividadeSelecionada == null) {
      return false;
    }

    _resultado = _atividadeSelecionada!.calcularCalorias(_tempo);
    _calculado = true;
    notifyListeners();
    return true;
  }

  void limpar() {
    _tempo = 0;
    _resultado = 0;
    _calculado = false;
    notifyListeners();
  }

  String gerarTextoCompartilhamento() {
    if (!_calculado || _atividadeSelecionada == null) return '';

    return '''
Calorias por Exercicio

Valores
Tempo: $_tempo min
Atividade: ${_atividadeSelecionada!.nome}

Resultados
Calorias Consumidas: $_resultado kCal
${_atividadeSelecionada!.nome} consome ${_atividadeSelecionada!.caloriasMinuto} kCal por minuto
''';
  }
}
