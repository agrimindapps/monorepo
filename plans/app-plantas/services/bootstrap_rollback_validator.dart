import '../core/bootstrap/bootstrap_state_machine.dart';

class BootstrapRollbackValidator {
  final List<TransactionCommand> _executedCommands = [];

  void registerCommand(TransactionCommand command) {
    _executedCommands.add(command);
  }

  Future<void> rollback() async {
    for (var command in _executedCommands.reversed) {
      try {
        // Implementar lógica de rollback se necessário
        await command.execute();
      } catch (e) {
        // Log do erro de rollback, mas continue
        print('Erro no rollback do comando: ${command.description}');
      }
    }
  }

  void clear() {
    _executedCommands.clear();
  }
}