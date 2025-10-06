import '../../domain/entities/medication_data.dart';
import '../../domain/entities/medication_dosage_input.dart';

/// Base de dados estática dos 10 medicamentos veterinários essenciais
class MedicationDatabase {
  static final List<MedicationData> _medications = [
    MedicationData(
      id: 'amoxicillin',
      name: 'Amoxicilina',
      activeIngredient: 'Amoxicilina',
      category: 'Antibiótico',
      indications: const [
        'Infecções respiratórias',
        'Infecções urinárias',
        'Infecções de pele',
        'Infecções odontológicas',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 10.0,
          maxDose: 20.0,
          toxicDose: 50.0,
          lethalDose: 100.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 10.0,
          maxDose: 15.0,
          toxicDose: 40.0,
          lethalDose: 80.0,
          species: Species.cat,
        ),
        DosageRange(
          minDose: 8.0,
          maxDose: 15.0,
          toxicDose: 40.0,
          species: Species.dog,
          ageGroup: AgeGroup.puppy,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
        MedicationConcentration(value: 125.0, unit: 'mg/ml', description: '125mg/ml'),
        MedicationConcentration(value: 250.0, unit: 'mg/ml', description: '250mg/ml'),
      ],
      pharmaceuticalForms: const ['Suspensão oral', 'Comprimido', 'Cápsula'],
      recommendedFrequencies: const [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: const ['Oral'],
      contraindications: const [
        Contraindication(
          condition: 'Alergia à penicilina',
          reason: 'Risco de reação alérgica grave',
          isAbsolute: true,
          alternative: 'Cefalexina ou Enrofloxacina',
        ),
      ],
      sideEffects: const ['Diarreia', 'Vômitos', 'Perda de apetite'],
      drugInteractions: const ['Cloranfenicol', 'Tetraciclina'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro com monitoramento',
      speciesSpecificWarnings: const {
        Species.cat: ['Monitorar função renal', 'Pode causar diarreia mais facilmente'],
      },
      storageInstructions: 'Armazenar em temperatura ambiente. Suspensão reconstituída: refrigerador por 14 dias.',
      clinicalNotes: 'Administrar preferencialmente com alimento para reduzir irritação gástrica.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'meloxicam',
      name: 'Meloxicam',
      activeIngredient: 'Meloxicam',
      category: 'Anti-inflamatório',
      indications: const [
        'Dor pós-operatória',
        'Artrite',
        'Inflamações músculo-esqueléticas',
        'Dor crônica',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 0.1,
          maxDose: 0.2,
          toxicDose: 0.5,
          lethalDose: 1.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 0.05,
          maxDose: 0.1,
          toxicDose: 0.2,
          lethalDose: 0.3,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 1.5, unit: 'mg/ml', description: '1,5mg/ml'),
        MedicationConcentration(value: 5.0, unit: 'mg/ml', description: '5mg/ml'),
      ],
      pharmaceuticalForms: const ['Suspensão oral', 'Comprimido', 'Injetável'],
      recommendedFrequencies: const [AdministrationFrequency.once],
      administrationRoutes: const ['Oral', 'Subcutânea', 'Intravenosa'],
      contraindications: const [
        Contraindication(
          condition: 'Doença renal',
          reason: 'Pode piorar função renal',
          isAbsolute: true,
        ),
        Contraindication(
          condition: 'Úlcera gástrica',
          reason: 'Pode causar perfuração gástrica',
          isAbsolute: true,
        ),
        Contraindication(
          condition: 'Desidratação',
          reason: 'Aumenta risco de toxicidade renal',
          isAbsolute: false,
        ),
      ],
      sideEffects: const ['Vômitos', 'Diarreia', 'Perda de apetite', 'Letargia'],
      drugInteractions: const ['Furosemida', 'Corticoides', 'Outros AINEs'],
      pregnancyCategory: 'C',
      lactationSafety: 'Evitar durante lactação',
      speciesSpecificWarnings: const {
        Species.cat: [
          'ATENÇÃO: Uso MUITO restrito em gatos',
          'Apenas primeira dose pós-cirúrgica',
          'Monitoramento renal obrigatório',
          'Pode causar insuficiência renal aguda',
        ],
      },
      storageInstructions: 'Armazenar em temperatura ambiente, proteger da luz.',
      clinicalNotes: 'SEMPRE administrar com alimento. Monitorar função renal durante uso prolongado.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'tramadol',
      name: 'Tramadol',
      activeIngredient: 'Cloridrato de Tramadol',
      category: 'Analgésico',
      indications: const [
        'Dor moderada a severa',
        'Dor pós-operatória',
        'Dor crônica',
        'Dor oncológica',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 2.0,
          maxDose: 5.0,
          toxicDose: 15.0,
          lethalDose: 30.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 1.0,
          maxDose: 4.0,
          toxicDose: 10.0,
          lethalDose: 20.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: const ['Comprimido', 'Solução oral', 'Injetável'],
      recommendedFrequencies: const [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: const ['Oral', 'Intramuscular', 'Intravenosa'],
      contraindications: const [
        Contraindication(
          condition: 'Epilepsia',
          reason: 'Pode reduzir limiar convulsivo',
          isAbsolute: false,
        ),
      ],
      sideEffects: const ['Sedação', 'Náusea', 'Constipação', 'Salivação excessiva'],
      drugInteractions: const ['IMAOs', 'Serotoninérgicos', 'Depressores do SNC'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: const {
        Species.cat: [
          'Metabolismo diferente dos cães',
          'Pode causar midríase',
          'Monitorar comportamento',
        ],
      },
      storageInstructions: 'Armazenar em temperatura ambiente. Medicamento controlado.',
      clinicalNotes: 'Iniciar com dose menor e titular conforme resposta.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'prednisolone',
      name: 'Prednisolona',
      activeIngredient: 'Prednisolona',
      category: 'Corticoide',
      indications: const [
        'Inflamações alérgicas',
        'Doenças autoimunes',
        'Inflamações articulares',
        'Dermatites',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 0.5,
          maxDose: 2.0,
          toxicDose: 5.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 0.5,
          maxDose: 2.0,
          toxicDose: 5.0,
          species: Species.cat,
        ),
        DosageRange(
          minDose: 2.0,
          maxDose: 4.0,
          toxicDose: 8.0,
          species: Species.dog,
          applicableConditions: [SpecialCondition.healthy], // Para doenças autoimunes
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 5.0, unit: 'mg/ml', description: '5mg/ml'),
        MedicationConcentration(value: 20.0, unit: 'mg/ml', description: '20mg/ml'),
      ],
      pharmaceuticalForms: const ['Comprimido', 'Solução oral'],
      recommendedFrequencies: const [
        AdministrationFrequency.once,
        AdministrationFrequency.twice,
      ],
      administrationRoutes: const ['Oral'],
      contraindications: const [
        Contraindication(
          condition: 'Diabetes mellitus',
          reason: 'Pode descompensar diabetes',
          isAbsolute: false,
        ),
        Contraindication(
          condition: 'Infecções sistêmicas',
          reason: 'Imunossupressão pode piorar infecção',
          isAbsolute: false,
        ),
      ],
      sideEffects: const [
        'Poliúria/polidipsia',
        'Polifagia',
        'Ganho de peso',
        'Panting',
        'Imunossupressão',
      ],
      drugInteractions: const ['AINEs', 'Diuréticos', 'Insulina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: const {
        Species.cat: ['Pode predispor a diabetes', 'Monitorar glicemia'],
      },
      storageInstructions: 'Armazenar em temperatura ambiente, proteger da umidade.',
      clinicalNotes: 'SEMPRE reduzir dose gradualmente. Administrar com alimento.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'omeprazole',
      name: 'Omeprazol',
      activeIngredient: 'Omeprazol',
      category: 'Protetor Gástrico',
      indications: const [
        'Úlcera gástrica',
        'Refluxo gastroesofágico',
        'Gastrite',
        'Prevenção de úlceras por AINEs',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 0.7,
          maxDose: 1.5,
          toxicDose: 5.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 0.7,
          maxDose: 1.0,
          toxicDose: 3.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 2.0, unit: 'mg/ml', description: '2mg/ml'),
        MedicationConcentration(value: 4.0, unit: 'mg/ml', description: '4mg/ml'),
      ],
      pharmaceuticalForms: const ['Cápsula', 'Comprimido', 'Suspensão oral'],
      recommendedFrequencies: const [AdministrationFrequency.once],
      administrationRoutes: const ['Oral'],
      contraindications: const [],
      sideEffects: const ['Raramente: diarreia leve', 'Alteração da flora intestinal'],
      drugInteractions: const ['Cetoconazol', 'Digoxina'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro',
      speciesSpecificWarnings: const {
        Species.cat: ['Uso off-label em gatos', 'Estudos limitados'],
      },
      storageInstructions: 'Armazenar em local seco, temperatura ambiente.',
      clinicalNotes: 'Administrar EM JEJUM, 30-60 minutos antes da alimentação.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'furosemide',
      name: 'Furosemida',
      activeIngredient: 'Furosemida',
      category: 'Diurético',
      indications: const [
        'Insuficiência cardíaca congestiva',
        'Edema pulmonar',
        'Ascite',
        'Hipertensão',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 1.0,
          maxDose: 4.0,
          toxicDose: 10.0,
          lethalDose: 20.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 1.0,
          maxDose: 2.0,
          toxicDose: 6.0,
          lethalDose: 12.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 10.0, unit: 'mg/ml', description: '10mg/ml'),
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: const ['Comprimido', 'Solução injetável', 'Solução oral'],
      recommendedFrequencies: const [
        AdministrationFrequency.once,
        AdministrationFrequency.twice,
      ],
      administrationRoutes: const ['Oral', 'Intravenosa', 'Intramuscular'],
      contraindications: const [
        Contraindication(
          condition: 'Desidratação severa',
          reason: 'Pode causar colapso circulatório',
          isAbsolute: true,
        ),
        Contraindication(
          condition: 'Anúria',
          reason: 'Ineficaz na ausência de função renal',
          isAbsolute: true,
        ),
      ],
      sideEffects: const [
        'Desidratação',
        'Desequilíbrio eletrolítico',
        'Azotemia pré-renal',
        'Ototoxicidade (doses altas)',
      ],
      drugInteractions: const ['AINEs', 'Aminoglicosídeos', 'Lítio'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: const {
        Species.cat: [
          'Maior risco de desidratação',
          'Monitorar eletrólitos rigorosamente',
          'Pode causar azotemia mais facilmente',
        ],
      },
      storageInstructions: 'Proteger da luz. Injetável: não congelar.',
      clinicalNotes: 'Monitorar função renal, eletrólitos e hidratação. Aumentar ingestão de água.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'enrofloxacin',
      name: 'Enrofloxacina',
      activeIngredient: 'Enrofloxacina',
      category: 'Antibiótico Quinolona',
      indications: const [
        'Infecções por Gram-negativos',
        'Infecções urinárias complexas',
        'Infecções respiratórias',
        'Infecções de pele',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 5.0,
          maxDose: 10.0,
          toxicDose: 25.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 2.5,
          maxDose: 5.0,
          toxicDose: 10.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 25.0, unit: 'mg/ml', description: '25mg/ml'),
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: const ['Comprimido', 'Solução oral', 'Injetável'],
      recommendedFrequencies: const [AdministrationFrequency.once],
      administrationRoutes: const ['Oral', 'Subcutânea', 'Intravenosa'],
      contraindications: const [
        Contraindication(
          condition: 'Filhotes em crescimento',
          reason: 'Pode afetar desenvolvimento da cartilagem',
          isAbsolute: true,
        ),
        Contraindication(
          condition: 'Gestação',
          reason: 'Efeitos teratogênicos possíveis',
          isAbsolute: false,
        ),
      ],
      sideEffects: const ['Distúrbios gastrointestinais', 'Cristalúria', 'Artropatia (jovens)'],
      drugInteractions: const ['Antiácidos', 'Teofilina', 'Varfarina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Evitar',
      speciesSpecificWarnings: const {
        Species.cat: [
          'PERIGO: Pode causar cegueira irreversível',
          'NÃO exceder 5mg/kg',
          'Monitorar sinais oculares',
          'Descontinuar se alterações visuais',
        ],
      },
      storageInstructions: 'Armazenar protegido da luz.',
      clinicalNotes: 'Não administrar com laticínios. Manter hidratação adequada.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'metronidazole',
      name: 'Metronidazol',
      activeIngredient: 'Metronidazol',
      category: 'Antiprotozoário',
      indications: const [
        'Giardíase',
        'Infecções anaeróbicas',
        'Colite',
        'Doença inflamatória intestinal',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 10.0,
          maxDose: 25.0,
          toxicDose: 60.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 10.0,
          maxDose: 20.0,
          toxicDose: 50.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 40.0, unit: 'mg/ml', description: '40mg/ml'),
      ],
      pharmaceuticalForms: const ['Comprimido', 'Suspensão oral'],
      recommendedFrequencies: const [AdministrationFrequency.twice],
      administrationRoutes: const ['Oral'],
      contraindications: const [
        Contraindication(
          condition: 'Doença hepática severa',
          reason: 'Metabolismo hepático prejudicado',
          isAbsolute: false,
        ),
      ],
      sideEffects: const [
        'Náusea',
        'Vômitos',
        'Perda de apetite',
        'Sabor metálico',
        'Neuropatia periférica (uso prolongado)',
      ],
      drugInteractions: const ['Varfarina', 'Álcool', 'Lítio'],
      pregnancyCategory: 'B',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: const {
        Species.cat: [
          'Maior sensibilidade aos efeitos adversos',
          'Usar doses menores',
          'Monitorar sinais neurológicos',
        ],
      },
      storageInstructions: 'Proteger da luz.',
      clinicalNotes: 'Administrar com alimento para reduzir náusea.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'gabapentin',
      name: 'Gabapentina',
      activeIngredient: 'Gabapentina',
      category: 'Anticonvulsivante',
      indications: const [
        'Dor neuropática',
        'Epilepsia (adjuvante)',
        'Ansiedade (off-label)',
        'Dor crônica',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 5.0,
          maxDose: 10.0,
          toxicDose: 50.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 3.0,
          maxDose: 8.0,
          toxicDose: 30.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: const ['Cápsula', 'Comprimido', 'Solução oral'],
      recommendedFrequencies: const [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: const ['Oral'],
      contraindications: const [],
      sideEffects: const ['Sedação', 'Ataxia', 'Fraqueza'],
      drugInteractions: const ['Antiácidos', 'Morfina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Dados limitados',
      speciesSpecificWarnings: const {
        Species.cat: [
          'Início com doses menores',
          'Monitorar coordenação',
          'Pode causar sedação excessiva',
        ],
      },
      storageInstructions: 'Temperatura ambiente.',
      clinicalNotes: 'Titular dose gradualmente. Pode ser administrado com ou sem alimento.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
    MedicationData(
      id: 'insulin_nph',
      name: 'Insulina NPH',
      activeIngredient: 'Insulina Humana NPH',
      category: 'Antidiabético',
      indications: const [
        'Diabetes mellitus tipo 1',
        'Diabetes mellitus tipo 2',
        'Cetoacidose diabética (com insulina rápida)',
      ],
      dosageRanges: const [
        DosageRange(
          minDose: 0.25,
          maxDose: 0.5,
          toxicDose: 2.0,
          species: Species.dog,
        ),
        DosageRange(
          minDose: 0.25,
          maxDose: 0.5,
          toxicDose: 2.0,
          species: Species.cat,
        ),
      ],
      concentrations: const [
        MedicationConcentration(value: 100.0, unit: 'UI/ml', description: '100UI/ml'),
      ],
      pharmaceuticalForms: const ['Suspensão injetável'],
      recommendedFrequencies: const [AdministrationFrequency.twice],
      administrationRoutes: const ['Subcutânea'],
      contraindications: const [
        Contraindication(
          condition: 'Hipoglicemia',
          reason: 'Pode causar coma hipoglicêmico',
          isAbsolute: true,
        ),
      ],
      sideEffects: const [
        'Hipoglicemia',
        'Reação no local da injeção',
        'Lipodistrofia',
      ],
      drugInteractions: const ['Corticoides', 'Beta-bloqueadores'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro',
      speciesSpecificWarnings: const {
        Species.cat: [
          'Gatos podem entrar em remissão',
          'Monitoramento glicêmico rigoroso',
          'Possível descontinuação do tratamento',
        ],
      },
      storageInstructions: 'REFRIGERAR (2-8°C). NÃO congelar. Homogeneizar antes do uso.',
      clinicalNotes: 'Administrar SEMPRE com refeição. Monitorar glicemia diariamente.',
      lastUpdated: DateTime(2024, 1, 1),
    ),
  ];

  /// Retorna todos os medicamentos disponíveis
  static List<MedicationData> getAllMedications() {
    return List.unmodifiable(_medications);
  }

  /// Busca medicamento por ID
  static MedicationData? getMedicationById(String id) {
    try {
      return _medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca medicamentos por categoria
  static List<MedicationData> getMedicationsByCategory(String category) {
    return _medications.where(
      (med) => med.category.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }

  /// Busca medicamentos seguros para uma espécie
  static List<MedicationData> getMedicationsForSpecies(Species species) {
    return _medications.where(
      (med) => med.dosageRanges.any((range) => range.species == species)
    ).toList();
  }

  /// Busca medicamentos por indicação
  static List<MedicationData> getMedicationsByIndication(String indication) {
    return _medications.where(
      (med) => med.indications.any(
        (ind) => ind.toLowerCase().contains(indication.toLowerCase())
      )
    ).toList();
  }

  /// Busca medicamentos por princípio ativo
  static List<MedicationData> getMedicationsByActiveIngredient(String activeIngredient) {
    return _medications.where(
      (med) => med.activeIngredient.toLowerCase().contains(activeIngredient.toLowerCase())
    ).toList();
  }

  /// Retorna medicamentos mais utilizados (top 5)
  static List<MedicationData> getTopMedications() {
    return [
      getMedicationById('amoxicillin')!,
      getMedicationById('meloxicam')!,
      getMedicationById('prednisolone')!,
      getMedicationById('tramadol')!,
      getMedicationById('omeprazole')!,
    ];
  }

  /// Retorna estatísticas da base de dados
  static Map<String, int> getDatabaseStats() {
    final stats = <String, int>{
      'total_medications': _medications.length,
      'antibiotics': getMedicationsByCategory('antibiótico').length,
      'anti_inflammatories': getMedicationsByCategory('anti-inflamatório').length,
      'analgesics': getMedicationsByCategory('analgésico').length,
      'for_dogs': getMedicationsForSpecies(Species.dog).length,
      'for_cats': getMedicationsForSpecies(Species.cat).length,
    };

    return stats;
  }
}