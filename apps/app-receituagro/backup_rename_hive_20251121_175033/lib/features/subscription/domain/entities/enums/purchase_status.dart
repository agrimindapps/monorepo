/// Purchase status enum
enum PurchaseStatus {
  pending, // Purchase is pending
  completed, // Purchase completed successfully
  failed, // Purchase failed
  cancelled, // Purchase was cancelled
  refunded, // Purchase was refunded
  processing, // Payment is being processed
  unknown; // Unknown status

  bool get isPending => this == PurchaseStatus.pending;
  bool get isCompleted => this == PurchaseStatus.completed;
  bool get isFailed => this == PurchaseStatus.failed;
  bool get isRefunded => this == PurchaseStatus.refunded;
  bool get isSuccessful =>
      [PurchaseStatus.completed, PurchaseStatus.refunded].contains(this);
  bool get isTerminal =>
      ![PurchaseStatus.pending, PurchaseStatus.processing].contains(this);

  String get displayName {
    switch (this) {
      case PurchaseStatus.pending:
        return 'Pendente';
      case PurchaseStatus.completed:
        return 'Completado';
      case PurchaseStatus.failed:
        return 'Falhou';
      case PurchaseStatus.cancelled:
        return 'Cancelado';
      case PurchaseStatus.refunded:
        return 'Reembolsado';
      case PurchaseStatus.processing:
        return 'Processando';
      case PurchaseStatus.unknown:
        return 'Desconhecido';
    }
  }
}
