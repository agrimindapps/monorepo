// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/diabetes_insulina_model.dart';

class DiabetesInsulinaController extends ChangeNotifier {
  final DiabetesInsulinaModel _model = DiabetesInsulinaModel();
  final formKey = GlobalKey<FormState>();

  DiabetesInsulinaModel get model => _model;
  bool get showInfoCard => _model.showInfoCard;

  void toggleInfoCard() {
    _model.showInfoCard = !_model.showInfoCard;
    notifyListeners();
  }

  void limpar() {
    _model.limpar();
    notifyListeners();
  }

  void calcular() {
    if (formKey.currentState!.validate()) {
      final peso =
          double.parse(_model.pesoController.text.replaceAll(',', '.'));
      final glicemia = int.parse(_model.glicemiaController.text);

      double dosagem;

      if (_model.usarRegra) {
        dosagem = double.parse(
            _model.dosagemInsulinaController.text.replaceAll(',', '.'));
      } else {
        // Cálculo baseado no peso e espécie
        final fatorBase =
            _model.fatoresInsulinaPorKg[_model.especieSelecionada]!;
        dosagem = peso * fatorBase;

        // Ajuste baseado na glicemia
        if (glicemia > 250) {
          dosagem *= 1.2; // Aumenta 20% se glicemia alta
        } else if (glicemia < 100) {
          dosagem *= 0.8; // Reduz 20% se glicemia baixa
        }
      }

      // Se tiver uma dose anterior, usar para ajuste
      if (_model.temDoseAnterior) {
        final doseAnterior = double.parse(
            _model.dosagemAnteriorController.text.replaceAll(',', '.'));
        if (glicemia > 250) {
          dosagem = doseAnterior * 1.1; // Aumenta 10% da dose anterior
        } else if (glicemia < 100) {
          dosagem = doseAnterior * 0.9; // Reduz 10% da dose anterior
        } else {
          dosagem = doseAnterior; // Mantém a dose anterior
        }
      }

      // Verificação final de segurança e arredondamento
      if (dosagem < 0.5) dosagem = 0.5;
      dosagem = (dosagem * 2).round() / 2; // Arredondar para a meia unidade

      _model.resultado = dosagem;
      _gerarRecomendacoes(glicemia, dosagem);
      notifyListeners();
    }
  }

  void _gerarRecomendacoes(int glicemia, double dosagem) {
    String rec = '';

    // Recomendações de monitoramento
    rec += 'Recomendações de monitoramento:\n';

    if (_model.tipoInsulinaSelecionada != null) {
      final duracao = _model.duracaoInsulina[_model.tipoInsulinaSelecionada]!;
      rec += '• Aplicar insulina a cada $duracao horas.\n';
    }

    if (glicemia > 300) {
      rec += '• Monitore a glicemia a cada 2-4 horas nas primeiras 12 horas.\n';
      rec +=
          '• Verifique sinais de cetoacidose (vômito, letargia, respiração ofegante).\n';
      rec +=
          '• Certifique-se de que o animal esteja bebendo água adequadamente.\n';
    } else if (glicemia > 250) {
      rec += '• Monitore a glicemia 2-3 vezes ao dia.\n';
      rec +=
          '• Ajuste a dosagem gradualmente conforme necessário nos próximos dias.\n';
    } else if (glicemia < 70) {
      rec +=
          '• EMERGÊNCIA: Ofereça alimento imediatamente ou aplique solução de glicose.\n';
      rec += '• Monitore a glicemia a cada 30 minutos até estabilização.\n';
      rec += '• Contate um veterinário urgentemente!\n';
    } else if (glicemia < 100) {
      rec += '• Monitore a glicemia a cada 2 horas.\n';
      rec +=
          '• Tenha mel ou xarope de milho disponível caso ocorra hipoglicemia.\n';
      rec += '• Garanta que o animal se alimente adequadamente.\n';
    } else {
      rec += '• Monitore a glicemia 2-3 vezes ao dia.\n';
      rec += '• Mantenha o registro das medições e doses aplicadas.\n';
    }

    // Recomendações gerais
    rec += '\nRecomendações gerais:\n';
    rec += '• Administre a insulina após a alimentação do animal.\n';
    rec +=
        '• Mantenha horários consistentes tanto para alimentação quanto para aplicação.\n';
    rec +=
        '• Consulte um veterinário regularmente para ajustar o tratamento.\n';
    rec +=
        '• Mantenha um registro diário dos níveis de glicemia e doses administradas.\n';

    _model.recomendacao = rec;
  }

  // Métodos para atualizar o estado do modelo
  void atualizarEspecie(String? value) {
    _model.especieSelecionada = value;
    notifyListeners();
  }

  void atualizarTipoInsulina(String? value) {
    _model.tipoInsulinaSelecionada = value;
    notifyListeners();
  }

  void atualizarTemDoseAnterior(bool value) {
    _model.temDoseAnterior = value;
    if (!value) {
      _model.dosagemAnteriorController.clear();
    }
    notifyListeners();
  }

  void atualizarUsarRegra(bool value) {
    _model.usarRegra = value;
    if (!value) {
      _model.dosagemInsulinaController.clear();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
