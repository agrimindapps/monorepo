/// Módulo de Cadastro de Veículos
///
/// Este arquivo exporta todos os componentes públicos do módulo
/// de cadastro de veículos, seguindo padrão barrel export.
library;

// Controllers e lógica de negócio
export 'controller/veiculos_cadastro_form_controller.dart';
// Models e estruturas de dados
export 'models/veiculos_cadastro_form_model.dart';
export 'models/veiculos_constants.dart';
// Services especializados (arquitetura separada por responsabilidades)
export 'services/index.dart';
export 'views/veiculos_cadastro_form_view.dart';
// Widgets e componentes de UI
export 'widgets/veiculos_cadastro_widget.dart';
