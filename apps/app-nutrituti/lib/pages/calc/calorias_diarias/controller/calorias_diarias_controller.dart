// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/calorias_diarias_model.dart';

class CaloriasDiariasController extends ChangeNotifier {
  final CaloriasDiariasModel model;
  final idadeController = TextEditingController();
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();

  // Constantes para gêneros
  static final List<Map<String, dynamic>> generos = [
    {
      'id': 1,
      'text': 'Masculino',
      'fator': 66,
      'KQuilos': 13.7,
      'KIdade': 5.0,
      'KAltura': 6.8
    },
    {
      'id': 2,
      'text': 'Feminino',
      'fator': 65.5,
      'KQuilos': 9.6,
      'KIdade': 1.8,
      'KAltura': 4.7
    }
  ];

  // Constantes para níveis de atividade
  static final List<Map<String, dynamic>> atividades = [
    {'id': 1, 'value': 1.25, 'text': 'Sedentario'},
    {'id': 2, 'value': 1.3, 'text': 'Levemente Ativo'},
    {'id': 3, 'value': 1.5, 'text': 'Moderadamente Ativo'},
    {'id': 4, 'value': 1.7, 'text': 'Muito Ativo'},
    {'id': 5, 'value': 2, 'text': 'Extremamente Ativo'}
  ];

  CaloriasDiariasController() : model = CaloriasDiariasModel.empty();

  void setGenero(int id) {
    final genero = generos.firstWhere((g) => g['id'] == id);
    model.generoSelecionado = id;
    model.generoText = genero['text'] as String; // FASE 0.7: Type cast
    model.generoData = genero;
    notifyListeners();
  }

  void setAtividade(int id) {
    final atividade = atividades.firstWhere((a) => a['id'] == id);
    model.atividadeSelecionada = id;
    model.atividadeText = atividade['text'] as String; // FASE 0.7: Type cast
    model.atividadeFator = atividade['value'] as double; // FASE 0.7: Type cast
    notifyListeners();
  }

  bool calcular(BuildContext context) {
    if (idadeController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a idade.');
      return false;
    }

    if (alturaController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a altura.');
      return false;
    }

    if (pesoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar o peso.');
      return false;
    }

    try {
      final idade = int.parse(idadeController.text);
      final altura = double.parse(alturaController.text.replaceAll(',', '.'));
      final peso = double.parse(pesoController.text.replaceAll(',', '.'));

      model.idade = idade;
      model.altura = altura;
      model.peso = peso;

      model.resultado = _calcularCalorias(
        model.generoData,
        {
          'id': model.atividadeSelecionada,
          'value': model.atividadeFator,
          'text': model.atividadeText
        },
        idade,
        altura,
        peso,
      );

      _exibirMensagem(context, 'Cálculo realizado com sucesso!',
          isError: false);
      notifyListeners();
      return true;
    } catch (e) {
      _exibirMensagem(
          context, 'Erro ao calcular. Verifique os valores informados.');
      return false;
    }
  }

  int _calcularCalorias(
      Map<String, dynamic> generoDef,
      Map<String, dynamic> atividadeDef,
      int idade,
      double altura,
      double peso) {
    // FASE 0.7: Type casts para resolver analyzer errors
    final t1 = ((generoDef['KIdade'] as num) * idade);
    final t2 = ((generoDef['KAltura'] as num) * altura * 100);
    final t3 = ((generoDef['KQuilos'] as num) * peso);
    final t4 = ((generoDef['fator'] as num) + t3 + t2 - t1) * (atividadeDef['value'] as num);
    return t4.round();
  }

  void limpar() {
    model.limpar();
    idadeController.clear();
    alturaController.clear();
    pesoController.clear();
    notifyListeners();
  }

  void compartilhar() {
    final texto = _gerarTextoCompartilhamento();
    Share.share(texto);
  }

  String _gerarTextoCompartilhamento() {
    StringBuffer t = StringBuffer();
    t.writeln('Calorias Diárias');
    t.writeln();
    t.writeln('Valores');
    t.writeln('Gênero: ${model.generoText}');
    t.writeln('Idade: ${model.idade} Anos');
    t.writeln('Altura: ${model.altura} Metros');
    t.writeln('Peso: ${model.peso} Kgs');
    t.writeln('Atividade: ${model.atividadeText}');
    t.writeln();
    t.writeln('Resultados');
    t.writeln('Consumo: ${model.resultado} Kcal diárias');
    t.writeln();
    t.writeln(
        'Importante: Esta é uma estimativa. Consulte um profissional de saúde para recomendações personalizadas.');
    return t.toString();
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
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  @override
  void dispose() {
    idadeController.dispose();
    alturaController.dispose();
    pesoController.dispose();
    super.dispose();
  }
}
