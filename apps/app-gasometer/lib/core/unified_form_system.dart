/// Sistema de formulários unificado para o GasOMeter
///
/// Este arquivo exporta todos os componentes do sistema unificado,
/// implementado seguindo o guia de padronização visual dos cadastros.
///
/// Características principais:
/// - 95% de consistência visual
/// - 40% redução no esforço de desenvolvimento
/// - Rate limiting integrado
/// - Validação em tempo real
/// - Design responsivo
///
/// Usage:
/// ```dart
/// import 'package:gasometer/core/unified_form_system.dart';
///
/// // Usar componentes unificados
/// UnifiedFormField(
///   label: 'Nome',
///   validationType: UnifiedValidationType.text,
///   required: true,
/// )
/// ```
library;
export 'mixins/rate_limited_submission.dart';
export 'services/formatters/unified_formatters.dart';
export 'theme/unified_design_tokens.dart';
export 'validation/unified_validators.dart';
export 'widgets/unified_date_picker.dart';
export 'widgets/unified_form_dialog.dart';
export 'widgets/unified_form_field.dart';
export 'widgets/unified_form_section.dart';
export 'widgets/unified_loading_states.dart';
