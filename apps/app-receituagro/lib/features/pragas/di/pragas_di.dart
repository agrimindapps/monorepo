import 'package:core/core.dart' hide Column;

import '../../../database/repositories/pragas_repository.dart';
import '../data/repositories/pragas_repository_impl.dart';
import '../data/services/pragas_error_message_service.dart';
import '../data/services/pragas_query_service.dart';
import '../data/services/pragas_search_service.dart';
import '../data/services/pragas_stats_service.dart';
import '../data/services/pragas_type_service.dart';
import '../domain/repositories/i_pragas_repository.dart';
import '../domain/services/i_pragas_error_message_service.dart';
import '../domain/services/i_pragas_query_service.dart';
import '../domain/services/i_pragas_search_service.dart';
import '../domain/services/i_pragas_stats_service.dart';
import '../domain/services/i_pragas_type_service.dart';

/// Configuração de Dependency Injection para o módulo de Pragas
///
/// SOLID Refactoring:
/// - Registers specialized services (Query, Search, Stats)
/// - Follows the pattern established in diagnosticos, defensivos, and comentarios features
/// - Improves testability through dependency injection
///
/// Princípio: Dependency Inversion
class PragasDI {
  const PragasDI._();
  static void configure() {
    final sl = GetIt.instance;

    // Register specialized services (Data Layer)
    if (!sl.isRegistered<IPragasQueryService>()) {
      sl.registerSingleton<IPragasQueryService>(PragasQueryService());
    }

    if (!sl.isRegistered<IPragasSearchService>()) {
      sl.registerSingleton<IPragasSearchService>(PragasSearchService());
    }

    if (!sl.isRegistered<IPragasStatsService>()) {
      sl.registerSingleton<IPragasStatsService>(PragasStatsService());
    }

    // Register domain services (now with interface)
    if (!sl.isRegistered<IPragasErrorMessageService>()) {
      sl.registerSingleton<IPragasErrorMessageService>(
        PragasErrorMessageService(),
      );
    }

    if (!sl.isRegistered<IPragasTypeService>()) {
      sl.registerSingleton<IPragasTypeService>(PragasTypeService());
    }

    // Register repository with service dependencies
    sl.registerLazySingleton<IPragasRepository>(
      () => PragasRepositoryImpl(
        sl<PragasRepository>(),
        sl<IPragasQueryService>(),
        sl<IPragasSearchService>(),
        sl<IPragasStatsService>(),
        sl<IPragasErrorMessageService>(),
      ),
    );

    sl.registerLazySingleton<IPragasHistoryRepository>(
      () => PragasHistoryRepositoryImpl(
        sl<PragasRepository>(),
        sl<IPragasErrorMessageService>(),
      ),
    );

    sl.registerLazySingleton<IPragasFormatter>(() => PragasFormatterImpl());
  }
}

/// Exemplo de uso no main.dart:
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Configurar DI dos módulos
///   PragasDI.configure();
///   // OutroModuloDI.configure();
///   
///   runApp(MyApp());
/// }
/// ```
/// 
/// Exemplo de uso na UI:
/// 
/// ```dart
/// class PragasPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ChangeNotifierProvider.value(
///       value: GetIt.instance<PragasProvider>(),
///       child: Consumer<PragasProvider>(
///         builder: (context, provider, child) {
///           if (provider.isLoading) {
///             return CircularProgressIndicator();
///           }
///           
///           return ListView.builder(
///             itemCount: provider.pragas.length,
///             itemBuilder: (context, index) {
///               final praga = provider.pragas[index];
///               return ListTile(
///                 title: Text(praga.nomeFormatado),
///                 subtitle: Text(praga.nomeCientifico),
///                 onTap: () => provider.selectPragaById(praga.idReg),
///               );
///             },
///           );
///         },
///       ),
///     );
///   }
/// }
/// ```
