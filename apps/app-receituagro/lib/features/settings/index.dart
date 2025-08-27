// Main pages
export 'config_page.dart';
export 'settings_page.dart';

// Constants
export 'constants/settings_design_tokens.dart';

// Data layer
export 'data/repositories/user_settings_repository_impl.dart';

// Dependency Injection
export 'di/settings_di.dart';

// Domain layer
export 'domain/entities/user_settings_entity.dart';
export 'domain/exceptions/settings_exceptions.dart';
export 'domain/repositories/i_user_settings_repository.dart';
// Note: Use cases não são exportados para evitar duplicação de exceções
// Importe diretamente quando necessário

// Integration
export 'settings_integration_example.dart';

// Legacy exports (for backwards compatibility)
export 'models/settings_state.dart';

// Presentation layer
export 'presentation/providers/settings_provider.dart';
export 'presentation/providers/user_settings_provider.dart';

// Providers (legacy)
export 'providers/settings_providers.dart';

// Sections (legacy)
export 'sections/desenvolvimento_section.dart';
export 'sections/publicidade_section.dart';
export 'sections/site_access_section.dart';
export 'sections/sobre_section.dart';
export 'sections/speech_to_text_section.dart';

// Services (legacy)
export 'services/device_service.dart';
export 'services/navigation_service.dart';
export 'services/premium_service.dart';
export 'services/theme_service.dart';

// Widgets - Refactored Components
export 'widgets/sections/about_section.dart';
export 'widgets/sections/app_info_section.dart';
export 'widgets/sections/development_section.dart';
export 'widgets/sections/notifications_section.dart';
export 'widgets/sections/premium_section.dart';
export 'widgets/sections/support_section.dart';

// Widgets - Shared Components
export 'widgets/shared/section_header.dart';
export 'widgets/shared/settings_card.dart';
export 'widgets/shared/settings_list_tile.dart';

// Widgets (legacy)
export 'widgets/section_title_widget.dart';