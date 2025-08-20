// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/medicamento_detalhes_model.dart';

class ListaMedicamentoDetalhesController extends ChangeNotifier {
  double _textScaleFactor = 1.0;
  MedicamentoDetalhes? _medicamento;
  final TextEditingController _pesoController = TextEditingController();
  String _resultadoDosagem = '';

  double get textScaleFactor => _textScaleFactor;
  MedicamentoDetalhes? get medicamento => _medicamento;
  TextEditingController get pesoController => _pesoController;
  String get resultadoDosagem => _resultadoDosagem;

  void inicializarMedicamento(Object? arguments) {
    if (arguments != null && arguments is Map<String, String>) {
      _medicamento = MedicamentoDetalhes.fromMap(arguments);
      notifyListeners();
    }
  }

  void aumentarTexto() {
    if (_textScaleFactor < 1.5) {
      _textScaleFactor += 0.1;
      notifyListeners();
    }
  }

  void diminuirTexto() {
    if (_textScaleFactor > 0.8) {
      _textScaleFactor -= 0.1;
      notifyListeners();
    }
  }

  void calcularDosagem() {
    final peso = double.tryParse(_pesoController.text);
    if (peso == null || peso <= 0) {
      _resultadoDosagem = 'Por favor, insira um peso válido.';
      notifyListeners();
      return;
    }

    // Exemplo de cálculo básico - deveria ser baseado em dados reais
    double dosagem = 0;
    String unidade = '';

    switch (_medicamento?.tipo) {
      case 'Antibiótico':
        dosagem = peso * 10; // 10mg/kg exemplo
        unidade = 'mg';
        break;
      case 'Analgésico':
        dosagem = peso * 5; // 5mg/kg exemplo
        unidade = 'mg';
        break;
      case 'Anti-inflamatório':
        dosagem = peso * 2; // 2mg/kg exemplo
        unidade = 'mg';
        break;
      default:
        _resultadoDosagem = 'Cálculo não disponível para este tipo de medicamento.';
        notifyListeners();
        return;
    }

    _resultadoDosagem = 'Dosagem sugerida: ${dosagem.toStringAsFixed(1)} $unidade';
    notifyListeners();
  }

  void compartilhar(BuildContext context) {
    // Implementar lógica de compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de compartilhamento em desenvolvimento')),
    );
  }

  void imprimir(BuildContext context) {
    // Implementar lógica de impressão
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de impressão em desenvolvimento')),
    );
  }

  void salvarComoFavorito(BuildContext context) {
    // Implementar lógica para salvar como favorito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicamento salvo como favorito')),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }
}
