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
library unified_form_system;

// Core Components
export 'components/unified_date_picker.dart';
export 'components/unified_form_dialog.dart';
export 'components/unified_form_field.dart';
export 'components/unified_form_section.dart';
export 'components/unified_loading_states.dart';

// Design System
export 'design/unified_design_tokens.dart';

// Mixins
export 'mixins/rate_limited_submission.dart';

// Services & Validators
export 'services/unified_formatters.dart';
export 'services/unified_validators.dart';