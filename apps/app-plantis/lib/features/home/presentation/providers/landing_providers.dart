import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
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
  Ref ref,
) {
  return LandingContentDataSource();
}

// ============================================================================
// Repository Providers
// ============================================================================

/// Provider for LandingAuthRepository
///
/// Bridges the core auth system with the landing feature
@riverpod
LandingAuthRepository landingAuthRepository(Ref ref) {
  final coreAuthRepository = ref.watch(authRepositoryProvider);
  return LandingAuthRepositoryImpl(coreAuthRepository: coreAuthRepository);
}

/// Provider for LandingContentRepository
@riverpod
LandingContentRepository landingContentRepository(
  Ref ref,
) {
  final dataSource = ref.watch(landingContentDataSourceProvider);
  return LandingContentRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for CheckAuthStatusUseCase
@riverpod
CheckAuthStatusUseCase checkAuthStatusUseCase(Ref ref) {
  final repository = ref.watch(landingAuthRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
}

/// Provider for GetLandingContentUseCase
@riverpod
GetLandingContentUseCase getLandingContentUseCase(
  Ref ref,
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
Future<LandingAuthStatus> landingAuthStatus(Ref ref) async {
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
  Ref ref,
) {
  final useCase = ref.watch(checkAuthStatusUseCaseProvider);
  return useCase.watch();
}

/// Provider for landing page content
///
/// Returns [LandingContent] with hero, features, and CTA sections
@riverpod
Future<LandingContent> landingContent(Ref ref) async {
  final useCase = ref.watch(getLandingContentUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => LandingContent.defaultContent(),
    (content) => content,
  );
}
