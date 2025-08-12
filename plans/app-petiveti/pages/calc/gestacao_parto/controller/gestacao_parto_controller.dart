// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../model/gestacao_parto_model.dart';

class GestacaoPartoController extends ChangeNotifier {
  GestacaoPartoModel _model;
  final formKey = GlobalKey<FormState>();

  GestacaoPartoController() : _model = GestacaoPartoModel.initial();

  // Getters para acessar o modelo
  GestacaoPartoModel get model => _model;
  bool get showInfoCard => _model.showInfoCard;
  DateTime? get dataAcasalamento => _model.dataAcasalamento;
  DateTime? get dataUltrassom => _model.dataUltrassom;
  double? get tamanhoFetos => _model.tamanhoFetos;
  String? get especieSelecionada => _model.especieSelecionada;
  String? get racaSelecionada => _model.racaSelecionada;
  String? get metodoCalculo => _model.metodoCalculo;
  DateTime? get dataParto => _model.dataParto;
  List<String>? get fasesPrenhez => _model.fasesPrenhez;
  String? get fasePrenhezAtual => _model.fasePrenhezAtual;

  // Métodos para atualizar o modelo
  void toggleInfoCard() {
    _model = _model.copyWith(showInfoCard: !_model.showInfoCard);
    notifyListeners();
  }

  void atualizarEspecie(String? especie) {
    if (especie == null) return;

    var novoModelo = _model.copyWith(
      especieSelecionada: especie,
      racaSelecionada: null,
      dataParto: null,
      fasesPrenhez: null,
      fasePrenhezAtual: null,
    );

    // Se a espécie não for cão ou gato e o método for ultrassom, resetar para acasalamento
    if (especie != 'Cão' &&
        especie != 'Gato' &&
        _model.metodoCalculo == _model.opcoesTipoCalculo[1]) {
      novoModelo =
          novoModelo.copyWith(metodoCalculo: _model.opcoesTipoCalculo[0]);
    }

    _model = novoModelo;
    notifyListeners();
  }

  void atualizarMetodoCalculo(String? metodo) {
    if (metodo == null) return;

    _model = _model.copyWith(
      metodoCalculo: metodo,
      dataParto: null,
      fasesPrenhez: null,
      fasePrenhezAtual: null,
    );
    notifyListeners();
  }

  void atualizarDataAcasalamento(DateTime? data) {
    if (data == null) return;

    _model = _model.copyWith(
      dataAcasalamento: data,
      dataParto: null,
      fasesPrenhez: null,
      fasePrenhezAtual: null,
    );
    notifyListeners();
  }

  void atualizarDataUltrassom(DateTime? data) {
    if (data == null) return;

    _model = _model.copyWith(
      dataUltrassom: data,
      dataParto: null,
      fasesPrenhez: null,
      fasePrenhezAtual: null,
    );
    notifyListeners();
  }

  void atualizarTamanhoFetos(String value) {
    final tamanho = double.tryParse(value);
    if (tamanho == null) return;

    _model = _model.copyWith(tamanhoFetos: tamanho);
    notifyListeners();
  }

  void limpar() {
    _model.limpar();
    notifyListeners();
  }

  // Métodos de cálculo
  void calcular() {
    if (!formKey.currentState!.validate()) return;

    if (_model.metodoCalculo == _model.opcoesTipoCalculo[0]) {
      _calcularPorAcasalamento();
    } else {
      _calcularPorUltrassom();
    }

    _determinarFaseAtual();
    notifyListeners();
  }

  void _calcularPorAcasalamento() {
    if (_model.dataAcasalamento == null ||
        _model.especieSelecionada == null ||
        _model.racaSelecionada == null) {
      return;
    }

    final diasGestacao = _model.diasGestacao[_model.especieSelecionada]!;
    final ajusteDias = _model.ajusteRacasDias[_model.especieSelecionada]![
            _model.racaSelecionada] ??
        0;

    final dataParto =
        _model.dataAcasalamento!.add(Duration(days: diasGestacao + ajusteDias));
    _model = _model.copyWith(dataParto: dataParto);

    _calcularFasesGestacao(_model.dataAcasalamento!);
  }

  void _calcularPorUltrassom() {
    if (_model.tamanhoFetos == null ||
        _model.dataUltrassom == null ||
        _model.especieSelecionada == null) {
      return;
    }

    int idadeEstimada = 0;

    if (_model.especieSelecionada == 'Cão') {
      idadeEstimada = _estimarIdadeFetosCao();
    } else if (_model.especieSelecionada == 'Gato') {
      idadeEstimada = _estimarIdadeRetosGato();
    }

    final dataAcasalamentoEstimada =
        _model.dataUltrassom!.subtract(Duration(days: idadeEstimada));
    _model = _model.copyWith(dataAcasalamento: dataAcasalamentoEstimada);

    _calcularPorAcasalamento();
  }

  int _estimarIdadeFetosCao() {
    var menorDiferenca = double.infinity;
    int idadeEstimada = 0;

    for (var estimativa in _model.estimativaIdadePeloTamanho) {
      double tamanho = estimativa['tamanho'];
      int dias = estimativa['dias'];

      double diferenca = (_model.tamanhoFetos! - tamanho).abs();
      if (diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        idadeEstimada = dias;
      }
    }

    return idadeEstimada;
  }

  int _estimarIdadeRetosGato() {
    if (_model.tamanhoFetos! <= 10) return 30;
    if (_model.tamanhoFetos! <= 20) return 40;
    if (_model.tamanhoFetos! <= 40) return 50;
    return 60;
  }

  void _calcularFasesGestacao(DateTime dataInicio) {
    if (_model.especieSelecionada == null) return;

    final fases = _model.fasesGestacao[_model.especieSelecionada]!;
    final novasFases = fases.map((fase) {
      DateTime dataInicioFase = dataInicio.add(Duration(days: fase['inicio']));
      DateTime dataFimFase = dataInicio.add(Duration(days: fase['fim']));

      return '${DateFormat('dd/MM/yyyy').format(dataInicioFase)} a ${DateFormat('dd/MM/yyyy').format(dataFimFase)}: ${fase['descricao']}';
    }).toList();

    _model = _model.copyWith(fasesPrenhez: novasFases);
  }

  void _determinarFaseAtual() {
    if (_model.dataAcasalamento == null || _model.especieSelecionada == null) {
      return;
    }

    final hoje = DateTime.now();
    final diasDesdeAcasalamento =
        hoje.difference(_model.dataAcasalamento!).inDays;

    if (diasDesdeAcasalamento < 0) {
      _model = _model.copyWith(
          fasePrenhezAtual: 'Data inválida: acasalamento no futuro');
      return;
    }

    if (_model.dataParto != null && hoje.isAfter(_model.dataParto!)) {
      _model = _model.copyWith(fasePrenhezAtual: 'Parto já deve ter ocorrido');
      return;
    }

    final fases = _model.fasesGestacao[_model.especieSelecionada]!;

    for (var fase in fases) {
      if (diasDesdeAcasalamento >= fase['inicio'] &&
          diasDesdeAcasalamento <= fase['fim']) {
        _model = _model.copyWith(fasePrenhezAtual: fase['descricao']);
        return;
      }
    }

    _model = _model.copyWith(fasePrenhezAtual: 'Fase não identificada');
  }
}
