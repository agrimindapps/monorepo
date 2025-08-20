class QuebraDormenciaRepository {
  static final Map<String, Map<String, num>> requisitoHorasFrio = {
    'Maçã': {
      'Gala': 600,
      'Fuji': 700,
      'Golden Delicious': 500,
      'Eva': 300,
      'Anna': 250,
    },
    'Pêra': {
      'Williams': 700,
      'Packham\'s': 800,
      'Housui': 500,
      'Kousui': 450,
    },
    'Pêssego': {
      'Chimarrita': 200,
      'Douradão': 150,
      'Diamante': 100,
      'Granada': 300,
    },
    'Ameixa': {
      'Reubennel': 300,
      'Santa Rosa': 400,
      'Letícia': 500,
      'Gulfblaze': 200,
    },
    'Nectarina': {
      'Sunraycer': 250,
      'Sunripe': 300,
      'Sunblaze': 350,
      'Sungold': 400,
    },
    'Kiwi': {
      'Bruno': 700,
      'Hayward': 800,
      'Monty': 700,
      'Golden': 600,
    },
    'Uva': {
      'Cabernet Sauvignon': 400,
      'Merlot': 350,
      'Chardonnay': 300,
      'Sauvignon Blanc': 250,
    },
  };

  static final Map<String, Map<String, dynamic>> recomendacoesPorDeficit = {
    'pequeno': {
      'faixa': [0, 100],
      'recomendacao': 'Tratamento leve com óleo mineral',
      'produtos': {
        'Óleo mineral': '3-4%',
      },
      'custoEstimado': 200,
    },
    'moderado': {
      'faixa': [100, 300],
      'recomendacao': 'Tratamento moderado com óleo mineral + cianamida',
      'produtos': {
        'Óleo mineral': '3-4%',
        'Cianamida hidrogenada': '0.5-0.8%',
        'Espalhante adesivo': '0.05%',
      },
      'custoEstimado': 450,
    },
    'alto': {
      'faixa': [300, 500],
      'recomendacao': 'Tratamento intensivo com óleo mineral + cianamida',
      'produtos': {
        'Óleo mineral': '4-5%',
        'Cianamida hidrogenada': '1.0-1.5%',
        'Espalhante adesivo': '0.1%',
      },
      'custoEstimado': 700,
    },
    'severo': {
      'faixa': [500, 999999],
      'recomendacao': 'Tratamento intensivo com aplicações complementares',
      'produtos': {
        'Óleo mineral': '5%',
        'Cianamida hidrogenada': '1.5-2.0%',
        'Espalhante adesivo': '0.1%',
        'Thidiazuron (TDZ)': '100-200 ppm',
      },
      'custoEstimado': 950,
    },
  };

  static List<String> getEspecies() {
    return requisitoHorasFrio.keys.toList();
  }

  static List<String> getVariedades(String especie) {
    return requisitoHorasFrio[especie]?.keys.toList() ?? [];
  }

  static num getRequisitoHorasFrio(String especie, String variedade) {
    return requisitoHorasFrio[especie]?[variedade] ?? 0;
  }

  static Map<String, dynamic> getRecomendacao(num deficitHorasFrio) {
    String nivel = 'pequeno';
    for (var entry in recomendacoesPorDeficit.entries) {
      var faixa = entry.value['faixa'] as List;
      if (deficitHorasFrio >= faixa[0] && deficitHorasFrio <= faixa[1]) {
        nivel = entry.key;
        break;
      }
    }
    return recomendacoesPorDeficit[nivel] ??
        recomendacoesPorDeficit['pequeno']!;
  }
}
