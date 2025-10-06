class SubscriptionStatus {
  final bool _isActive;
  final DateTime? _expirationDate;

  const SubscriptionStatus({
    required bool isActive,
    DateTime? expirationDate,
  }) : 
    _isActive = isActive,
    _expirationDate = expirationDate;

  bool get isActive => _isActive &&
    (_expirationDate == null || _expirationDate.isAfter(DateTime.now()));

  DateTime? get expirationDate => _expirationDate;

  factory SubscriptionStatus.free() => const SubscriptionStatus(
    isActive: false,
    expirationDate: null,
  );

  factory SubscriptionStatus.premium() => SubscriptionStatus(
    isActive: true,
    expirationDate: DateTime.now().add(const Duration(days: 30)),
  );
}
