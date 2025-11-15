import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';
import 'i_diagnosticos_metadata_repository.dart';
import 'i_diagnosticos_query_repository.dart';
import 'i_diagnosticos_read_repository.dart';
import 'i_diagnosticos_recommendation_repository.dart';
import 'i_diagnosticos_search_repository.dart';
import 'i_diagnosticos_stats_repository.dart';
import 'i_diagnosticos_validation_repository.dart';

/// @deprecated Use specialized repository interfaces instead:
/// - IDiagnosticosReadRepository
/// - IDiagnosticosQueryRepository
/// - IDiagnosticosSearchRepository
/// - IDiagnosticosStatsRepository
/// - IDiagnosticosMetadataRepository
/// - IDiagnosticosValidationRepository
/// - IDiagnosticosRecommendationRepository
///
/// This interface is maintained for backward compatibility only.
/// It combines all 7 specialized interfaces following Interface Segregation Principle (SOLID).
/// New code should inject only the specific repository interface it needs.
///
/// REFACTORED (Phase 4): 30+ methods split into 7 specialized interfaces
/// to reduce coupling and improve testability.
abstract class IDiagnosticosRepository
    implements
        IDiagnosticosReadRepository,
        IDiagnosticosQueryRepository,
        IDiagnosticosSearchRepository,
        IDiagnosticosStatsRepository,
        IDiagnosticosMetadataRepository,
        IDiagnosticosValidationRepository,
        IDiagnosticosRecommendationRepository {}
