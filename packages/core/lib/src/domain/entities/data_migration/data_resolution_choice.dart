/// Enum representing the user's choice when data conflicts occur during account migration
/// 
/// This enum is used throughout the migration system to track and handle
/// the user's decision on how to resolve data conflicts between anonymous
/// and existing account data.
enum DataResolutionChoice {
  /// User chooses to keep existing account data and discard anonymous data
  /// This will result in complete cleanup of anonymous data (local, server, account deletion)
  keepAccountData,
  
  /// User chooses to keep anonymous data and create a new account
  /// This will guide the user through new account creation process
  keepAnonymousData,
  
  /// User wants to cancel the current operation and remain anonymous
  /// This returns to the previous state without any changes
  cancel;

  /// Human-readable display name for UI
  String get displayName {
    switch (this) {
      case DataResolutionChoice.keepAccountData:
        return 'Manter dados da conta existente';
      case DataResolutionChoice.keepAnonymousData:
        return 'Manter dados anônimos';
      case DataResolutionChoice.cancel:
        return 'Cancelar';
    }
  }

  /// Description of the action that will be performed
  String get description {
    switch (this) {
      case DataResolutionChoice.keepAccountData:
        return 'Os dados anônimos serão permanentemente removidos e substituídos pelos dados da sua conta existente.';
      case DataResolutionChoice.keepAnonymousData:
        return 'Você será direcionado para criar uma nova conta com os dados anônimos atuais.';
      case DataResolutionChoice.cancel:
        return 'Retornar ao estado anterior sem fazer alterações.';
    }
  }

  /// Warning message for destructive actions
  String? get warningMessage {
    switch (this) {
      case DataResolutionChoice.keepAccountData:
        return 'ATENÇÃO: Esta ação não pode ser desfeita. Todos os dados anônimos serão permanentemente perdidos.';
      case DataResolutionChoice.keepAnonymousData:
        return null;
      case DataResolutionChoice.cancel:
        return null;
    }
  }

  /// Whether this choice requires confirmation from the user
  bool get requiresConfirmation {
    switch (this) {
      case DataResolutionChoice.keepAccountData:
        return true;
      case DataResolutionChoice.keepAnonymousData:
        return false;
      case DataResolutionChoice.cancel:
        return false;
    }
  }

  /// Whether this choice is destructive (cannot be undone)
  bool get isDestructive {
    switch (this) {
      case DataResolutionChoice.keepAccountData:
        return true;
      case DataResolutionChoice.keepAnonymousData:
        return false;
      case DataResolutionChoice.cancel:
        return false;
    }
  }
}