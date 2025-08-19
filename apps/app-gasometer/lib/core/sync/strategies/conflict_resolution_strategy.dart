/// Estratégias para resolução de conflitos de sincronização
enum ConflictResolutionStrategy {
  /// Dados locais sempre ganham
  localWins,

  /// Dados remotos sempre ganham  
  remoteWins,

  /// O timestamp mais recente ganha
  newerWins,

  /// Merge inteligente baseado no tipo de modelo
  merge,

  /// Resolução manual pelo usuário (TODO)
  manual,

  /// Prioriza versão com maior número
  versionWins,

  /// Estratégia customizada por feature
  custom
}

extension ConflictResolutionStrategyExtension on ConflictResolutionStrategy {
  String get displayName {
    switch (this) {
      case ConflictResolutionStrategy.localWins:
        return 'Manter dados locais';
      case ConflictResolutionStrategy.remoteWins:
        return 'Usar dados remotos';
      case ConflictResolutionStrategy.newerWins:
        return 'Mais recente ganha';
      case ConflictResolutionStrategy.merge:
        return 'Combinar dados';
      case ConflictResolutionStrategy.manual:
        return 'Resolução manual';
      case ConflictResolutionStrategy.versionWins:
        return 'Maior versão ganha';
      case ConflictResolutionStrategy.custom:
        return 'Estratégia customizada';
    }
  }

  String get description {
    switch (this) {
      case ConflictResolutionStrategy.localWins:
        return 'Sempre mantém os dados que estão armazenados localmente';
      case ConflictResolutionStrategy.remoteWins:
        return 'Sempre usa os dados vindos do servidor remoto';
      case ConflictResolutionStrategy.newerWins:
        return 'Compara timestamps e mantém o dado mais recente';
      case ConflictResolutionStrategy.merge:
        return 'Combina dados de forma inteligente baseado no modelo';
      case ConflictResolutionStrategy.manual:
        return 'Permite ao usuário escolher como resolver o conflito';
      case ConflictResolutionStrategy.versionWins:
        return 'Compara números de versão e mantém o maior';
      case ConflictResolutionStrategy.custom:
        return 'Usa lógica personalizada para cada tipo de dado';
    }
  }

  bool get requiresUserInput {
    return this == ConflictResolutionStrategy.manual;
  }
}