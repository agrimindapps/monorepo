// Dart imports:
import 'dart:math' as math;

/// Modelo de dados para a calculadora de peso ideal por condição corporal
class PesoIdealModel {
  String? especieSelecionada;
  String? racaSelecionada;
  String? sexoSelecionado;
  bool esterilizado = false;
  int? idadeAnos;
  double? escalaECCSelecionada;
  double? pesoAtual;
  double? pesoIdeal;
  double? diferencaPeso;
  double? kcalAjustadas;
  int? tempoEstimadoSemanas;
  bool showInfoCard = true;

  // Mapa de raças por espécie
  final Map<String, List<String>> racasPorEspecie = {
    'Cão': [
      'Sem raça definida',
      'Border Collie',
      'Boxer',
      'Bulldog Francês',
      'Chihuahua',
      'Dachshund',
      'Golden Retriever',
      'Labrador',
      'Pastor Alemão',
      'Pinscher',
      'Poodle',
      'Pug',
      'Rottweiler',
      'Shih Tzu',
      'Yorkshire',
      'Outro porte pequeno (<10kg)',
      'Outro porte médio (10-25kg)',
      'Outro porte grande (>25kg)',
    ],
    'Gato': [
      'Sem raça definida',
      'Persa',
      'Siamês',
      'Maine Coon',
      'Bengal',
      'Ragdoll',
      'British Shorthair',
      'Sphynx',
      'Outro',
    ],
  };

  // Peso ideal médio por raça (kg)
  final Map<String, Map<String, Map<String, double>>> pesoIdealPorRaca = {
    'Cão': {
      'macho': {
        'Outro porte grande (>25kg)': 32.0,
      },
      'fêmea': {
        'Outro porte grande (>25kg)': 28.0,
      },
    },
    'Gato': {
      'macho': {
        'Outro': 4.5,
      },
      'fêmea': {
        'Outro': 3.5,
      },
    },
  };

  // Fatores de conversão por ECC (1-9)
  final Map<double, double> fatoresConversaoECC = {
    1.0: 1.43,
    2.0: 1.25,
    3.0: 1.15,
    4.0: 1.05,
    5.0: 1.00,
    6.0: 0.90,
    7.0: 0.80,
    8.0: 0.70,
    9.0: 0.60,
  };

  // Descrições das condições corporais
  final Map<double, Map<String, String>> descricaoECC = {
    1.0: {
      'titulo': 'Caquético',
      'descricao':
          'Costelas, vértebras lombares, ossos pélvicos e todas as saliências ósseas visíveis à distância. Ausência de gordura corporal discernível. Perda evidente de massa muscular.',
    },
    2.0: {
      'titulo': 'Muito Magro',
      'descricao':
          'Costelas, vértebras lombares e ossos pélvicos facilmente visíveis. Ausência de gordura palpável. Algumas saliências ósseas visíveis à distância. Perda mínima de massa muscular.',
    },
    3.0: {
      'titulo': 'Magro',
      'descricao':
          'Costelas facilmente palpáveis e podem ser visíveis sem gordura palpável. Topo das vértebras lombares visível. Ossos pélvicos começando a ficar proeminentes. Cintura e reentrância abdominal evidentes.',
    },
    4.0: {
      'titulo': 'Levemente Magro',
      'descricao':
          'Costelas facilmente palpáveis com mínima cobertura de gordura. Cintura facilmente observada, vista de cima. Reentrância abdominal evidente.',
    },
    5.0: {
      'titulo': 'Ideal',
      'descricao':
          'Costelas palpáveis sem excesso de cobertura de gordura. Cintura observada atrás das costelas quando vista de cima. Abdômen retraído quando visto de lado.',
    },
    6.0: {
      'titulo': 'Levemente acima do peso',
      'descricao':
          'Costelas palpáveis com leve excesso de cobertura de gordura. Cintura é visível de cima, mas não acentuada. Reentrância abdominal aparente.',
    },
    7.0: {
      'titulo': 'Acima do peso',
      'descricao':
          'Costelas palpáveis com dificuldade; pesada cobertura de gordura. Depósitos de gordura visíveis sobre a área lombar e base da cauda. Cintura ausente ou pouco visível. Reentrância abdominal pode estar ausente.',
    },
    8.0: {
      'titulo': 'Obeso',
      'descricao':
          'Costelas não palpáveis sob cobertura muito espessa de gordura, ou palpáveis somente com pressão significativa. Grandes depósitos de gordura sobre área lombar e base da cauda. Cintura ausente. Nenhuma reentrância abdominal. Pode haver distensão abdominal evidente.',
    },
    9.0: {
      'titulo': 'Obeso mórbido',
      'descricao':
          'Maciços depósitos de gordura sobre tórax, espinha e base da cauda. Cintura e reentrância abdominal ausentes. Depósitos de gordura no pescoço e membros. Distensão abdominal evidente.',
    },
  };

  // Manutenção calórica diária estimada (kcal/dia)
  final Map<String, double> kcalPorKgPesoMetabolico = {
    'Cão': 132.0,
    'Gato': 100.0,
  };

  /// Limpa os dados do modelo
  void limpar() {
    especieSelecionada = null;
    racaSelecionada = null;
    sexoSelecionado = null;
    esterilizado = false;
    idadeAnos = null;
    escalaECCSelecionada = null;
    pesoAtual = null;
    pesoIdeal = null;
    diferencaPeso = null;
    kcalAjustadas = null;
    tempoEstimadoSemanas = null;
  }

  /// Calcula o peso metabólico
  double calcularPesoMetabolico(double pesoKg) {
    return math.pow(pesoKg, 0.75).toDouble();
  }
}
