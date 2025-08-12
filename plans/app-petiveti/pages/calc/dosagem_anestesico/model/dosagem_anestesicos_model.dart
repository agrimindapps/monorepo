class DosagemAnestesicosModel {
  String? especieSelecionada;
  String? anestesicoSelecionado;
  String? resultado;
  double? dosagem;
  bool showInfoCard = true;
  bool showAlertaCard = true;

  // Opções para os dropdowns
  final List<String> especies = ['Cão', 'Gato'];

  // Anestésicos e suas dosagens por espécie (mg/kg)
  final Map<String, Map<String, List<double>>> anestesicos = {
    'Cão': {
      'Propofol': [4.0, 6.0],
      'Ketamina': [5.0, 10.0],
      'Buprenorfina': [0.01, 0.02],
    },
    'Gato': {
      'Buprenorfina': [0.01, 0.02],
    },
  };

  // Concentrações padrão dos anestésicos (mg/ml)
  final Map<String, double> concentracoes = {
    'Propofol': 10.0,
    'Ketamina': 100.0,
    'Midazolam': 5.0,
    'Xilazina': 20.0,
    'Acepromazina': 10.0,
    'Dexmedetomidina': 0.5,
    'Butorfanol': 10.0,
    'Atropina': 0.5,
    'Diazepam': 5.0,
    'Buprenorfina': 0.3,
  };

  // Descrições dos anestésicos
  final Map<String, String> descricoes = {
    'Propofol':
        'Anestésico intravenoso de ação ultra-curta, utilizado para indução e manutenção de anestesia.',
    'Ketamina':
        'Anestésico dissociativo usado para anestesia e analgesia. Frequentemente usado em combinação com outros medicamentos.',
    'Midazolam':
        'Benzodiazepínico utilizado como sedativo, relaxante muscular e anticonvulsivante.',
    'Xilazina':
        'Sedativo, analgésico e relaxante muscular usado frequentemente em combinação com outros anestésicos.',
    'Acepromazina':
        'Tranquilizante frequentemente usado como pré-anestésico para acalmar o animal.',
    'Dexmedetomidina': 'Sedativo potente que também proporciona analgesia.',
    'Butorfanol': 'Analgésico opioide usado para controle da dor e sedação.',
    'Atropina':
        'Anticolinérgico usado para prevenir ou tratar bradicardia e secreções excessivas durante anestesia.',
    'Diazepam':
        'Benzodiazepínico usado como tranquilizante, relaxante muscular e anticonvulsivante.',
    'Buprenorfina':
        'Analgésico opioide potente usado para controle da dor moderada a severa.',
  };

  // Advertências específicas para cada anestésico
  final Map<String, String> advertencias = {
    'Propofol':
        'Não usar em animais com hipersensibilidade, hipotensão severa ou compromisso cardiovascular significativo.',
    'Ketamina':
        'Contraindicado em animais com hipertensão, problemas cardíacos, glaucoma, trauma craniano ou hipertensão intracraniana.',
    'Midazolam':
        'Usar com cautela em animais debilitados, geriatricos ou com comprometimento hepático ou renal.',
    'Xilazina':
        'Não recomendado para animais diabéticos, com doença cardíaca ou respiratória, ou em gestação avançada.',
    'Acepromazina':
        'Contraindicado em animais hipotensos, epilépticos, hipovolêmicos ou com doenças hepáticas significativas.',
    'Dexmedetomidina':
        'Não recomendado para animais com doença cardiovascular ou comprometimento hepático ou renal severo.',
    'Butorfanol':
        'Usar com cautela em animais com trauma craniano, aumento da pressão intracraniana ou comprometimento hepático ou renal.',
    'Atropina':
        'Usar com cautela em animais com glaucoma, taquicardia, hipertensão ou hipertireoidismo.',
    'Diazepam':
        'Usar com cautela em animais com disfunção hepática, insuficiência renal ou animais muito debilitados.',
    'Buprenorfina':
        'Monitorar atentamente a função respiratória. Pode causar sedação prolongada em alguns animais.',
  };

  void limpar() {
    especieSelecionada = null;
    anestesicoSelecionado = null;
    resultado = null;
    dosagem = null;
  }
}
