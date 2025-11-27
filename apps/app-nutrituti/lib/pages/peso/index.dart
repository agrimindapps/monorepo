// Peso Feature - Weight Tracking Module
//
// Este módulo implementa o controle de peso do usuário com:
// - Registro de peso diário
// - Definição de metas
// - Visualização de progresso
// - Sistema de conquistas
//
// Arquitetura: Clean Architecture com Riverpod 3.0
// Estado: Production Ready

// Controllers
export 'controllers/peso_controller.dart';

// Models
export 'models/peso_model.dart';
export 'models/achievement_model.dart';

// Repository
export 'repository/peso_repository.dart';

// Pages
export 'peso_page.dart';
export 'pages/peso_form_page.dart';
export 'pages/peso_cadastro_page.dart';

// Widgets
export 'widgets/achievements_card_widget.dart';
export 'widgets/meta_card_widget.dart';
export 'widgets/registros_card_widget.dart';
export 'widgets/stat_column_widget.dart';
export 'widgets/tip_card_widget.dart';
