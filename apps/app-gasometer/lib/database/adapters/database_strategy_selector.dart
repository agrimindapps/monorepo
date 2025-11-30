import 'package:flutter/foundation.dart';
import 'database_adapter.dart';

/// Estratégia para selecionar o melhor backend de dados por plataforma
///
/// **Lógica:**
/// - **Web (kIsWeb)**: Usa Firestore (suportado nativamente na web)
/// - **Mobile/Desktop**: Usa Drift com SQLite local (melhor performance offline)
///
/// **Vantagens:**
/// - ✅ Web: Sem dependências WASM complexas, Firestore com sync automático
/// - ✅ Mobile: SQLite robusto com offline-first garantido
/// - ✅ Fallback automático: Firestore usado como remote para ambas plataformas
class DatabaseStrategySelector {
  /// Seleciona a estratégia de banco mais apropriada
  ///
  /// **Retorna:**
  /// - `Firestore` para web (kIsWeb = true)
  /// - `Drift` para mobile/desktop
  static IDatabaseAdapter selectStrategy() {
    if (kIsWeb) {
      return const FirestoreDatabaseAdapter();
    }
    return const DriftDatabaseAdapter();
  }

  /// Verifica se a plataforma atual suporta Drift
  ///
  /// Drift pode falhar em web com erro WASM, portanto
  /// deve ser evitado em kIsWeb
  static bool isDriftSupported() {
    return !kIsWeb;
  }

  /// Verifica se a plataforma atual suporta Firestore
  ///
  /// Firestore é suportado em todas as plataformas
  /// e é a escolha segura para web
  static bool isFirestoreSupported() {
    return true;
  }

  /// Log de debug da estratégia selecionada
  static void logStrategyInfo() {
    final strategy = selectStrategy();
    final isDriftOk = isDriftSupported();
    final isFirestoreOk = isFirestoreSupported();

    print('📊 Database Strategy Selection:');
    print('   Platform: ${kIsWeb ? "WEB" : "MOBILE/DESKTOP"}');
    print('   Selected: ${strategy.name}');
    print('   Drift Support: ${isDriftOk ? "✅" : "❌"}');
    print('   Firestore Support: ${isFirestoreOk ? "✅" : "❌"}');
  }
}
