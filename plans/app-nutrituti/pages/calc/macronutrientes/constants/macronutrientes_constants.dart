class MacronutrientesConstants {
  // Informações de valores calóricos para cada macronutriente
  static const Map<String, int> caloriasPorGrama = {
    'carboidratos': 4,
    'proteinas': 4,
    'gorduras': 9,
  };

  // Distribuições predefinidas
  static const List<Map<String, dynamic>> distribuicoesPredefinidas = [
    {
      'id': 1,
      'text': 'Baixo Carboidrato',
      'carbs': 20,
      'protein': 40,
      'fat': 40
    },
    {'id': 2, 'text': 'Cetogênico', 'carbs': 5, 'protein': 25, 'fat': 70},
    {'id': 3, 'text': 'Equilibrado', 'carbs': 50, 'protein': 25, 'fat': 25},
    {'id': 4, 'text': 'Alta Proteína', 'carbs': 40, 'protein': 40, 'fat': 20},
    {
      'id': 5,
      'text': 'Alto Carboidrato',
      'carbs': 60,
      'protein': 25,
      'fat': 15
    },
    {'id': 6, 'text': 'Personalizado', 'carbs': 50, 'protein': 25, 'fat': 25},
  ];

  // Valores mínimos e máximos recomendados
  static const double caloriasMin = 800;
  static const double caloriasMax = 5000;
  static const int porcentagemMin = 0;
  static const int porcentagemMax = 100;
}
