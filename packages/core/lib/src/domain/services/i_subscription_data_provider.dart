import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/subscription_entity.dart';

/// Interface para provedores de dados de subscription
///
/// Permite plugar diferentes fontes de dados para sincronização:
/// - RevenueCat (in-app purchases)
/// - Firebase Firestore (cross-device sync)
/// - Webhooks (instant updates)
/// - Local storage (offline fallback)
///
/// Cada provider tem uma prioridade para resolução de conflitos
abstract class ISubscriptionDataProvider {
  /// Nome identificador do provider
  String get name;

  /// Stream de atualizações desta fonte
  ///
  /// Emite novos valores quando o status muda nesta fonte específica
  Stream<SubscriptionEntity?> get updates;

  /// Fetch manual do status atual
  ///
  /// Força uma busca imediata ignorando cache
  Future<Either<Failure, SubscriptionEntity?>> fetch();

  /// Prioridade para resolução de conflitos (0-100)
  ///
  /// Quando múltiplas fontes retornam dados diferentes, a fonte
  /// com maior prioridade prevalece.
  ///
  /// Valores sugeridos:
  /// - RevenueCat: 100 (fonte da verdade para purchases)
  /// - Firebase: 80 (sync cross-device confiável)
  /// - Webhook: 60 (pode ter delay)
  /// - Local: 40 (fallback offline)
  int get priority;

  /// Se este provider está habilitado
  bool get isEnabled;

  /// Inicializa o provider (setup de listeners, etc)
  Future<void> initialize();

  /// Dispose de recursos
  Future<void> dispose();
}
