// Detalhes Defensivos - Clean Architecture Implementation
//
// Módulo responsável pela visualização detalhada de defensivos agrícolas
// Implementa padrão Clean Architecture com MVC + Services + Use Cases
//
// Funcionalidades principais:
// - Visualização de informações detalhadas de defensivos
// - Sistema de favoritos com persistência
// - Text-to-Speech (TTS) para acessibilidade
// - Diagnóstico e busca de pragas relacionadas
// - Informações de aplicação e classificação
//
// Padrões arquiteturais:
// - Clean Architecture (Domain, Data, Presentation)
// - Dependency Injection via GetX Bindings
// - Interface Segregation Principle
// - Single Responsibility Principle

// === CORE LAYER ===

// === DEPENDENCY INJECTION ===

// Bindings
export 'bindings/detalhes_defensivos_bindings.dart';
// === INFRASTRUCTURE LAYER ===

// Constants
export 'constants/detalhes_defensivos_design_tokens.dart';
// Controllers
export 'controller/detalhes_defensivos_controller.dart';
// === DOMAIN LAYER ===

// Interfaces
export 'interfaces/i_diagnostic_filter_service.dart';
export 'interfaces/i_favorite_service.dart';
export 'interfaces/i_load_defensivo_use_case.dart';
export 'interfaces/i_tts_service.dart';
// Managers
export 'managers/loading_state_manager.dart';
export 'models/aplicacao_model.dart';
// Models
export 'models/defensivo_details_model.dart';
// === DATA LAYER ===

// Services
export 'services/diagnostic_filter_service.dart';
export 'services/favorite_service.dart';
export 'services/tts_service.dart';
// Use Cases
export 'use_cases/load_defensivo_data_use_case.dart';
// Utils
export 'utils/defensivo_formatter.dart';
// Components
export 'views/components/defensivo_app_bar.dart';
export 'views/components/tabs_section.dart';
// === PRESENTATION LAYER ===

// Views
export 'views/detalhes_defensivos_page.dart';
export 'views/tabs/aplicacao_tab.dart';
export 'views/tabs/comentarios_tab.dart';
export 'views/tabs/diagnostico_tab.dart';
// Tabs
export 'views/tabs/informacoes_tab.dart';
// Widgets
export 'widgets/application_info_section.dart';
export 'widgets/classificacao_card_widget.dart';
export 'widgets/diagnostic_item_widget.dart';
export 'widgets/info_card_widget.dart';
