import 'package:flutter/foundation.dart';

/// Estratégias de resolução de conflitos
enum ConflictStrategy {
  /// Last-Write-Wins: Versão mais recente sempre vence
  lastWriteWins,

  /// Three-Way Merge: Mescla mudanças baseado em versão base
  threeWayMerge,

  /// Server-Wins: Servidor sempre vence
  serverWins,

  /// Client-Wins: Cliente sempre vence
  clientWins,
}

/// Resultado de resolução de conflito
class ConflictResolution<T> {
  final T resolvedValue;
  final bool hadConflict;
  final String? conflictReason;
  final ConflictStrategy strategy;

  const ConflictResolution({
    required this.resolvedValue,
    required this.hadConflict,
    this.conflictReason,
    required this.strategy,
  });
}

/// Serviço de resolução de conflitos para sincronização
///
/// Implementa diferentes estratégias de merge, incluindo Three-Way Merge
/// que é mais inteligente que Last-Write-Wins.
///
/// **Three-Way Merge:**
/// - Compara: Base (última versão sincronizada) vs Local vs Remote
/// - Se Base == Local, mas Remote diferente → usa Remote (sem conflito local)
/// - Se Base == Remote, mas Local diferente → usa Local (sem conflito remoto)
/// - Se todos diferentes → merge inteligente ou usa estratégia de fallback
///
/// **Exemplo:**
/// ```dart
/// final resolver = ConflictResolver<ListModel>();
///
/// final result = resolver.resolve(
///   base: baseVersion,    // Última versão sincronizada
///   local: localVersion,  // Versão local atual
///   remote: remoteVersion, // Versão do servidor
///   strategy: ConflictStrategy.threeWayMerge,
/// );
///
/// if (result.hadConflict) {
///   print('Conflito resolvido: ${result.conflictReason}');
/// }
/// ```
class ConflictResolver<T> {
  /// Compara dois valores para verificar se são iguais
  final bool Function(T a, T b) equals;

  /// Mescla dois valores quando há conflito real
  /// Recebe: (base, local, remote) → merged
  final T Function(T? base, T local, T remote)? merger;

  ConflictResolver({
    required this.equals,
    this.merger,
  });

  /// Resolve conflito entre versões local e remota
  ///
  /// [base] - Versão base (última sincronizada) - opcional para LWW
  /// [local] - Versão local atual
  /// [remote] - Versão remota do servidor
  /// [strategy] - Estratégia de resolução (padrão: threeWayMerge)
  ConflictResolution<T> resolve({
    T? base,
    required T local,
    required T remote,
    ConflictStrategy strategy = ConflictStrategy.threeWayMerge,
  }) {
    switch (strategy) {
      case ConflictStrategy.threeWayMerge:
        return _threeWayMerge(base, local, remote);

      case ConflictStrategy.lastWriteWins:
        return _lastWriteWins(local, remote);

      case ConflictStrategy.serverWins:
        return ConflictResolution(
          resolvedValue: remote,
          hadConflict: !equals(local, remote),
          conflictReason: 'Server-wins strategy',
          strategy: strategy,
        );

      case ConflictStrategy.clientWins:
        return ConflictResolution(
          resolvedValue: local,
          hadConflict: !equals(local, remote),
          conflictReason: 'Client-wins strategy',
          strategy: strategy,
        );
    }
  }

  /// Three-Way Merge implementation
  ConflictResolution<T> _threeWayMerge(T? base, T local, T remote) {
    // Sem versão base - fallback para Last-Write-Wins
    if (base == null) {
      debugPrint('ConflictResolver: No base version, using LWW');
      return _lastWriteWins(local, remote);
    }

    // Caso 1: Nenhuma mudança (base == local == remote)
    if (equals(base, local) && equals(base, remote)) {
      return ConflictResolution(
        resolvedValue: local,
        hadConflict: false,
        strategy: ConflictStrategy.threeWayMerge,
      );
    }

    // Caso 2: Apenas local mudou (base == remote, mas local diferente)
    if (equals(base, remote) && !equals(base, local)) {
      return ConflictResolution(
        resolvedValue: local,
        hadConflict: false,
        conflictReason: 'Only local changed',
        strategy: ConflictStrategy.threeWayMerge,
      );
    }

    // Caso 3: Apenas remote mudou (base == local, mas remote diferente)
    if (equals(base, local) && !equals(base, remote)) {
      return ConflictResolution(
        resolvedValue: remote,
        hadConflict: false,
        conflictReason: 'Only remote changed',
        strategy: ConflictStrategy.threeWayMerge,
      );
    }

    // Caso 4: Ambos mudaram (conflito real!)
    if (!equals(base, local) && !equals(base, remote) && !equals(local, remote)) {
      // Tenta merge customizado se disponível
      if (merger != null) {
        final merged = merger!(base, local, remote);
        return ConflictResolution(
          resolvedValue: merged,
          hadConflict: true,
          conflictReason: 'Both changed, used custom merger',
          strategy: ConflictStrategy.threeWayMerge,
        );
      }

      // Fallback: usa remote (servidor vence em conflitos reais)
      debugPrint('ConflictResolver: Real conflict, no merger, using remote');
      return ConflictResolution(
        resolvedValue: remote,
        hadConflict: true,
        conflictReason: 'Both changed, server wins (no custom merger)',
        strategy: ConflictStrategy.threeWayMerge,
      );
    }

    // Caso 5: local == remote (mesmo que base seja diferente)
    if (equals(local, remote)) {
      return ConflictResolution(
        resolvedValue: local,
        hadConflict: false,
        conflictReason: 'Local and remote converged',
        strategy: ConflictStrategy.threeWayMerge,
      );
    }

    // Fallback inesperado
    debugPrint('ConflictResolver: Unexpected case, using remote');
    return ConflictResolution(
      resolvedValue: remote,
      hadConflict: true,
      conflictReason: 'Unexpected case',
      strategy: ConflictStrategy.threeWayMerge,
    );
  }

  /// Last-Write-Wins implementation
  /// Usa timestamp updatedAt para decidir
  ConflictResolution<T> _lastWriteWins(T local, T remote) {
    // Para LWW, precisamos que T tenha updatedAt
    // Por enquanto, sempre usa remote como default seguro
    // Será sobrescrito nos adapters que conhecem updatedAt

    return ConflictResolution(
      resolvedValue: remote,
      hadConflict: !equals(local, remote),
      conflictReason: 'Last-write-wins (default: remote)',
      strategy: ConflictStrategy.lastWriteWins,
    );
  }
}

/// Resolver especializado para models com timestamp
class TimestampConflictResolver<T> extends ConflictResolver<T> {
  final DateTime Function(T) getUpdatedAt;

  TimestampConflictResolver({
    required super.equals,
    required this.getUpdatedAt,
    super.merger,
  });

  @override
  ConflictResolution<T> _lastWriteWins(T local, T remote) {
    final localTime = getUpdatedAt(local);
    final remoteTime = getUpdatedAt(remote);

    final useRemote = remoteTime.isAfter(localTime);

    return ConflictResolution(
      resolvedValue: useRemote ? remote : local,
      hadConflict: !equals(local, remote),
      conflictReason: useRemote
          ? 'Remote is newer ($remoteTime > $localTime)'
          : 'Local is newer ($localTime > $remoteTime)',
      strategy: ConflictStrategy.lastWriteWins,
    );
  }
}
