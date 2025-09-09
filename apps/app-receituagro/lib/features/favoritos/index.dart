// Core exports - Simplified favoritos system
export 'constants/favoritos_design_tokens.dart';
export 'favoritos_page.dart';
export 'favoritos_di.dart';

// Domain exports
export 'domain/entities/favorito_entity.dart';
export 'domain/repositories/i_favoritos_repository.dart';

// Model exports
export 'models/favorito_defensivo_model.dart';
export 'models/favorito_diagnostico_model.dart';
export 'models/favorito_praga_model.dart';
export 'models/favoritos_data.dart';
export 'models/view_mode.dart';

// Service exports (active services only)
export 'services/favoritos_cache_service.dart';
export 'services/favoritos_data_service.dart' hide IFavoritosRepository;
export 'services/favoritos_hive_repository.dart';
export 'services/favoritos_navigation_service.dart';

// Widget exports
export 'widgets/defensivo_favorito_list_item.dart';
export 'widgets/diagnostico_favorito_list_item.dart';
export 'widgets/empty_state_widget.dart';
export 'widgets/enhanced_favorite_button.dart';
export 'widgets/enhanced_loading_states.dart';
export 'widgets/praga_favorito_list_item.dart';

// Presentation exports
export 'presentation/pages/favoritos_clean_page.dart';
export 'presentation/providers/favoritos_provider_simplified.dart';
export 'presentation/widgets/favoritos_tabs_widget.dart';