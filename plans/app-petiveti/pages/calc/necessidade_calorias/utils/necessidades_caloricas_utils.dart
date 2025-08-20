class NecessidadesCaloricas_Utils {
  static const List<String> especies = ['Cão', 'Gato'];

  static const Map<String, List<String>> estadosFisiologicos = {
    'Cão': ['Filhote', 'Adulto', 'Idoso', 'Gestante', 'Lactante', 'Castrado'],
    'Gato': ['Filhote', 'Adulto', 'Idoso', 'Gestante', 'Lactante', 'Castrado'],
  };

  static const Map<String, List<String>> niveisAtividade = {
    'Cão': [
      'Sedentário',
      'Pouco ativo',
      'Moderadamente ativo',
      'Muito ativo',
      'Atleta'
    ],
    'Gato': ['Sedentário', 'Ativo', 'Muito ativo'],
  };

  static const Map<String, Map<String, double>> fatoresBase = {
    'Cão': {
      'Filhote': 3.0,
      'Adulto': 1.6,
      'Idoso': 1.4,
      'Gestante': 3.0,
      'Lactante': 4.0,
      'Castrado': 1.4,
    },
    'Gato': {
      'Filhote': 2.5,
      'Adulto': 1.2,
      'Idoso': 1.1,
      'Gestante': 2.0,
      'Lactante': 3.0,
      'Castrado': 1.0,
    },
  };

  static const Map<String, Map<String, double>> fatoresAtividade = {
    'Cão': {
      'Sedentário': 1.0,
      'Pouco ativo': 1.2,
      'Moderadamente ativo': 1.4,
      'Muito ativo': 1.6,
      'Atleta': 2.0,
    },
    'Gato': {
      'Sedentário': 1.0,
      'Ativo': 1.2,
      'Muito ativo': 1.4,
    },
  };

  static String? validateNumber(String? value) {
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
}
