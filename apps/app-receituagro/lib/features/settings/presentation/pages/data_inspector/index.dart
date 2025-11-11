// Barrel file para módulos do Data Inspector
//
// Este arquivo re-exporta todos os widgets e services necessários
// para o Data Inspector Page.
//
// Arquivo refatorado de data_inspector_page.dart (964 linhas)
// em 4 módulos menores para melhor manutenibilidade:
// - data_inspector_helpers.dart (~70 linhas) - Helpers de formatação
// - hive_box_loader_service.dart (~110 linhas) - Service de loading
// - shared_prefs_tab_widget.dart (~300 linhas) - Tab SharedPrefs
// - hive_tab_widget.dart (~450 linhas) - Tab HiveBoxes

export 'data_inspector_helpers.dart';
// export 'hive_box_loader_service.dart'; // Temporariamente comentado durante migração
// export 'hive_tab_widget.dart'; // Temporariamente comentado durante migração
export 'shared_prefs_tab_widget.dart';
