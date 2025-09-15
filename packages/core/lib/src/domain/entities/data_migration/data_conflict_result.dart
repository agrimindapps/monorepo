import 'anonymous_data.dart';
import 'account_data.dart';
import 'data_resolution_choice.dart';

/// Result of data conflict detection between anonymous and existing account data
/// 
/// This class encapsulates the results of comparing anonymous user data
/// with existing account data to determine if conflicts exist and what
/// actions are available to the user.
class DataConflictResult {
  const DataConflictResult({
    required this.hasConflict,
    required this.anonymousData,
    required this.accountData,
    this.conflictDetails = const {},
    this.recommendedChoice,
    this.availableChoices = const [
      DataResolutionChoice.keepAccountData,
      DataResolutionChoice.keepAnonymousData,
      DataResolutionChoice.cancel,
    ],
  });

  /// Whether a conflict was detected between anonymous and account data
  final bool hasConflict;
  
  /// The anonymous user's data
  final AnonymousData? anonymousData;
  
  /// The existing account's data
  final AccountData? accountData;
  
  /// Detailed information about specific conflicts found
  final Map<String, dynamic> conflictDetails;
  
  /// System recommendation for conflict resolution (optional)
  final DataResolutionChoice? recommendedChoice;
  
  /// Available choices for the user to resolve the conflict
  final List<DataResolutionChoice> availableChoices;

  /// Whether both data sources have significant data
  bool get hasTwoWayConflict => 
      (anonymousData?.hasSignificantData ?? false) && 
      (accountData?.hasSignificantData ?? false);

  /// Whether only anonymous data exists
  bool get hasOnlyAnonymousData => 
      (anonymousData?.hasSignificantData ?? false) && 
      !(accountData?.hasSignificantData ?? false);

  /// Whether only account data exists  
  bool get hasOnlyAccountData => 
      !(anonymousData?.hasSignificantData ?? false) && 
      (accountData?.hasSignificantData ?? false);

  /// Whether no data exists in either source
  bool get hasNoData => 
      !(anonymousData?.hasSignificantData ?? false) && 
      !(accountData?.hasSignificantData ?? false);

  /// Get conflict severity level
  ConflictSeverity get severity {
    if (!hasConflict) return ConflictSeverity.none;
    if (hasNoData) return ConflictSeverity.none;
    if (hasOnlyAnonymousData || hasOnlyAccountData) return ConflictSeverity.low;
    return ConflictSeverity.high;
  }

  /// Get a human-readable description of the conflict
  String get conflictDescription {
    if (!hasConflict) return 'Nenhum conflito detectado.';
    
    if (hasNoData) {
      return 'Não há dados em nenhuma das contas.';
    }
    
    if (hasOnlyAnonymousData) {
      return 'Apenas dados anônimos encontrados. Você pode migrar estes dados para a sua conta.';
    }
    
    if (hasOnlyAccountData) {
      return 'Apenas dados da conta existente encontrados. Os dados serão mantidos.';
    }
    
    if (hasTwoWayConflict) {
      final anonCount = anonymousData?.recordCount ?? 0;
      final accountCount = accountData?.recordCount ?? 0;
      return 'Conflito detectado: dados anônimos ($anonCount registros) e dados da conta ($accountCount registros) encontrados.';
    }
    
    return 'Conflito de dados detectado.';
  }

  /// Get recommended action text
  String? get recommendedActionText {
    if (recommendedChoice == null) return null;
    
    switch (recommendedChoice!) {
      case DataResolutionChoice.keepAccountData:
        return 'Recomendamos manter os dados da sua conta existente.';
      case DataResolutionChoice.keepAnonymousData:
        return 'Recomendamos criar uma nova conta com os dados anônimos.';
      case DataResolutionChoice.cancel:
        return 'Recomendamos cancelar esta operação.';
    }
  }

  /// Create a copy with updated fields
  DataConflictResult copyWith({
    bool? hasConflict,
    AnonymousData? anonymousData,
    AccountData? accountData,
    Map<String, dynamic>? conflictDetails,
    DataResolutionChoice? recommendedChoice,
    List<DataResolutionChoice>? availableChoices,
  }) {
    return DataConflictResult(
      hasConflict: hasConflict ?? this.hasConflict,
      anonymousData: anonymousData ?? this.anonymousData,
      accountData: accountData ?? this.accountData,
      conflictDetails: conflictDetails ?? this.conflictDetails,
      recommendedChoice: recommendedChoice ?? this.recommendedChoice,
      availableChoices: availableChoices ?? this.availableChoices,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'has_conflict': hasConflict,
      'anonymous_data': anonymousData?.toJson(),
      'account_data': accountData?.toJson(),
      'conflict_details': conflictDetails,
      'recommended_choice': recommendedChoice?.name,
      'available_choices': availableChoices.map((c) => c.name).toList(),
      'severity': severity.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataConflictResult &&
           other.hasConflict == hasConflict &&
           other.anonymousData == anonymousData &&
           other.accountData == accountData;
  }

  @override
  int get hashCode => hasConflict.hashCode ^ 
                     anonymousData.hashCode ^ 
                     accountData.hashCode;
}

/// Severity levels for data conflicts
enum ConflictSeverity {
  /// No conflict detected
  none,
  
  /// Minor conflict - can be easily resolved
  low,
  
  /// Significant conflict - requires user decision
  high;

  /// Display name for the severity level
  String get displayName {
    switch (this) {
      case ConflictSeverity.none:
        return 'Nenhum';
      case ConflictSeverity.low:
        return 'Baixo';
      case ConflictSeverity.high:
        return 'Alto';
    }
  }

  /// Color indicator for UI
  String get colorIndicator {
    switch (this) {
      case ConflictSeverity.none:
        return 'green';
      case ConflictSeverity.low:
        return 'orange';
      case ConflictSeverity.high:
        return 'red';
    }
  }
}