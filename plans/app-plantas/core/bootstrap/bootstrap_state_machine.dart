enum BootstrapPhase {
  initial,
  configuration,
  authentication,
  dataLoad,
  featureSetup,
  complete,
  error
}

/// Representa um comando transacional durante o bootstrap
class TransactionCommand {
  final String description;
  final Future<void> Function() execute;
  final bool Function()? canExecute;

  const TransactionCommand({
    required this.description,
    required this.execute,
    this.canExecute,
  });
}

/// Gerencia transações de bootstrap para inicialização robusta
class BootstrapTransaction {
  final List<TransactionCommand> commands;
  final void Function(String)? onStepProgress;
  final void Function(dynamic)? onError;

  const BootstrapTransaction({
    required this.commands,
    this.onStepProgress,
    this.onError,
  });

  /// Executa todas as transações na ordem
  Future<void> execute() async {
    for (final command in commands) {
      try {
        if (command.canExecute == null || command.canExecute!()) {
          onStepProgress?.call(command.description);
          await command.execute();
        }
      } catch (e) {
        onError?.call(e);
        rethrow;
      }
    }
  }
}