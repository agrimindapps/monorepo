import 'package:get/get.dart';

import '../core/bootstrap/bootstrap_state_machine.dart';

class BootstrapTransactionManager extends GetxController {
  final RxList<TransactionCommand> _pendingTransactions = <TransactionCommand>[].obs;
  final RxList<TransactionCommand> _completedTransactions = <TransactionCommand>[].obs;
  final Rx<BootstrapPhase> currentPhase = BootstrapPhase.initial.obs;

  /// Adicionar transação à fila
  void addTransaction(TransactionCommand transaction) {
    _pendingTransactions.add(transaction);
  }

  /// Executar todas as transações pendentes
  Future<void> executeTransactions() async {
    while (_pendingTransactions.isNotEmpty) {
      final transaction = _pendingTransactions.removeAt(0);
      
      try {
        await transaction.execute();
        _completedTransactions.add(transaction);
      } catch (e) {
        // Tratamento de erro na transação
        print('Erro na transação: ${transaction.description}');
        currentPhase.value = BootstrapPhase.error;
        rethrow;
      }
    }
    
    currentPhase.value = BootstrapPhase.complete;
  }

  /// Verificar progresso das transações
  double get transactionProgress {
    final total = _pendingTransactions.length + _completedTransactions.length;
    return total > 0 
      ? _completedTransactions.length / total 
      : 1.0;
  }

  /// Limpar todas as transações
  void reset() {
    _pendingTransactions.clear();
    _completedTransactions.clear();
    currentPhase.value = BootstrapPhase.initial;
  }
}