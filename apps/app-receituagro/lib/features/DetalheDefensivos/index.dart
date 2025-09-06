// Export clean architecture components

// Data Layer
export 'data/mappers/diagnostico_mapper.dart';
export 'data/repositories/defensivo_details_repository_impl.dart';

// DI
export 'di/defensivo_details_di.dart';

// Domain Layer
export 'domain/entities/defensivo_details_entity.dart';
export 'domain/entities/diagnostico_entity.dart';
export 'domain/repositories/i_defensivo_details_repository.dart';
export 'domain/usecases/get_defensivo_details_usecase.dart';
export 'domain/usecases/get_diagnosticos_usecase.dart';
export 'domain/usecases/toggle_favorite_usecase.dart';

// Presentation Layer
export 'detalhe_defensivo_page.dart';
export 'presentation/providers/defensivo_details_provider.dart';
export 'presentation/providers/diagnosticos_provider.dart';
export 'presentation/providers/tab_controller_provider.dart';
export 'presentation/widgets/defensivo_info_cards_widget.dart';
export 'presentation/widgets/diagnosticos_tab_widget.dart';
export 'presentation/widgets/optimized_tab_bar_widget.dart';
