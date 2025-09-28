import 'package:core/core.dart';

import '../../../core/repositories/pragas_hive_repository.dart';
import '../data/repositories/pragas_repository_impl.dart';
import '../domain/repositories/i_pragas_repository.dart';
import '../domain/usecases/get_pragas_usecase.dart';
import '../presentation/providers/pragas_provider.dart';

/// Configuração de Dependency Injection para o módulo de Pragas
/// Princípio: Dependency Inversion
class PragasDI {
  static void configure() {
    final sl = GetIt.instance;

    // Repositories
    sl.registerLazySingleton<IPragasRepository>(
      () => PragasRepositoryImpl(sl<PragasHiveRepository>()),
    );
    
    sl.registerLazySingleton<IPragasHistoryRepository>(
      () => PragasHistoryRepositoryImpl(sl<PragasHiveRepository>()),
    );
    
    sl.registerLazySingleton<IPragasFormatter>(
      () => PragasFormatterImpl(),
    );

    // Use Cases
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

    // Providers
    sl.registerLazySingleton<PragasProvider>(
      () => PragasProvider(
        getPragasUseCase: sl(),
        getPragasByTipoUseCase: sl(),
        getPragaByIdUseCase: sl(),
        getPragasByCulturaUseCase: sl(),
        searchPragasUseCase: sl(),
        getRecentPragasUseCase: sl(),
        getSuggestedPragasUseCase: sl(),
        getPragasStatsUseCase: sl(),
      ),
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