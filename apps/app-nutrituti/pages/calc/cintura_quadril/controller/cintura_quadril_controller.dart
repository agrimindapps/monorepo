// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/cintura_quadril_model.dart';

/// Controller otimizado para minimizar rebuilds desnecessários
/// usando notificadores granulares para cada estado específico
class CinturaQuadrilController extends ChangeNotifier {
  final TextEditingController cinturaController = TextEditingController();
  final TextEditingController quadrilController = TextEditingController();
  final FocusNode focusCintura = FocusNode();
  final FocusNode focusQuadril = FocusNode();

  // Notificadores granulares para otimizar rebuilds específicos
  // Cada um é responsável por um aspecto específico da UI
  final ValueNotifier<int> _generoNotifier = ValueNotifier<int>(1);
  final ValueNotifier<CinturaQuadrilModel?> _resultadoNotifier =
      ValueNotifier<CinturaQuadrilModel?>(null);
  final ValueNotifier<bool> _mostrarResultadoNotifier =
      ValueNotifier<bool>(false);

  // Getters públicos para acesso aos notificadores granulares
  ValueNotifier<int> get generoNotifier => _generoNotifier;
  ValueNotifier<CinturaQuadrilModel?> get resultadoNotifier =>
      _resultadoNotifier;
  ValueNotifier<bool> get mostrarResultadoNotifier => _mostrarResultadoNotifier;

  // Getters de conveniência para compatibilidade
  int get generoSelecionado => _generoNotifier.value;
  CinturaQuadrilModel? get resultado => _resultadoNotifier.value;
  bool get mostrarResultado => _mostrarResultadoNotifier.value;

  @override
  void dispose() {
    cinturaController.dispose();
    quadrilController.dispose();
    focusCintura.dispose();
    focusQuadril.dispose();
    _generoNotifier.dispose();
    _resultadoNotifier.dispose();
    _mostrarResultadoNotifier.dispose();
    super.dispose();
  }

  void onGeneroChanged(int value) {
    _generoNotifier.value = value;
    // Não precisa notifyListeners() aqui pois o ValueNotifier já notifica seus ouvintes
  }

  bool _validarEntradas() {
    if (cinturaController.text.isEmpty || quadrilController.text.isEmpty) {
      return false;
    }

    final cintura =
        double.tryParse(cinturaController.text.replaceAll(',', '.')) ?? 0;
    final quadril =
        double.tryParse(quadrilController.text.replaceAll(',', '.')) ?? 0;

    return cintura > 0 && quadril > 0;
  }

  void calcular() {
    if (!_validarEntradas()) {
      _resultadoNotifier.value = null;
      _mostrarResultadoNotifier.value = false;
      return;
    }

    final cintura = double.parse(cinturaController.text.replaceAll(',', '.'));
    final quadril = double.parse(quadrilController.text.replaceAll(',', '.'));
    final rcq = calcularRCQ(cintura, quadril);
    final classificacao = obterClassificacao(rcq);
    final comentario = obterComentario(classificacao);

    _resultadoNotifier.value = CinturaQuadrilModel(
      cintura: cintura,
      quadril: quadril,
      rcq: rcq,
      generoSelecionado: generoSelecionado,
      classificacao: classificacao,
      comentario: comentario,
    );
    _mostrarResultadoNotifier.value = true;
  }

  void limpar() {
    cinturaController.clear();
    quadrilController.clear();
    _resultadoNotifier.value = null;
    _mostrarResultadoNotifier.value = false;
  }

  void compartilhar() {
    if (resultado != null) {
      Share.share(resultado!.gerarTextoCompartilhamento());
    }
  }

  double calcularRCQ(double cintura, double quadril) {
    return cintura / quadril;
  }

  String obterClassificacao(double rcq) {
    if (generoSelecionado == 1) {
      // Classificação para homens
      if (rcq < 0.83) return 'Baixo';
      if (rcq >= 0.83 && rcq <= 0.88) return 'Moderado';
      if (rcq > 0.88 && rcq <= 0.94) return 'Alto';
      return 'Muito Alto';
    } else {
      // Classificação para mulheres
      if (rcq < 0.71) return 'Baixo';
      if (rcq >= 0.71 && rcq <= 0.77) return 'Moderado';
      if (rcq > 0.77 && rcq <= 0.82) return 'Alto';
      return 'Muito Alto';
    }
  }

  String obterComentario(String classificacao) {
    switch (classificacao) {
      case 'Baixo':
        return 'Seu risco de doenças cardiovasculares e metabólicas é baixo.';
      case 'Moderado':
        return 'Seu risco de doenças cardiovasculares e metabólicas é moderado. Monitore regularmente.';
      case 'Alto':
        return 'Seu risco de doenças cardiovasculares e metabólicas é alto. Recomenda-se consultar um profissional de saúde.';
      case 'Muito Alto':
        return 'Seu risco de doenças cardiovasculares e metabólicas é muito alto. É importante consultar um profissional de saúde o mais breve possível.';
      default:
        return 'Classificação não disponível.';
    }
  }
}
