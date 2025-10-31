import '../../features/livestock/data/models/livestock_enums_adapter.dart';
import '../../features/markets/data/models/market_enums_adapter.dart';

/// Registra todos os adapters Hive do app-agrihurbi
///
/// IMPORTANTE: Chamar APÓS Hive.initFlutter() e ANTES de abrir qualquer box
///
/// ⚠️ TEMPORARIAMENTE DESABILITADO: Adapters Hive removidos devido a conflito
/// com riverpod_generator (incompatibilidade de versões do analyzer).
/// App usa apenas persistência remota (Supabase/Firebase).
void registerAgrihurbiHiveAdapters() {
  // TODO: Implementar adapters manuais ou migrar para Hive 3.x

  // Registra apenas enum adapters (não dependem de code generation)
  registerLivestockEnumAdapters();
  registerMarketAdapters();

  print('⚠️  AgriHurbi Hive Adapters registration SKIPPED');
  print('   - Using remote storage only (Supabase/Firebase)');
  print('   - Enum Adapters: Livestock (5) + Market (2) registered');
}
