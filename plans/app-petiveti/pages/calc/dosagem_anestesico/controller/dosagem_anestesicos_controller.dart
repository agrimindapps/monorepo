// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/dosagem_anestesicos_model.dart';

class DosagemAnestesicosController extends ChangeNotifier {
  final model = DosagemAnestesicosModel();
  final formKey = GlobalKey<FormState>();

  // Getters para acesso aos estados
  bool get showInfoCard => model.showInfoCard;
  bool get showAlertaCard => model.showAlertaCard;
  String? get especieSelecionada => model.especieSelecionada;
  String? get anestesicoSelecionado => model.anestesicoSelecionado;
  String? get resultado => model.resultado;
  double? get dosagem => model.dosagem;

  // Controlador de texto para o campo de peso
  final pesoController = TextEditingController();

  // Métodos de controle de visibilidade
  void toggleInfoCard() {
    model.showInfoCard = !model.showInfoCard;
    notifyListeners();
  }

  void toggleAlertaCard() {
    model.showAlertaCard = !model.showAlertaCard;
    notifyListeners();
  }

  // Métodos de atualização de dados
  void setEspecie(String? value) {
    if (value != model.especieSelecionada) {
      model.especieSelecionada = value;
      model.anestesicoSelecionado = null;
      model.resultado = null;
      model.dosagem = null;
      notifyListeners();
    }
  }

  void setAnestesico(String? value) {
    if (value != model.anestesicoSelecionado) {
      model.anestesicoSelecionado = value;
      notifyListeners();
    }
  }

  // Validações
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value.replaceAll(',', '.')) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  // Cálculos
  void calcular() {
    if (!formKey.currentState!.validate()) return;

    final peso = double.parse(pesoController.text.replaceAll(',', '.'));

    // Obter faixa de dosagem para o anestésico selecionado
    final dosagens = model
        .anestesicos[model.especieSelecionada]![model.anestesicoSelecionado]!;
    final minDosagem = dosagens[0];
    final maxDosagem = dosagens[1];

    // Usar a dosagem média para cálculos
    final mediaDosagem = (minDosagem + maxDosagem) / 2;

    // Calcular quantidade total de medicamento em mg
    final quantidadeMg = mediaDosagem * peso;

    // Calcular volume em ml com base na concentração do medicamento
    final concentracao = model.concentracoes[model.anestesicoSelecionado]!;
    final volumeMl = quantidadeMg / concentracao;

    model.dosagem = volumeMl;
    model.resultado = 'Anestésico: ${model.anestesicoSelecionado}\n'
        'Dosagem recomendada: $minDosagem - $maxDosagem mg/kg\n'
        'Peso do animal: $peso kg\n\n'
        'Volume a administrar: ${volumeMl.toStringAsFixed(2)} ml\n'
        '(Equivalente a ${quantidadeMg.toStringAsFixed(2)} mg de medicamento)';

    notifyListeners();
  }

  // Compartilhamento
  void compartilhar() {
    if (model.resultado == null || model.anestesicoSelecionado == null) return;

    final buffer = StringBuffer();
    buffer.writeln('Calculadora de Dosagem de Anestésicos');
    buffer.writeln();
    buffer.writeln('Espécie: ${model.especieSelecionada}');
    buffer.writeln('Anestésico: ${model.anestesicoSelecionado}');
    buffer.writeln('Peso do animal: ${pesoController.text} kg');
    buffer.writeln();
    buffer.writeln('Resultados:');
    buffer.writeln(model.resultado);
    buffer.writeln();
    buffer.writeln('Informações sobre ${model.anestesicoSelecionado}:');
    buffer.writeln('${model.descricoes[model.anestesicoSelecionado]}');
    buffer.writeln();
    buffer.writeln('Advertências e Contraindicações:');
    buffer.writeln('${model.advertencias[model.anestesicoSelecionado]}');
    buffer.writeln();
    buffer.writeln('Notas importantes:');
    buffer.writeln(
        '• A administração deve ser realizada lentamente e com monitoramento constante.');
    buffer.writeln(
        '• Tenha sempre medicamentos de reversão e equipamentos de emergência disponíveis.');
    buffer.writeln(
        '• Realize exames pré-anestésicos para garantir a segurança do procedimento.');
    buffer.writeln(
        '• Ajuste a dose conforme o estado físico, idade e condições pré-existentes do paciente.');

    Share.share(buffer.toString());
  }

  // Limpeza
  void limpar() {
    pesoController.clear();
    model.limpar();
    notifyListeners();
  }

  @override
  void dispose() {
    pesoController.dispose();
    super.dispose();
  }
}
