// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/idade_animal_model.dart';

class IdadeAnimalController extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _idadeController = TextEditingController();
  final _model = IdadeAnimalModel();

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get idadeController => _idadeController;
  IdadeAnimalModel get model => _model;

  @override
  void dispose() {
    _idadeController.dispose();
    super.dispose();
  }

  void atualizarEspecie(String? especie) {
    _model.especieSelecionada = especie;
    if (especie != 'Cão') {
      _model.porteCanino = null;
    }
    _model.resultado = null;
    notifyListeners();
  }

  void atualizarPorte(String? porte) {
    _model.porteCanino = porte;
    _model.resultado = null;
    notifyListeners();
  }

  void limpar() {
    _idadeController.clear();
    _model.limpar();
    notifyListeners();
  }

  void calcular() {
    if (!_formKey.currentState!.validate()) return;

    final idadeAnimal = int.parse(_idadeController.text);

    if (_model.especieSelecionada == 'Cão') {
      _calcularIdadeCao(idadeAnimal);
    } else if (_model.especieSelecionada == 'Gato') {
      _calcularIdadeGato(idadeAnimal);
    }

    notifyListeners();
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Digite um número inteiro válido';
    }

    if (intValue <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  void _calcularIdadeCao(int idadeAnimal) {
    int idadeHumana;
    String faseVida;
    String porte = _model.porteCanino!;

    if (idadeAnimal == 1) {
      if (porte.startsWith('Pequeno')) {
        idadeHumana = 15;
      } else if (porte.startsWith('Médio')) {
        idadeHumana = 15;
      } else if (porte.startsWith('Grande')) {
        idadeHumana = 14;
      } else {
        idadeHumana = 12;
      }
      faseVida = 'Adolescente';
    } else if (idadeAnimal == 2) {
      if (porte.startsWith('Pequeno')) {
        idadeHumana = 24;
      } else if (porte.startsWith('Médio')) {
        idadeHumana = 24;
      } else if (porte.startsWith('Grande')) {
        idadeHumana = 22;
      } else {
        idadeHumana = 19;
      }
      faseVida = 'Jovem adulto';
    } else {
      int idadeBase;
      int fatorPorAno;

      if (porte.startsWith('Pequeno')) {
        idadeBase = 24;
        fatorPorAno = 4;
      } else if (porte.startsWith('Médio')) {
        idadeBase = 24;
        fatorPorAno = 5;
      } else if (porte.startsWith('Grande')) {
        idadeBase = 22;
        fatorPorAno = 6;
      } else {
        idadeBase = 19;
        fatorPorAno = 7;
      }

      idadeHumana = idadeBase + (idadeAnimal - 2) * fatorPorAno;

      if (porte.startsWith('Pequeno')) {
        if (idadeAnimal < 7) {
          faseVida = 'Adulto';
        } else if (idadeAnimal < 12) {
          faseVida = 'Adulto maduro';
        } else {
          faseVida = 'Idoso';
        }
      } else if (porte.startsWith('Médio')) {
        if (idadeAnimal < 6) {
          faseVida = 'Adulto';
        } else if (idadeAnimal < 10) {
          faseVida = 'Adulto maduro';
        } else {
          faseVida = 'Idoso';
        }
      } else {
        if (idadeAnimal < 5) {
          faseVida = 'Adulto';
        } else if (idadeAnimal < 8) {
          faseVida = 'Adulto maduro';
        } else {
          faseVida = 'Idoso';
        }
      }
    }

    _model.resultado =
        'A idade de $idadeAnimal anos para um cão de porte $porte '
        'equivale aproximadamente a $idadeHumana anos humanos.\n\n'
        'Fase da vida: $faseVida';
  }

  void _calcularIdadeGato(int idadeAnimal) {
    int idadeHumana;
    String faseVida;

    if (idadeAnimal == 1) {
      idadeHumana = 15;
      faseVida = 'Adolescente';
    } else if (idadeAnimal == 2) {
      idadeHumana = 24;
      faseVida = 'Jovem adulto';
    } else {
      idadeHumana = 24 + (idadeAnimal - 2) * 4;

      if (idadeAnimal < 7) {
        faseVida = 'Adulto';
      } else if (idadeAnimal < 10) {
        faseVida = 'Adulto maduro';
      } else if (idadeAnimal < 15) {
        faseVida = 'Idoso';
      } else {
        faseVida = 'Idoso avançado';
      }
    }

    _model.resultado = 'A idade de $idadeAnimal anos para um gato '
        'equivale aproximadamente a $idadeHumana anos humanos.\n\n'
        'Fase da vida: $faseVida';
  }

  String gerarDicasFaseVida() {
    if (_model.resultado == null) return '';

    String dicas = '';

    if (_model.resultado!.contains('Filhote')) {
      dicas = 'Dicas para esta fase:\n'
          '• Vacinação completa\n'
          '• Socialização adequada\n'
          '• Treinamento básico\n'
          '• Alimentação específica para filhotes';
    } else if (_model.resultado!.contains('Adolescente') ||
        _model.resultado!.contains('Jovem adulto')) {
      dicas = 'Dicas para esta fase:\n'
          '• Check-ups veterinários anuais\n'
          '• Exercícios regulares\n'
          '• Treinamento contínuo\n'
          '• Alimentação balanceada';
    } else if (_model.resultado!.contains('Adulto')) {
      dicas = 'Dicas para esta fase:\n'
          '• Check-ups veterinários anuais\n'
          '• Manter peso adequado\n'
          '• Exercícios regulares\n'
          '• Cuidados dentários';
    } else if (_model.resultado!.contains('maduro')) {
      dicas = 'Dicas para esta fase:\n'
          '• Check-ups veterinários a cada 6 meses\n'
          '• Atenção à dieta\n'
          '• Exercícios moderados\n'
          '• Monitoramento de problemas de saúde';
    } else if (_model.resultado!.contains('Idoso')) {
      dicas = 'Dicas para esta fase:\n'
          '• Check-ups veterinários frequentes\n'
          '• Dieta específica para idosos\n'
          '• Exercícios leves\n'
          '• Atenção especial ao conforto';
    }

    return dicas;
  }
}
