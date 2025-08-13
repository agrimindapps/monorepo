// Este arquivo é o ponto de entrada principal para o módulo de Lista de Defensivos Agrupados.
// Exporta todos os componentes, controladores, modelos, views e utilitários necessários
// para o funcionamento deste módulo, incluindo utilitários avançados de monitoramento.

// Core - Componentes principais do módulo (Bindings, Controller, Página)
export 'bindings/lista_defensivos_agrupados_bindings.dart';
/// UiConstants - Constantes de interface do usuário (dimensões, estilos, etc.)
/// AlphaConstants - Constantes de transparência para cores
/// ResponsiveConstants - Breakpoints de responsividade
/// PerformanceConstants - Configurações de performance e timeouts
/// MonitoringConstants - Configurações de monitoramento
export 'config/ui_constants.dart';
export 'controller/lista_defensivos_agrupados_controller.dart';
// Data Models - Modelos para as estruturas de dados
export 'models/defensivo_item_model.dart';
// State Management - Modelos relacionados ao gerenciamento de estado
export 'models/defensivos_state.dart';
export 'models/view_mode.dart';
/// MonitoringService - Service dedicado para monitoramento de recursos e memória
/// Abstrai e centraliza toda a lógica de tracking e cleanup de recursos
export 'services/monitoring_service.dart';
// Standard Utilities - Utilitários padrão e helpers
export 'utils/defensivos_category.dart';
export 'utils/defensivos_helpers.dart';
export 'utils/defensivos_page_config.dart';
/// MemoryMonitor - Monitor de memória para detectar vazamentos
/// Captura snapshots periódicos e detecta tendências de crescimento suspeitas
export 'utils/memory_monitor.dart';
/// ResourceTracker - Utilitário para rastrear e gerenciar recursos ativos
/// Previne memory leaks registrando controllers, listeners e workers
export 'utils/resource_tracker.dart';
// UI Components - Widgets reutilizáveis e genéricos da UI
export 'views/components/defensivos_app_bar.dart';
export 'views/components/empty_result_message.dart';
export 'views/components/loading_indicator.dart';
export 'views/lista_defensivos_agrupados_page.dart';
// UI Widgets - Widgets específicos para apresentação da lista de defensivos
export 'views/widgets/defensivo_grid_item.dart';
export 'views/widgets/defensivo_list_item.dart';
export 'views/widgets/defensivos_grid_view.dart';
export 'views/widgets/defensivos_list_view.dart';
