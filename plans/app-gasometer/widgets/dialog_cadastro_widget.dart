// Flutter imports:
import 'package:flutter/material.dart';

class DialogCadastro {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required GlobalKey formKey,
    required Widget Function(Key?) formWidget,
    required VoidCallback onSubmit,
    double? maxHeight = 570.0,
    bool Function()? disableSubmitWhen,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: isSmallScreen ? 16 : 18,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? 420.0 : 500.0,
              maxHeight: maxHeight ?? 570.0,
            ),
            child: AlertDialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              insetPadding: const EdgeInsets.all(0),
              titlePadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
                0,
              ),
              contentPadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                0,
                isSmallScreen ? 12 : 16,
                0,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 12 : 20,
                      0,
                      isSmallScreen ? 12 : 20,
                      5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider()
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: formWidget(formKey),
                ),
              ),
              actionsPadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 18,
                isSmallScreen ? 8 : 12,
                isSmallScreen ? 12 : 18,
                isSmallScreen ? 8 : 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                _AnimatedSaveButton(
                  onPressed: disableSubmitWhen != null && disableSubmitWhen()
                      ? null
                      : onSubmit,
                  onCompleted: () {
                    // This is called after successful save
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSaveButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onCompleted;

  const _AnimatedSaveButton({this.onPressed, this.onCompleted});

  @override
  _AnimatedSaveButtonState createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton>
    with SingleTickerProviderStateMixin {
  ButtonState _state = ButtonState.initial;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasValidationError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AnimatedSaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se o botão estava desabilitado e agora está habilitado, e temos um erro de validação,
    // resetamos o estado do botão
    if (oldWidget.onPressed == null &&
        widget.onPressed != null &&
        _hasValidationError) {
      setState(() {
        _state = ButtonState.initial;
        _hasValidationError = false;
      });
    }
  }

  void _onPressed() async {
    if (_state == ButtonState.initial && widget.onPressed != null) {
      setState(() {
        _state = ButtonState.loading;
      });

      try {
        // Executamos a função onPressed (submit do formulário)
        widget.onPressed!();

        // Aguardar um curto período para ver se houve algum erro de validação
        // que tenha redefinido o estado isLoading do formulário
        await Future.delayed(const Duration(milliseconds: 300));

        // Se o widget não estiver mais montado, não fazemos nada
        if (!mounted) return;

        // Verificamos se o botão ainda deve estar habilitado
        // Se não estiver, significa que houve erro de validação
        if (widget.onPressed == null) {
          setState(() {
            _state = ButtonState.initial;
            _hasValidationError = true;
          });
          return;
        }

        // Para este widget, não assumimos sucesso automaticamente
        // O fechamento do diálogo deve ser controlado pelo próprio submit
        setState(() {
          _state = ButtonState.initial;
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _state = ButtonState.initial;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return TextButton(
      onPressed: isEnabled ? _onPressed : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildButtonChild() {
    switch (_state) {
      case ButtonState.initial:
        return const Text(
          'Salvar',
          key: ValueKey('save'),
        );
      case ButtonState.loading:
        return SizedBox(
          key: const ValueKey('loading'),
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case ButtonState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Salvo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
    }
  }
}

enum ButtonState {
  initial,
  loading,
  success,
}
