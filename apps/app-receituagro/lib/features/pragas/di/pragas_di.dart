import 'package:core/core.dart';

import '../../../core/data/repositories/pragas_hive_repository.dart';
import '../data/repositories/pragas_repository_impl.dart';
import '../data/services/pragas_query_service.dart';
import '../data/services/pragas_search_service.dart';
import '../data/services/pragas_stats_service.dart';
import '../domain/repositories/i_pragas_repository.dart';
import '../domain/usecases/get_pragas_usecase.dart';

/// Configuração de Dependency Injection para o módulo de Pragas
///
/// SOLID Refactoring:
/// - Registers specialized services (Query, Search, Stats)
/// - Follows the pattern established in diagnosticos, defensivos, and comentarios features
/// - Improves testability through dependency injection
///
/// Princípio: Dependency Inversion
class PragasDI {
  static void configure() {
    final sl = GetIt.instance;

    // Register specialized services
    if (!sl.isRegistered<IPragasQueryService>()) {
      sl.registerSingleton<IPragasQueryService>(PragasQueryService());
    }

    if (!sl.isRegistered<IPragasSearchService>()) {
      sl.registerSingleton<IPragasSearchService>(PragasSearchService());
    }

    if (!sl.isRegistered<IPragasStatsService>()) {
      sl.registerSingleton<IPragasStatsService>(PragasStatsService());
    }

    // Register repository with service dependencies
    sl.registerLazySingleton<IPragasRepository>(
      () => PragasRepositoryImpl(
        sl<PragasHiveRepository>(),
        sl<IPragasQueryService>(),
        sl<IPragasSearchService>(),
        sl<IPragasStatsService>(),
      ),
    );
    
    sl.registerLazySingleton<IPragasHistoryRepository>(
      () => PragasHistoryRepositoryImpl(sl<PragasHiveRepository>()),
    );
    
    sl.registerLazySingleton<IPragasFormatter>(
      () => PragasFormatterImpl(),
    );
    sl.registerLazySingleton<GetPragasUseCase>(
      () => GetPragasUseCase(repository: sl()),
    );
    
    sl.registerLazySingleton<GetPragasByTipoUseCase>(
      () => GetPragasByTipoUseCase(repository: sl()),
    );
    
    sl.registerLazySingleton<GetPragaByIdUseCase>(
      () => GetPragaByIdUseCase(
        repository: sl(),
        historyRepository: sl(),
      ),
    );
    
    sl.registerLazySingleton<GetPragasByCulturaUseCase>(
      () => GetPragasByCulturaUseCase(repository: sl()),
    );
    
    sl.registerLazySingleton<SearchPragasUseCase>(
      () => SearchPragasUseCase(repository: sl()),
    );
    
    sl.registerLazySingleton<GetRecentPragasUseCase>(
      () => GetRecentPragasUseCase(historyRepository: sl()),
    );
    
    sl.registerLazySingleton<GetSuggestedPragasUseCase>(
      () => GetSuggestedPragasUseCase(historyRepository: sl()),
    );
    
    sl.registerLazySingleton<GetPragasStatsUseCase>(
      () => GetPragasStatsUseCase(repository: sl()),
    );
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
