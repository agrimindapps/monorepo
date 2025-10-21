// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/controllers/independencia_financeira_controller.dart';
import 'package:app_calculei/services/validacao_service.dart';
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/utils/rebuild_optimizer.dart';

/// Widget otimizado para campos de entrada que evita rebuilds desnecessários
class OptimizedInputWidget extends StatefulWidget {
  final IndependenciaFinanceiraController controller;
  final String fieldKey;
  final String label;
  final String hint;
  final TextEditingController textController;
  final List<TextInputFormatter> formatters;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const OptimizedInputWidget({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.textController,
    required this.formatters,
    required this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<OptimizedInputWidget> createState() => _OptimizedInputWidgetState();
}

class _OptimizedInputWidgetState extends State<OptimizedInputWidget> 
    with RebuildOptimizationMixin {
  
  List<ResultadoValidacao> _lastValidations = [];
  bool _lastHasErrors = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentValidations = widget.controller.getValidacoesCampo(widget.fieldKey);
    final currentHasErrors = widget.controller.temErros;

    // Só rebuilda se validações mudaram
    if (_shouldRebuildValidations(currentValidations, currentHasErrors)) {
      _lastValidations = currentValidations;
      _lastHasErrors = currentHasErrors;
      setShouldRebuild(true);
    }
  }

  bool _shouldRebuildValidations(
    List<ResultadoValidacao> currentValidations,
    bool currentHasErrors,
  ) {
    // Rebuilda se status de erro mudou
    if (currentHasErrors != _lastHasErrors) {
      return true;
    }

    // Rebuilda se número de validações mudou
    if (currentValidations.length != _lastValidations.length) {
      return true;
    }

    // Rebuilda se conteúdo das validações mudou
    for (int i = 0; i < currentValidations.length; i++) {
      if (currentValidations[i].mensagem != _lastValidations[i].mensagem ||
          currentValidations[i].tipo != _lastValidations[i].tipo) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final validations = widget.controller.getValidacoesCampo(widget.fieldKey);
    final hasFieldErrors = validations.any((v) => v.tipo == TipoValidacao.erro);
    
    return IsolatedWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de texto com cache
          CachedWidget(
            dependencies: [
              widget.label,
              widget.hint,
              hasFieldErrors,
            ],
            builder: (context) => _buildTextField(context, hasFieldErrors),
          ),
          
          // Validações com cache
          if (validations.isNotEmpty)
            CachedWidget(
              dependencies: [
                validations.map((v) => '${v.mensagem}_${v.tipo}').join('|'),
              ],
              builder: (context) => _buildValidations(context, validations),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool hasErrors) {
    return RepaintBoundary(
      child: TextField(
        controller: widget.textController,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: widget.suffixIcon,
          border: const OutlineInputBorder(),
          errorBorder: hasErrors ? const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ) : null,
          focusedErrorBorder: hasErrors ? const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ) : null,
        ),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.formatters,
      ),
    );
  }

  Widget _buildValidations(BuildContext context, List<ResultadoValidacao> validations) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: validations.map((validation) {
          return _ValidationMessage(
            validation: validation,
            key: ValueKey('${validation.mensagem}_${validation.tipo}'),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget isolado para mensagem de validação
class _ValidationMessage extends StatelessWidget {
  final ResultadoValidacao validation;

  const _ValidationMessage({
    super.key,
    required this.validation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              validation.tipo == TipoValidacao.erro 
                  ? Icons.error_outline 
                  : Icons.warning_amber_outlined,
              size: 16,
              color: validation.tipo == TipoValidacao.erro 
                  ? Colors.red 
                  : Colors.orange,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                validation.mensagem,
                style: TextStyle(
                  fontSize: 12,
                  color: validation.tipo == TipoValidacao.erro 
                      ? Colors.red 
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget otimizado para seção de campos
class OptimizedInputSection extends StatefulWidget {
  final IndependenciaFinanceiraController controller;
  final String title;
  final List<Widget> children;

  const OptimizedInputSection({
    super.key,
    required this.controller,
    required this.title,
    required this.children,
  });

  @override
  State<OptimizedInputSection> createState() => _OptimizedInputSectionState();
}

class _OptimizedInputSectionState extends State<OptimizedInputSection> 
    with RebuildOptimizationMixin {
  
  bool _lastCalculando = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentCalculando = widget.controller.calculando;
    
    // Só rebuilda se status de cálculo mudou
    if (currentCalculando != _lastCalculando) {
      _lastCalculando = currentCalculando;
      setShouldRebuild(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IsolatedWidget(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título com cache
              CachedWidget(
                dependencies: [widget.title],
                builder: (context) => Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Campos filhos
              ...widget.children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: child,
              )),
              
              // Indicador de carregamento
              if (widget.controller.calculando)
                const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget otimizado para botões de ação
class OptimizedActionButtons extends StatefulWidget {
  final IndependenciaFinanceiraController controller;

  const OptimizedActionButtons({
    super.key,
    required this.controller,
  });

  @override
  State<OptimizedActionButtons> createState() => _OptimizedActionButtonsState();
}

class _OptimizedActionButtonsState extends State<OptimizedActionButtons> 
    with RebuildOptimizationMixin {
  
  bool _lastCalculando = false;
  bool _lastTemErros = false;
  bool _lastCalculoAutomatico = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentCalculando = widget.controller.calculando;
    final currentTemErros = widget.controller.temErros;
    final currentCalculoAutomatico = widget.controller.calculoAutomatico;

    // Só rebuilda se estados relevantes mudaram
    if (currentCalculando != _lastCalculando ||
        currentTemErros != _lastTemErros ||
        currentCalculoAutomatico != _lastCalculoAutomatico) {
      _lastCalculando = currentCalculando;
      _lastTemErros = currentTemErros;
      _lastCalculoAutomatico = currentCalculoAutomatico;
      setShouldRebuild(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IsolatedWidget(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Botão calcular
            Expanded(
              child: ElevatedButton(
                onPressed: widget.controller.calculando || widget.controller.temErros
                    ? null
                    : widget.controller.calcular,
                child: widget.controller.calculando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Calcular'),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Botão limpar
            OutlinedButton(
              onPressed: widget.controller.calculando 
                  ? null 
                  : widget.controller.limpar,
              child: const Text('Limpar'),
            ),
            
            const SizedBox(width: 12),
            
            // Toggle cálculo automático
            IconButton(
              onPressed: widget.controller.toggleCalculoAutomatico,
              icon: Icon(
                widget.controller.calculoAutomatico 
                    ? Icons.auto_mode 
                    : Icons.refresh,
              ),
              tooltip: widget.controller.calculoAutomatico 
                  ? 'Desativar cálculo automático'
                  : 'Ativar cálculo automático',
            ),
          ],
        ),
      ),
    );
  }
}
