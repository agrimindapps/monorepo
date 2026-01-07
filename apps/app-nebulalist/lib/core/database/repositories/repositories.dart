/// Drift Database Repositories - Nebulalist
///
/// **NOTA IMPORTANTE:**
/// Estes repositories são camada de acesso direto ao Drift (database layer).
/// Eles NÃO são os mesmos que os repositories em features/*/data/repositories/.
///
/// **Arquitetura:**
/// - **Core Drift Repos** (aqui): Acesso direto ao DB com Either<Failure, T> pattern
///   - Usados pelos DAOs e operações de baixo nível
///   - Pattern: Either<Failure, T> do core package
///
/// - **Feature Repos** (features/*/data/repositories/): Implementam interfaces do domain
///   - Usados pelos use cases via dependency injection
///   - Pattern: Either<Failure, T> do dartz
///   - Orquestram local + remote datasources
///
/// Ambos coexistem e têm propósitos diferentes na arquitetura.
library;

export 'item_master_repository.dart';
export 'item_repository.dart';
export 'list_repository.dart';
