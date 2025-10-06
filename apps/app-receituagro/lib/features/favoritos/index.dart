// Core exports - Simplified favoritos system
export 'constants/favoritos_design_tokens.dart';
// Model exports
export 'data/favorito_defensivo_model.dart';
export 'data/favorito_diagnostico_model.dart';
export 'data/favorito_praga_model.dart';
export 'data/favoritos_data.dart';
export 'data/view_mode.dart';
// Domain exports
export 'domain/entities/favorito_entity.dart';
// Service exports (active services only)
export 'domain/favoritos_cache_service.dart';
export 'domain/favoritos_data_service.dart' hide IFavoritosRepository;
export 'domain/favoritos_hive_repository.dart';
export 'domain/favoritos_navigation_service.dart';
export 'domain/repositories/i_favoritos_repository.dart';
export 'favoritos_di.dart';
export 'favoritos_page.dart';
// Presentation exports
export 'presentation/providers/favoritos_provider_simplified.dart';
export 'presentation/widgets/favoritos_tabs_widget.dart';
// Widget exports
export 'widgets/defensivo_favorito_list_item.dart';
export 'widgets/diagnostico_favorito_list_item.dart';
export 'widgets/empty_state_widget.dart';
export 'widgets/enhanced_favorite_button.dart';
export 'widgets/enhanced_loading_states.dart';
export 'widgets/praga_favorito_list_item.dart';
