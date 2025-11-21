// Barrel file para widgets de comentários
//
// Este arquivo re-exporta todos os widgets modulares.
//
// Arquivo refatorado de comentarios_page.dart (927 linhas)
// em 4 módulos menores para melhor manutenibilidade:
// - comentarios_helpers.dart (~45 linhas) - Helpers de formatação
// - comentarios_empty_state_widget.dart (~50 linhas) - Empty state
// - comentario_card_widget.dart (~180 linhas) - Card individual
// - add_comment_dialog_widget.dart (~450 linhas) - Dialog completo

export 'add_comment_dialog_widget.dart';
export 'comentario_card_widget.dart';
export 'comentarios_empty_state_widget.dart';
export 'comentarios_helpers.dart';
