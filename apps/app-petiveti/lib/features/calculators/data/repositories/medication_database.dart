import '../../domain/entities/medication_data.dart';
import '../../domain/entities/medication_dosage_input.dart';

/// Base de dados estática dos 10 medicamentos veterinários essenciais
class MedicationDatabase {
  static final List<MedicationData> _medications = [
    // 1. AMOXICILINA - Antibiótico de amplo espectro
    MedicationData(
      id: 'amoxicillin',
      name: 'Amoxicilina',
      activeIngredient: 'Amoxicilina',
      category: 'Antibiótico',
      indications: [
        'Infecções respiratórias',
        'Infecções urinárias',
        'Infecções de pele',
        'Infecções odontológicas',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 10.0,
          maxDose: 20.0,
          toxicDose: 50.0,
          lethalDose: 100.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 10.0,
          maxDose: 15.0,
          toxicDose: 40.0,
          lethalDose: 80.0,
          species: Species.cat,
        ),
        // Filhotes - dose reduzida
        DosageRange(
          minDose: 8.0,
          maxDose: 15.0,
          toxicDose: 40.0,
          species: Species.dog,
          ageGroup: AgeGroup.puppy,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
        MedicationConcentration(value: 125.0, unit: 'mg/ml', description: '125mg/ml'),
        MedicationConcentration(value: 250.0, unit: 'mg/ml', description: '250mg/ml'),
      ],
      pharmaceuticalForms: ['Suspensão oral', 'Comprimido', 'Cápsula'],
      recommendedFrequencies: [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: ['Oral'],
      contraindications: [
        Contraindication(
          condition: 'Alergia à penicilina',
          reason: 'Risco de reação alérgica grave',
          isAbsolute: true,
          alternative: 'Cefalexina ou Enrofloxacina',
        ),
      ],
      sideEffects: ['Diarreia', 'Vômitos', 'Perda de apetite'],
      drugInteractions: ['Cloranfenicol', 'Tetraciclina'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro com monitoramento',
      speciesSpecificWarnings: {
        Species.cat: ['Monitorar função renal', 'Pode causar diarreia mais facilmente'],
      },
      storageInstructions: 'Armazenar em temperatura ambiente. Suspensão reconstituída: refrigerador por 14 dias.',
      clinicalNotes: 'Administrar preferencialmente com alimento para reduzir irritação gástrica.',
      lastUpdated: DateTime(2024, 1, 1),
    ),

    // 2. MELOXICAM - Anti-inflamatório não esteroidal
    MedicationData(
      id: 'meloxicam',
      name: 'Meloxicam',
      activeIngredient: 'Meloxicam',
      category: 'Anti-inflamatório',
      indications: [
        'Dor pós-operatória',
        'Artrite',
        'Inflamações músculo-esqueléticas',
        'Dor crônica',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 0.1,
          maxDose: 0.2,
          toxicDose: 0.5,
          lethalDose: 1.0,
          species: Species.dog,
        ),
        // Gatos - MUITO RESTRITO
        DosageRange(
          minDose: 0.05,
          maxDose: 0.1,
          toxicDose: 0.2,
          lethalDose: 0.3,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 1.5, unit: 'mg/ml', description: '1,5mg/ml'),
        MedicationConcentration(value: 5.0, unit: 'mg/ml', description: '5mg/ml'),
      ],
      pharmaceuticalForms: ['Suspensão oral', 'Comprimido', 'Injetável'],
      recommendedFrequencies: [AdministrationFrequency.once],
      administrationRoutes: ['Oral', 'Subcutânea', 'Intravenosa'],
      contraindications: [
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
      sideEffects: ['Vômitos', 'Diarreia', 'Perda de apetite', 'Letargia'],
      drugInteractions: ['Furosemida', 'Corticoides', 'Outros AINEs'],
      pregnancyCategory: 'C',
      lactationSafety: 'Evitar durante lactação',
      speciesSpecificWarnings: {
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

    // 3. TRAMADOL - Analgésico opioide
    MedicationData(
      id: 'tramadol',
      name: 'Tramadol',
      activeIngredient: 'Cloridrato de Tramadol',
      category: 'Analgésico',
      indications: [
        'Dor moderada a severa',
        'Dor pós-operatória',
        'Dor crônica',
        'Dor oncológica',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 2.0,
          maxDose: 5.0,
          toxicDose: 15.0,
          lethalDose: 30.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 1.0,
          maxDose: 4.0,
          toxicDose: 10.0,
          lethalDose: 20.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: ['Comprimido', 'Solução oral', 'Injetável'],
      recommendedFrequencies: [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: ['Oral', 'Intramuscular', 'Intravenosa'],
      contraindications: [
        Contraindication(
          condition: 'Epilepsia',
          reason: 'Pode reduzir limiar convulsivo',
          isAbsolute: false,
        ),
      ],
      sideEffects: ['Sedação', 'Náusea', 'Constipação', 'Salivação excessiva'],
      drugInteractions: ['IMAOs', 'Serotoninérgicos', 'Depressores do SNC'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: {
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

    // 4. PREDNISOLONA - Corticoide
    MedicationData(
      id: 'prednisolone',
      name: 'Prednisolona',
      activeIngredient: 'Prednisolona',
      category: 'Corticoide',
      indications: [
        'Inflamações alérgicas',
        'Doenças autoimunes',
        'Inflamações articulares',
        'Dermatites',
      ],
      dosageRanges: [
        // Cães e Gatos - dose anti-inflamatória
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
        // Dose imunossupressora
        DosageRange(
          minDose: 2.0,
          maxDose: 4.0,
          toxicDose: 8.0,
          species: Species.dog,
          applicableConditions: [SpecialCondition.healthy], // Para doenças autoimunes
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 5.0, unit: 'mg/ml', description: '5mg/ml'),
        MedicationConcentration(value: 20.0, unit: 'mg/ml', description: '20mg/ml'),
      ],
      pharmaceuticalForms: ['Comprimido', 'Solução oral'],
      recommendedFrequencies: [
        AdministrationFrequency.once,
        AdministrationFrequency.twice,
      ],
      administrationRoutes: ['Oral'],
      contraindications: [
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
      sideEffects: [
        'Poliúria/polidipsia',
        'Polifagia',
        'Ganho de peso',
        'Panting',
        'Imunossupressão',
      ],
      drugInteractions: ['AINEs', 'Diuréticos', 'Insulina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: {
        Species.cat: ['Pode predispor a diabetes', 'Monitorar glicemia'],
      },
      storageInstructions: 'Armazenar em temperatura ambiente, proteger da umidade.',
      clinicalNotes: 'SEMPRE reduzir dose gradualmente. Administrar com alimento.',
      lastUpdated: DateTime(2024, 1, 1),
    ),

    // 5. OMEPRAZOL - Protetor gástrico
    MedicationData(
      id: 'omeprazole',
      name: 'Omeprazol',
      activeIngredient: 'Omeprazol',
      category: 'Protetor Gástrico',
      indications: [
        'Úlcera gástrica',
        'Refluxo gastroesofágico',
        'Gastrite',
        'Prevenção de úlceras por AINEs',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 0.7,
          maxDose: 1.5,
          toxicDose: 5.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 0.7,
          maxDose: 1.0,
          toxicDose: 3.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 2.0, unit: 'mg/ml', description: '2mg/ml'),
        MedicationConcentration(value: 4.0, unit: 'mg/ml', description: '4mg/ml'),
      ],
      pharmaceuticalForms: ['Cápsula', 'Comprimido', 'Suspensão oral'],
      recommendedFrequencies: [AdministrationFrequency.once],
      administrationRoutes: ['Oral'],
      contraindications: [],
      sideEffects: ['Raramente: diarreia leve', 'Alteração da flora intestinal'],
      drugInteractions: ['Cetoconazol', 'Digoxina'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro',
      speciesSpecificWarnings: {
        Species.cat: ['Uso off-label em gatos', 'Estudos limitados'],
      },
      storageInstructions: 'Armazenar em local seco, temperatura ambiente.',
      clinicalNotes: 'Administrar EM JEJUM, 30-60 minutos antes da alimentação.',
      lastUpdated: DateTime(2024, 1, 1),
    ),

    // 6. FUROSEMIDA - Diurético de alça
    MedicationData(
      id: 'furosemide',
      name: 'Furosemida',
      activeIngredient: 'Furosemida',
      category: 'Diurético',
      indications: [
        'Insuficiência cardíaca congestiva',
        'Edema pulmonar',
        'Ascite',
        'Hipertensão',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 1.0,
          maxDose: 4.0,
          toxicDose: 10.0,
          lethalDose: 20.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 1.0,
          maxDose: 2.0,
          toxicDose: 6.0,
          lethalDose: 12.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 10.0, unit: 'mg/ml', description: '10mg/ml'),
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: ['Comprimido', 'Solução injetável', 'Solução oral'],
      recommendedFrequencies: [
        AdministrationFrequency.once,
        AdministrationFrequency.twice,
      ],
      administrationRoutes: ['Oral', 'Intravenosa', 'Intramuscular'],
      contraindications: [
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
      sideEffects: [
        'Desidratação',
        'Desequilíbrio eletrolítico',
        'Azotemia pré-renal',
        'Ototoxicidade (doses altas)',
      ],
      drugInteractions: ['AINEs', 'Aminoglicosídeos', 'Lítio'],
      pregnancyCategory: 'C',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: {
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

    // 7. ENROFLOXACINA - Quinolona
    MedicationData(
      id: 'enrofloxacin',
      name: 'Enrofloxacina',
      activeIngredient: 'Enrofloxacina',
      category: 'Antibiótico Quinolona',
      indications: [
        'Infecções por Gram-negativos',
        'Infecções urinárias complexas',
        'Infecções respiratórias',
        'Infecções de pele',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 5.0,
          maxDose: 10.0,
          toxicDose: 25.0,
          species: Species.dog,
        ),
        // Gatos - DOSE MUITO RESTRITA
        DosageRange(
          minDose: 2.5,
          maxDose: 5.0,
          toxicDose: 10.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 25.0, unit: 'mg/ml', description: '25mg/ml'),
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: ['Comprimido', 'Solução oral', 'Injetável'],
      recommendedFrequencies: [AdministrationFrequency.once],
      administrationRoutes: ['Oral', 'Subcutânea', 'Intravenosa'],
      contraindications: [
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
      sideEffects: ['Distúrbios gastrointestinais', 'Cristalúria', 'Artropatia (jovens)'],
      drugInteractions: ['Antiácidos', 'Teofilina', 'Varfarina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Evitar',
      speciesSpecificWarnings: {
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

    // 8. METRONIDAZOL - Antiprotozoário/Antibacteriano
    MedicationData(
      id: 'metronidazole',
      name: 'Metronidazol',
      activeIngredient: 'Metronidazol',
      category: 'Antiprotozoário',
      indications: [
        'Giardíase',
        'Infecções anaeróbicas',
        'Colite',
        'Doença inflamatória intestinal',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 10.0,
          maxDose: 25.0,
          toxicDose: 60.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 10.0,
          maxDose: 20.0,
          toxicDose: 50.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 40.0, unit: 'mg/ml', description: '40mg/ml'),
      ],
      pharmaceuticalForms: ['Comprimido', 'Suspensão oral'],
      recommendedFrequencies: [AdministrationFrequency.twice],
      administrationRoutes: ['Oral'],
      contraindications: [
        Contraindication(
          condition: 'Doença hepática severa',
          reason: 'Metabolismo hepático prejudicado',
          isAbsolute: false,
        ),
      ],
      sideEffects: [
        'Náusea',
        'Vômitos',
        'Perda de apetite',
        'Sabor metálico',
        'Neuropatia periférica (uso prolongado)',
      ],
      drugInteractions: ['Varfarina', 'Álcool', 'Lítio'],
      pregnancyCategory: 'B',
      lactationSafety: 'Usar com cautela',
      speciesSpecificWarnings: {
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

    // 9. GABAPENTINA - Anticonvulsivante/Analgésico neuropático
    MedicationData(
      id: 'gabapentin',
      name: 'Gabapentina',
      activeIngredient: 'Gabapentina',
      category: 'Anticonvulsivante',
      indications: [
        'Dor neuropática',
        'Epilepsia (adjuvante)',
        'Ansiedade (off-label)',
        'Dor crônica',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 5.0,
          maxDose: 10.0,
          toxicDose: 50.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 3.0,
          maxDose: 8.0,
          toxicDose: 30.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
      ],
      pharmaceuticalForms: ['Cápsula', 'Comprimido', 'Solução oral'],
      recommendedFrequencies: [
        AdministrationFrequency.twice,
        AdministrationFrequency.thrice,
      ],
      administrationRoutes: ['Oral'],
      contraindications: [],
      sideEffects: ['Sedação', 'Ataxia', 'Fraqueza'],
      drugInteractions: ['Antiácidos', 'Morfina'],
      pregnancyCategory: 'C',
      lactationSafety: 'Dados limitados',
      speciesSpecificWarnings: {
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

    // 10. INSULINA NPH - Antidiabético
    MedicationData(
      id: 'insulin_nph',
      name: 'Insulina NPH',
      activeIngredient: 'Insulina Humana NPH',
      category: 'Antidiabético',
      indications: [
        'Diabetes mellitus tipo 1',
        'Diabetes mellitus tipo 2',
        'Cetoacidose diabética (com insulina rápida)',
      ],
      dosageRanges: [
        // Cães
        DosageRange(
          minDose: 0.25,
          maxDose: 0.5,
          toxicDose: 2.0,
          species: Species.dog,
        ),
        // Gatos
        DosageRange(
          minDose: 0.25,
          maxDose: 0.5,
          toxicDose: 2.0,
          species: Species.cat,
        ),
      ],
      concentrations: [
        MedicationConcentration(value: 100.0, unit: 'UI/ml', description: '100UI/ml'),
      ],
      pharmaceuticalForms: ['Suspensão injetável'],
      recommendedFrequencies: [AdministrationFrequency.twice],
      administrationRoutes: ['Subcutânea'],
      contraindications: [
        Contraindication(
          condition: 'Hipoglicemia',
          reason: 'Pode causar coma hipoglicêmico',
          isAbsolute: true,
        ),
      ],
      sideEffects: [
        'Hipoglicemia',
        'Reação no local da injeção',
        'Lipodistrofia',
      ],
      drugInteractions: ['Corticoides', 'Beta-bloqueadores'],
      pregnancyCategory: 'B',
      lactationSafety: 'Seguro',
      speciesSpecificWarnings: {
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