// Ponto de entrada do módulo Detalhes de Diagnóstico
// Exports organizados por categoria para melhor manutenibilidade

// Core - Bindings e Controller
export 'bindings/detalhes_diagnostico_bindings.dart';
// Constants
export 'constants/diagnostico_performance_constants.dart';
export 'controller/detalhes_diagnostico_controller.dart';
// Interfaces
export 'interfaces/i_database_repository.dart';
export 'interfaces/i_local_storage_service.dart';
export 'interfaces/i_premium_service.dart';
export 'interfaces/i_tts_service.dart';
// Models
export 'models/diagnostic_data.dart';
export 'models/diagnostico_details_model.dart';
export 'models/loading_state.dart';
// Services
export 'services/database_repository_impl.dart';
export 'services/diagnostico_performance_service.dart';
export 'services/local_storage_service_impl.dart';
export 'services/premium_service_impl.dart';
export 'services/tts_service_impl.dart';
export 'views/components/diagnostico_app_bar.dart';
export 'views/components/premium_card.dart';
// Views
export 'views/detalhes_diagnostico_page.dart';
export 'views/sections/application_section.dart';
export 'views/sections/header_section.dart';
export 'views/sections/image_section.dart';
export 'views/sections/info_section.dart';
// Widgets
export 'widgets/application_tabs.dart';
export 'widgets/favorite_button.dart';
export 'widgets/font_size_controls.dart';
export 'widgets/info_box.dart';
export 'widgets/loading_state_widget.dart';
export 'widgets/share_button.dart';
