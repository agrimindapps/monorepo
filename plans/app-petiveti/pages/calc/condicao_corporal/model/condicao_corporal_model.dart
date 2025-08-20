
class CondicaoCorporalModel {
  String? especieSelecionada;
  int? indiceSelecionado;
  String? resultado;
  bool showInfoCard = true;

  final List<String> especies = ['Cão', 'Gato'];

  final Map<String, List<String>> indices = {
    'Cão': ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
    'Gato': ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
  };

  final Map<String, Map<String, String>> descricoes = {
    'Cão': {
      '1':
          'Caquético - Costelas, vértebras lombares, ossos pélvicos e todas as proeminências ósseas evidentes à distância. Sem gordura corporal perceptível. Perda evidente de massa muscular.',
      '2':
          'Muito magro - Costelas, vértebras lombares e ossos pélvicos facilmente visíveis. Cintura acentuada vista de cima. Curvatura abdominal acentuada. Mínima massa muscular.',
      '3':
          'Magro - Costelas facilmente palpáveis, podem ser visíveis sem gordura palpável. Topo das vértebras lombares visível. Ossos pélvicos começando a ficar proeminentes. Cintura óbvia e curvatura abdominal pronunciada.',
      '4':
          'Abaixo do ideal - Costelas facilmente palpáveis com mínima cobertura de gordura. Cintura facilmente observada, vista de cima. Curvatura abdominal evidente.',
      '5':
          'Ideal - Costelas palpáveis sem excesso de cobertura de gordura. Cintura observada atrás das costelas, quando vista de cima. Abdômen retraído quando visto de lado.',
      '6':
          'Sobrepeso leve - Costelas palpáveis com leve excesso de cobertura de gordura. Cintura é visível, vista de cima, mas não é acentuada. Curvatura abdominal aparente.',
      '7':
          'Sobrepeso - Costelas palpáveis com dificuldade; cobertura de gordura pesada. Depósitos de gordura notáveis sobre a área lombar e base da cauda. Cintura ausente ou pouco visível. Pode haver curvatura abdominal.',
      '8':
          'Obeso - Costelas não palpáveis sob cobertura muito espessa de gordura ou palpáveis somente com pressão significativa. Depósitos pesados de gordura sobre a área lombar e base da cauda. Cintura ausente. Sem curvatura abdominal. Pode haver distensão abdominal evidente.',
      '9':
          'Obesidade mórbida - Depósitos maciços de gordura sobre o tórax, coluna e base da cauda. Cintura e curvatura abdominal ausentes. Depósitos de gordura no pescoço e membros. Distensão abdominal óbvia.',
    },
    'Gato': {
      '1':
          'Caquético - Costelas, vértebras lombares, ossos pélvicos e todas as proeminências ósseas evidentes à distância. Sem gordura corporal perceptível. Perda evidente de massa muscular. Abdômen severamente retraído.',
      '2':
          'Muito magro - Costelas, vértebras lombares e ossos pélvicos facilmente visíveis, especialmente em gatos de pelo curto. Ausência de gordura palpável. Cintura extremamente acentuada. Abdômen retraído.',
      '3':
          'Magro - Costelas visíveis, vértebras lombares e ossos pélvicos facilmente palpáveis. Cintura bem definida. Gordura abdominal mínima.',
      '4':
          'Abaixo do ideal - Costelas facilmente palpáveis com mínima cobertura de gordura. Cintura bem definida. Pequena quantidade de gordura abdominal.',
      '5':
          'Ideal - Bem proporcionado. Cintura observável atrás das costelas. Costelas palpáveis com leve cobertura de gordura. Mínima gordura abdominal.',
      '6':
          'Sobrepeso leve - Costelas palpáveis com moderada cobertura de gordura. Cintura e gordura abdominal visíveis mas não óbvias.',
      '7':
          'Sobrepeso - Costelas difíceis de palpar. Cintura pouco visível. Gordura abdominal óbvia. Depósitos de gordura lombar moderados.',
      '8':
          'Obeso - Costelas não palpáveis com excesso de cobertura de gordura. Cintura ausente. Abdômen arredondado. Depósitos de gordura lombar óbvios.',
      '9':
          'Obesidade mórbida - Depósitos maciços de gordura no tórax, coluna, abdômen e membros. Distensão abdominal óbvia.',
    },
  };

  final Map<String, String> classificacoes = {
    '1': 'Subnutrição severa',
    '2': 'Subnutrição',
    '3': 'Magro',
    '4': 'Abaixo do peso ideal',
    '5': 'Peso ideal',
    '6': 'Sobrepeso leve',
    '7': 'Sobrepeso',
    '8': 'Obesidade',
    '9': 'Obesidade mórbida',
  };

  final Map<String, String> recomendacoes = {
    'baixo':
        'Consulte um veterinário imediatamente. Seu animal está severamente abaixo do peso ideal e pode ter problemas de saúde subjacentes que precisam ser abordados. Será necessário um plano de alimentação supervisionado para ganho de peso gradual.',
    'ideal':
        'Parabéns! Seu animal está com o peso ideal. Continue com a mesma alimentação e nível de atividade física para manter esta condição saudável.',
    'alto':
        'Consulte um veterinário para desenvolver um plano de perda de peso seguro. O excesso de peso pode causar diversos problemas de saúde. Será necessário ajustar a dieta e aumentar o nível de atividade física gradualmente.',
  };

  void limpar() {
    especieSelecionada = null;
    indiceSelecionado = null;
    resultado = null;
  }

  void atualizarEspecie(String? especie) {
    especieSelecionada = especie;
    indiceSelecionado = null;
    resultado = null;
  }

  void toggleInfoCard() {
    showInfoCard = !showInfoCard;
  }
}
