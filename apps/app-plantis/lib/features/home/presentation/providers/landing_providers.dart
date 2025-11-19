import 'package:core/core.dart' hide Column;

import '../../data/datasources/landing_content_datasource.dart';
import '../../data/repositories/landing_auth_repository_impl.dart';
import '../../data/repositories/landing_content_repository_impl.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/entities/landing_content.dart';
import '../../domain/repositories/auth_status_repository.dart';
import '../../domain/repositories/landing_content_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_landing_content_usecase.dart';

part 'landing_providers.g.dart';

// ============================================================================
// DataSource Providers
// ============================================================================

/// Provider for LandingContentDataSource
@riverpod
LandingContentDataSource landingContentDataSource(
  LandingContentDataSourceRef ref,
) {
  return LandingContentDataSource();
}

// ============================================================================
// Repository Providers
// ============================================================================

/// Provider for LandingAuthRepository
///
/// Bridges the core auth system with the landing feature
/// Note: Uses getIt minimal dependency - this is the bridge point
@riverpod
LandingAuthRepository landingAuthRepository(LandingAuthRepositoryRef ref) {
  // Minimal GetIt usage - only to get core auth repository
  // Consider moving this to a core provider in the future
  final coreAuthRepository = getIt<IAuthRepository>();
  return LandingAuthRepositoryImpl(coreAuthRepository: coreAuthRepository);
}

/// Provider for LandingContentRepository
@riverpod
LandingContentRepository landingContentRepository(
  LandingContentRepositoryRef ref,
) {
  final dataSource = ref.watch(landingContentDataSourceProvider);
  return LandingContentRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for CheckAuthStatusUseCase
@riverpod
CheckAuthStatusUseCase checkAuthStatusUseCase(CheckAuthStatusUseCaseRef ref) {
  final repository = ref.watch(landingAuthRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
}

/// Provider for GetLandingContentUseCase
@riverpod
GetLandingContentUseCase getLandingContentUseCase(
  GetLandingContentUseCaseRef ref,
) {
  final repository = ref.watch(landingContentRepositoryProvider);
  return GetLandingContentUseCase(repository);
}

// ============================================================================
// Feature Providers
// ============================================================================

/// Provider for landing authentication status
///
/// Returns current auth status as [LandingAuthStatus]
@riverpod
Future<LandingAuthStatus> landingAuthStatus(LandingAuthStatusRef ref) async {
  final useCase = ref.watch(checkAuthStatusUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => const LandingAuthStatus.unauthenticated(),
    (status) => status,
  );
}

/// Provider for landing authentication status stream
///
/// Watches for changes in authentication status
@riverpod
Stream<LandingAuthStatus> landingAuthStatusStream(
  LandingAuthStatusStreamRef ref,
) {
  final useCase = ref.watch(checkAuthStatusUseCaseProvider);
  return useCase.watch();
}

/// Provider for landing page content
///
/// Returns [LandingContent] with hero, features, and CTA sections
@riverpod
Future<LandingContent> landingContent(LandingContentRef ref) async {
  final useCase = ref.watch(getLandingContentUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => LandingContent.defaultContent(),
    (content) => content,
  );
}
