/// Calculadora de Gestação de Pets
/// Calcula data prevista do parto e acompanha estágios da gestação
library;

enum PregnancyStage {
  implantation, // 0-20 dias
  earlyDevelopment, // 21-34 dias
  midDevelopment, // 35-49 dias
  lateDevelopment, // 50-62 dias
  term, // pronto para nascer
  overdue, // atrasado
}

class PregnancyMilestone {
  final int day;
  final String title;
  final String description;
  final bool isImportant;

  const PregnancyMilestone({
    required this.day,
    required this.title,
    required this.description,
    this.isImportant = false,
  });
}

class PregnancyResult {
  /// Dias de gestação até agora
  final int gestationDays;

  /// Data estimada do parto
  final DateTime estimatedDueDate;

  /// Data mais cedo possível
  final DateTime earliestDueDate;

  /// Data mais tarde possível
  final DateTime latestDueDate;

  /// Estágio atual da gestação
  final PregnancyStage currentStage;

  /// Descrição do estágio
  final String stageDescription;

  /// Dias restantes
  final int daysRemaining;

  /// Progresso (0-100%)
  final double progressPercent;

  /// Recomendações nutricionais
  final List<String> nutritionalRecommendations;

  /// Instruções de cuidado
  final List<String> careInstructions;

  /// Próximos marcos importantes
  final List<PregnancyMilestone> upcomingMilestones;

  /// Está atrasado?
  final bool isOverdue;

  const PregnancyResult({
    required this.gestationDays,
    required this.estimatedDueDate,
    required this.earliestDueDate,
    required this.latestDueDate,
    required this.currentStage,
    required this.stageDescription,
    required this.daysRemaining,
    required this.progressPercent,
    required this.nutritionalRecommendations,
    required this.careInstructions,
    required this.upcomingMilestones,
    required this.isOverdue,
  });
}

class PregnancyCalculator {
  // Períodos de gestação em dias
  static const Map<String, Map<String, int>> gestationPeriods = {
    'dog': {'min': 58, 'average': 63, 'max': 68},
    'cat': {'min': 64, 'average': 67, 'max': 70},
  };

  /// Calcula informações da gestação
  static PregnancyResult calculate({
    required bool isDog,
    required DateTime matingDate,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final species = isDog ? 'dog' : 'cat';
    final period = gestationPeriods[species]!;

    final gestationDays = now.difference(matingDate).inDays;
    final averageDays = period['average']!;
    final minDays = period['min']!;
    final maxDays = period['max']!;

    final estimatedDueDate = matingDate.add(Duration(days: averageDays));
    final earliestDueDate = matingDate.add(Duration(days: minDays));
    final latestDueDate = matingDate.add(Duration(days: maxDays));

    final daysRemaining = (averageDays - gestationDays).clamp(0, averageDays);
    final progressPercent = ((gestationDays / averageDays) * 100).clamp(0, 100);
    final isOverdue = gestationDays > maxDays;

    final currentStage = _getStage(gestationDays, averageDays, maxDays);
    final stageDescription = _getStageDescription(currentStage, isDog);
    final nutritionalRecommendations = _getNutritionalRecommendations(
      currentStage,
      isDog,
    );
    final careInstructions = _getCareInstructions(currentStage, isDog);
    final upcomingMilestones = _getUpcomingMilestones(
      gestationDays,
      isDog,
    );

    return PregnancyResult(
      gestationDays: gestationDays,
      estimatedDueDate: estimatedDueDate,
      earliestDueDate: earliestDueDate,
      latestDueDate: latestDueDate,
      currentStage: currentStage,
      stageDescription: stageDescription,
      daysRemaining: daysRemaining,
      progressPercent: progressPercent.toDouble(),
      nutritionalRecommendations: nutritionalRecommendations,
      careInstructions: careInstructions,
      upcomingMilestones: upcomingMilestones,
      isOverdue: isOverdue,
    );
  }

  static PregnancyStage _getStage(int days, int average, int max) {
    if (days > max) return PregnancyStage.overdue;
    if (days >= average - 5) return PregnancyStage.term;
    if (days >= 50) return PregnancyStage.lateDevelopment;
    if (days >= 35) return PregnancyStage.midDevelopment;
    if (days >= 21) return PregnancyStage.earlyDevelopment;
    return PregnancyStage.implantation;
  }

  static String _getStageDescription(PregnancyStage stage, bool isDog) {
    final babies = isDog ? 'filhotes' : 'gatinhos';

    return switch (stage) {
      PregnancyStage.implantation =>
        'Fase de implantação dos embriões. Evite estresse.',
      PregnancyStage.earlyDevelopment =>
        'Os embriões estão se desenvolvendo. Primeiro ultrassom recomendado.',
      PregnancyStage.midDevelopment =>
        'Desenvolvimento fetal ativo. É possível contar os $babies no ultrassom.',
      PregnancyStage.lateDevelopment =>
        'Fase final. Os $babies estão quase prontos. Prepare o ninho!',
      PregnancyStage.term =>
        'A qualquer momento! Monitore sinais de trabalho de parto.',
      PregnancyStage.overdue =>
        '⚠️ Gestação prolongada. Consulte o veterinário imediatamente!',
    };
  }

  static List<String> _getNutritionalRecommendations(
    PregnancyStage stage,
    bool isDog,
  ) {
    return switch (stage) {
      PregnancyStage.implantation => [
        'Mantenha alimentação normal de qualidade',
        'Suplementação de ácido fólico pode ajudar',
        'Evite medicamentos desnecessários',
        'Água fresca sempre disponível',
      ],
      PregnancyStage.earlyDevelopment => [
        'Comece transição para ração de filhotes',
        'Aumente porções em 10-20%',
        'Proteína de alta qualidade é essencial',
        'Divida em 3 refeições diárias',
      ],
      PregnancyStage.midDevelopment => [
        'Aumente porções em 30-50%',
        'Ração premium para filhotes/gestantes',
        'Mínimo 25% de proteína na dieta',
        'Cálcio sob orientação veterinária',
        '3-4 refeições diárias',
      ],
      PregnancyStage.lateDevelopment || PregnancyStage.term => [
        'Aumente porções em 50-75%',
        'Refeições pequenas e frequentes (4-5x)',
        'Água sempre disponível',
        'Evite sal e aditivos',
        'Monitorar peso semanalmente',
      ],
      PregnancyStage.overdue => [
        'Mantenha hidratação',
        'Refeições leves',
        'Siga orientação veterinária',
      ],
    };
  }

  static List<String> _getCareInstructions(PregnancyStage stage, bool isDog) {
    return switch (stage) {
      PregnancyStage.implantation => [
        'Evite atividades intensas',
        'Ambiente calmo e tranquilo',
        'Evite viagens longas',
        'Não use medicamentos sem orientação',
      ],
      PregnancyStage.earlyDevelopment => [
        'Agende ultrassom com veterinário',
        'Exercícios leves são permitidos',
        'Observe mudanças de comportamento',
        'Mantenha vermifugação em dia',
      ],
      PregnancyStage.midDevelopment => [
        'Segundo ultrassom para contar filhotes',
        'Reduza exercícios gradualmente',
        'Prepare área para o ninho',
        'Comece a reunir materiais para o parto',
      ],
      PregnancyStage.lateDevelopment => [
        'Monte a caixa de parto',
        'Mantenha ambiente aquecido (24-26°C)',
        'Tenha número do veterinário à mão',
        'Observe sinais de inquietação',
      ],
      PregnancyStage.term => [
        'Monitore temperatura retal (queda = parto em 24h)',
        'Observe contrações e secreções',
        'Tenha toalhas limpas prontas',
        'Não deixe sozinha por muito tempo',
      ],
      PregnancyStage.overdue => [
        '⚠️ Ligue para o veterinário',
        'Pode ser necessária cesariana',
        'Observe sinais de sofrimento',
      ],
    };
  }

  static List<PregnancyMilestone> _getUpcomingMilestones(
    int currentDays,
    bool isDog,
  ) {
    final allMilestones = isDog ? _dogMilestones : _catMilestones;

    return allMilestones
        .where((m) => m.day > currentDays)
        .take(4)
        .toList();
  }

  static const List<PregnancyMilestone> _dogMilestones = [
    PregnancyMilestone(
      day: 14,
      title: 'Implantação',
      description: 'Embriões se implantam no útero',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 25,
      title: 'Primeiro Ultrassom',
      description: 'Já é possível confirmar a gestação',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 30,
      title: 'Batimentos Cardíacos',
      description: 'Corações dos filhotes começam a bater',
    ),
    PregnancyMilestone(
      day: 40,
      title: 'Segundo Ultrassom',
      description: 'Contagem de filhotes é possível',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 50,
      title: 'Comportamento de Ninho',
      description: 'Mamãe começa a preparar o ninho',
    ),
    PregnancyMilestone(
      day: 58,
      title: 'Monitoramento Intensivo',
      description: 'Parto pode ocorrer a qualquer momento',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 63,
      title: 'Data Prevista',
      description: 'Dia esperado do nascimento',
      isImportant: true,
    ),
  ];

  static const List<PregnancyMilestone> _catMilestones = [
    PregnancyMilestone(
      day: 15,
      title: 'Implantação',
      description: 'Embriões se implantam no útero',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 21,
      title: 'Primeiro Ultrassom',
      description: 'Já é possível confirmar a gestação',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 35,
      title: 'Estruturas Formadas',
      description: 'Estruturas fetais visíveis',
    ),
    PregnancyMilestone(
      day: 45,
      title: 'Segundo Ultrassom',
      description: 'Contagem de gatinhos é possível',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 55,
      title: 'Comportamento de Ninho',
      description: 'Mamãe procura local para o parto',
    ),
    PregnancyMilestone(
      day: 62,
      title: 'Monitoramento Final',
      description: 'Parto pode ocorrer a qualquer momento',
      isImportant: true,
    ),
    PregnancyMilestone(
      day: 67,
      title: 'Data Prevista',
      description: 'Dia esperado do nascimento',
      isImportant: true,
    ),
  ];

  static String getStageText(PregnancyStage stage) {
    return switch (stage) {
      PregnancyStage.implantation => 'Implantação',
      PregnancyStage.earlyDevelopment => 'Desenvolvimento Inicial',
      PregnancyStage.midDevelopment => 'Desenvolvimento Médio',
      PregnancyStage.lateDevelopment => 'Desenvolvimento Final',
      PregnancyStage.term => 'A Termo',
      PregnancyStage.overdue => 'Atrasado',
    };
  }
}
