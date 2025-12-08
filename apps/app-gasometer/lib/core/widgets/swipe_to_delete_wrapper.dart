import 'package:flutter/material.dart';

/// Widget reutilizável para exclusão com swipe + undo
///
/// Envolve um item de lista e adiciona funcionalidade de swipe-to-delete
/// com SnackBar de undo.
///
/// Exemplo de uso:
/// ```dart
/// SwipeToDeleteWrapper(
///   itemKey: 'vehicle_${vehicle.id}',
///   deletedMessage: 'Veículo excluído',
///   onDelete: () => notifier.removeOptimistic(vehicle.id),
///   onRestore: () => notifier.restore(vehicle.id),
///   child: VehicleCard(vehicle: vehicle),
/// )
/// ```
class SwipeToDeleteWrapper extends StatelessWidget {
  const SwipeToDeleteWrapper({
    super.key,
    required this.itemKey,
    required this.deletedMessage,
    required this.onDelete,
    required this.onRestore,
    required this.child,
    this.undoDuration = const Duration(seconds: 5),
    this.confirmDismiss,
    this.enabled = true,
  });

  /// Chave única para o item (usado no Dismissible)
  final String itemKey;

  /// Mensagem exibida no SnackBar após exclusão
  final String deletedMessage;

  /// Callback executado quando o item é excluído (swipe completo)
  final Future<void> Function() onDelete;

  /// Callback executado quando o usuário clica em "Desfazer"
  final Future<void> Function() onRestore;

  /// Widget filho (o item da lista)
  final Widget child;

  /// Duração do SnackBar antes da exclusão permanente
  final Duration undoDuration;

  /// Callback opcional para confirmar a exclusão
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  /// Se o swipe está habilitado
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Dismissible(
      key: ValueKey(itemKey),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.4},
      confirmDismiss: confirmDismiss,
      onDismissed: (_) => _handleDismiss(context),
      background: const _DeleteBackground(),
      child: child,
    );
  }

  Future<void> _handleDismiss(BuildContext context) async {
    // Executa a exclusão otimista
    await onDelete();

    if (!context.mounted) return;

    // Mostra SnackBar com opção de desfazer
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deletedMessage),
        duration: undoDuration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () async {
            await onRestore();
          },
        ),
      ),
    );
  }
}

/// Background vermelho com ícone de lixeira para o swipe
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

/// Extensão para facilitar a criação de SwipeToDeleteWrapper
extension SwipeToDeleteWrapperX on Widget {
  /// Envolve o widget com SwipeToDeleteWrapper
  Widget withSwipeToDelete({
    required String itemKey,
    required String deletedMessage,
    required Future<void> Function() onDelete,
    required Future<void> Function() onRestore,
    Duration undoDuration = const Duration(seconds: 5),
    bool enabled = true,
  }) {
    return SwipeToDeleteWrapper(
      itemKey: itemKey,
      deletedMessage: deletedMessage,
      onDelete: onDelete,
      onRestore: onRestore,
      undoDuration: undoDuration,
      enabled: enabled,
      child: this,
    );
  }
}
