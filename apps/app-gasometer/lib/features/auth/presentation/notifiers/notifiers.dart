/// Riverpod Notifiers para Auth Feature
///
/// Este arquivo exporta todos os notifiers migrados para Riverpod v2.
/// Utiliza code generation com @riverpod para type-safety e performance.
///
/// Padrão:
/// - State classes com valores primitivos (sem TextEditingController)
/// - Notifier classes com @riverpod annotation
/// - Controllers gerenciados internamente (disposal automático)
/// - Use cases injetados via GetIt
library;

export 'login_form_notifier.dart';
export 'login_form_state.dart';
export 'social_login_notifier.dart';
export 'social_login_state.dart';
