import '../../../core/di/injection_container.dart';
import '../data/repositories/defensivo_details_repository_impl.dart';
import '../domain/repositories/i_defensivo_details_repository.dart';

/// Configuração de injeção de dependência para DetalheDefensivos
/// Registra todas as dependências seguindo Clean Architecture
void initDefensivoDetailsDI() {
  sl.registerLazySingleton<IDefensivoDetailsRepository>(
    () => DefensivoDetailsRepositoryImpl(),
  );
}