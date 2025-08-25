// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/volume_sanguineo_controller.dart';
import '../formatters/secure_input_formatter.dart';
import '../utils/debounce_helper.dart';
import 'info_dialog.dart';

class VolumeSanguineoInputForm extends StatefulWidget {
  const VolumeSanguineoInputForm({super.key});

  @override
  State<VolumeSanguineoInputForm> createState() =>
      _VolumeSanguineoInputFormState();
}

class _VolumeSanguineoInputFormState extends State<VolumeSanguineoInputForm> {
  late FocusNode _dropdownFocusNode;
  String? _securityAlert; // 🔒 ISSUE #3: Armazena alertas de segurança

  // 🚀 ISSUE #5: Debounce para validação de entrada
  late DebounceHelper _validationDebouncer;
  ValidationResult _weightValidationState = ValidationResult.none;
  bool _focusListenerAdded = false; // Para controlar se já adicionou o listener

  @override
  void initState() {
    super.initState();
    _dropdownFocusNode = FocusNode();
    _validationDebouncer =
        DebounceHelper(delay: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _dropdownFocusNode.dispose();
    _validationDebouncer.dispose();
    super.dispose();
  }

  /// 🔒 ISSUE #3: Callback para alertas de segurança
  void _onSecurityAlert(String alert) {
    setState(() {
      _securityAlert = alert;
    });

    // Remove alerta após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _securityAlert = null;
        });
      }
    });
  }

  /// 🚀 ISSUE #5: Validação com debounce para o campo de peso
  void _onWeightChanged(String value, VolumeSanguineoController controller) {
    // Marca como pendente imediatamente
    setState(() {
      _weightValidationState = ValidationResult.pending;
    });

    // Cancela validação anterior e agenda nova
    _validationDebouncer.run(() {
      if (!mounted) return;

      _performWeightValidation(value, controller);
    });
  }

  /// 🚀 ISSUE #5: Executa validação do peso
  void _performWeightValidation(
      String value, VolumeSanguineoController controller) {
    if (value.isEmpty) {
      setState(() {
        _weightValidationState = ValidationResult.none;
      });
      return;
    }

    // Usa o serviço de validação existente
    final validationError = controller.validationService.validatePeso(value);

    setState(() {
      if (validationError != null) {
        _weightValidationState = ValidationResult.invalid(validationError);
      } else {
        _weightValidationState = ValidationResult.valid;
      }
    });
  }

  /// 🚀 ISSUE #5: Validação imediata ao perder foco (melhor UX)
  void _onWeightFocusLost(VolumeSanguineoController controller) {
    final value = controller.model.pesoController.text;
    if (value.isNotEmpty) {
      _validationDebouncer.cancel(); // Cancela debounce e valida imediatamente
      _performWeightValidation(value, controller);
    }
  }

  /// 🚀 ISSUE #5: Limpa estado de validação quando limpar campos
  void _clearValidationState() {
    setState(() {
      _weightValidationState = ValidationResult.none;
    });
    _validationDebouncer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VolumeSanguineoController>();
    final isDark = ThemeManager().isDark.value;

    return Focus(
      onKeyEvent: (node, event) => _handleKeyEvent(event, controller),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              // 🔒 ISSUE #3: Exibe alertas de segurança
              if (_securityAlert != null) _buildSecurityAlert(),
              _buildGeneroSelector(context, controller, isDark),
              _buildPesoInput(controller, isDark),
              _buildButtons(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles keyboard shortcuts and navigation
  /// Issue #10: Implementa navegação por teclado completa
  KeyEventResult _handleKeyEvent(
      KeyEvent event, VolumeSanguineoController controller) {
    if (event is KeyDownEvent) {
      // Enter key - Calculate from any field
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        controller.calcular();
        return KeyEventResult.handled;
      }

      // Escape key - Clear fields
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        controller.limpar();
        return KeyEventResult.handled;
      }

      // F1 key - Show info dialog
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        VolumeSanguineoInfoDialog.show(context);
        return KeyEventResult.handled;
      }

      // Ctrl+S - Share results (if calculated)
      if (event.logicalKey == LogicalKeyboardKey.keyS &&
          HardwareKeyboard.instance.isControlPressed) {
        if (controller.isCalculated) {
          controller.compartilhar();
        }
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// 🔒 ISSUE #3: Widget para exibir alertas de segurança
  Widget _buildSecurityAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _securityAlert!,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'Informe os valores para o cálculo',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ShadcnStyle.textColor,
        ),
      ),
    );
  }

  Widget _buildGeneroSelector(
    BuildContext context,
    VolumeSanguineoController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<Map<String, dynamic>>(
          focusNode: _dropdownFocusNode,
          decoration: InputDecoration(
            labelText: 'Tipo de Pessoa',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: controller.model.generoDef,
          items: controller.model.generos.map((item) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: item,
              child: Text(
                item['text'] as String,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateGenero(value);
              // Move focus to weight field after selection
              controller.model.weightFocus.requestFocus();
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPesoInput(VolumeSanguineoController controller, bool isDark) {
    // 🚀 ISSUE #5: Adiciona listener uma única vez para validação ao perder foco
    if (!_focusListenerAdded) {
      controller.model.weightFocus.addListener(() {
        if (!controller.model.weightFocus.hasFocus) {
          _onWeightFocusLost(controller);
        }
      });
      _focusListenerAdded = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VTextField(
          labelText: 'Peso (kg)',
          hintText: 'Ex: 70,5',
          focusNode: controller.model.weightFocus,
          txEditController: controller.model.pesoController,
          prefixIcon: Icon(
            Icons.monitor_weight_outlined,
            color: isDark ? Colors.blue.shade300 : Colors.blue,
          ),
          // 🔒 ISSUE #3: Usa formatter com validação de segurança
          inputFormatters: [
            SecurePesoInputFormatter(
              onSecurityAlert: _onSecurityAlert,
            ),
          ],
          // 🚀 ISSUE #5: Adiciona validação com debounce
          onChanged: (value) => _onWeightChanged(value, controller),
          showClearButton: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        // 🚀 ISSUE #5: Indicador visual de validação
        _buildValidationIndicator(),
      ],
    );
  }

  /// 🚀 ISSUE #5: Constrói indicador visual de validação
  Widget _buildValidationIndicator() {
    if (_weightValidationState.state == ValidationState.none) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Row(
        children: [
          _buildValidationIcon(),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _getValidationMessage(),
              style: TextStyle(
                color: _getValidationColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚀 ISSUE #5: Ícone de acordo com o estado de validação
  Widget _buildValidationIcon() {
    switch (_weightValidationState.state) {
      case ValidationState.pending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        );
      case ValidationState.valid:
        return Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.green.shade600,
        );
      case ValidationState.invalid:
        return Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red.shade600,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 🚀 ISSUE #5: Mensagem de acordo com o estado
  String _getValidationMessage() {
    switch (_weightValidationState.state) {
      case ValidationState.pending:
        return 'Validando...';
      case ValidationState.valid:
        return 'Valor válido';
      case ValidationState.invalid:
        return _weightValidationState.message ?? 'Valor inválido';
      default:
        return '';
    }
  }

  /// 🚀 ISSUE #5: Cor de acordo com o estado
  Color _getValidationColor() {
    switch (_weightValidationState.state) {
      case ValidationState.pending:
        return Colors.grey.shade600;
      case ValidationState.valid:
        return Colors.green.shade600;
      case ValidationState.invalid:
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildButtons(
    BuildContext context,
    VolumeSanguineoController controller,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {
              controller.limpar();
              _clearValidationState(); // 🚀 ISSUE #5: Limpa estado de validação
            },
            icon: const Icon(Icons.refresh_outlined, size: 18),
            label: const Text('Limpar'),
            style: ShadcnStyle.textButtonStyle,
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () => controller.calcular(),
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: const Text('Calcular'),
            style: ShadcnStyle.primaryButtonStyle,
          ),
        ],
      ),
    );
  }
}
