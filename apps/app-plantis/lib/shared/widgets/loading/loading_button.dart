import 'package:flutter/material.dart';

/// Botão com estados de loading integrados que resolve problemas de UX
/// identificados na análise de feedback visual insuficiente
class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;
  final Widget child;
  final Widget? loadingChild;
  final String? loadingText;
  final bool isLoading;
  final bool disabled;
  final ButtonStyle? style;
  final LoadingButtonType type;
  final Duration animationDuration;
  final bool showSuccessIndicator;
  final Duration successDuration;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final String? semanticLabel;

  const LoadingButton({
    super.key,
    this.onPressed,
    this.onPressedAsync,
    required this.child,
    this.loadingChild,
    this.loadingText,
    this.isLoading = false,
    this.disabled = false,
    this.style,
    this.type = LoadingButtonType.elevated,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showSuccessIndicator = false,
    this.successDuration = const Duration(milliseconds: 2000),
    this.onSuccess,
    this.onError,
    this.semanticLabel,
  }) : assert(
         onPressed != null || onPressedAsync != null,
         'Either onPressed or onPressedAsync must be provided',
       );

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isInternalLoading = false;
  bool _showSuccess = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLoading => widget.isLoading || _isInternalLoading;
  bool get _isDisabled => widget.disabled || _isLoading;

  void _handlePress() async {
    if (_isDisabled) return;

    // Animate button press
    await _controller.forward();
    await _controller.reverse();

    try {
      if (widget.onPressedAsync != null) {
        setState(() {
          _isInternalLoading = true;
          _showError = false;
        });

        await widget.onPressedAsync!();

        if (widget.showSuccessIndicator) {
          setState(() => _showSuccess = true);
          widget.onSuccess?.call();

          await Future<void>.delayed(widget.successDuration);

          if (mounted) {
            setState(() => _showSuccess = false);
          }
        }
      } else {
        widget.onPressed?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showError = true;
        });
        widget.onError?.call();

        // Auto-hide error after 2 seconds
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _showError = false);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isInternalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !_isDisabled,
      label: widget.semanticLabel ?? _getSemanticLabel(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _isDisabled ? 0.6 : _opacityAnimation.value,
              child: _buildButton(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.type) {
      case LoadingButtonType.elevated:
        return ElevatedButton(
          onPressed: _isDisabled ? null : _handlePress,
          style: widget.style,
          child: _buildButtonChild(),
        );
      case LoadingButtonType.outlined:
        return OutlinedButton(
          onPressed: _isDisabled ? null : _handlePress,
          style: widget.style,
          child: _buildButtonChild(),
        );
      case LoadingButtonType.text:
        return TextButton(
          onPressed: _isDisabled ? null : _handlePress,
          style: widget.style,
          child: _buildButtonChild(),
        );
      case LoadingButtonType.filled:
        return FilledButton(
          onPressed: _isDisabled ? null : _handlePress,
          style: widget.style,
          child: _buildButtonChild(),
        );
      case LoadingButtonType.icon:
        return IconButton(
          onPressed: _isDisabled ? null : _handlePress,
          style: widget.style,
          icon: _buildButtonChild(),
        );
    }
  }

  Widget _buildButtonChild() {
    if (_showSuccess) {
      return const AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
              key: ValueKey('success'),
            ),
            SizedBox(width: 8),
            Text('Sucesso!'),
          ],
        ),
      );
    }

    if (_showError) {
      return const AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 20,
              key: ValueKey('error'),
            ),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
      );
    }

    if (_isLoading) {
      return AnimatedSwitcher(
        duration: widget.animationDuration,
        child: widget.loadingChild ?? _buildDefaultLoading(),
      );
    }

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      child: widget.child,
    );
  }

  Widget _buildDefaultLoading() {
    if (widget.type == LoadingButtonType.icon) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        if (widget.loadingText != null) ...[
          const SizedBox(width: 8),
          Text(widget.loadingText!),
        ],
      ],
    );
  }

  String _getSemanticLabel() {
    if (_showSuccess) return 'Operação realizada com sucesso';
    if (_showError) return 'Erro na operação';
    if (_isLoading) return 'Processando operação';
    return 'Botão para executar ação';
  }
}

/// Tipos de botão disponíveis
enum LoadingButtonType { elevated, outlined, text, filled, icon }

/// Botão específico para operações de salvamento
class SaveButton extends StatelessWidget {
  final Future<void> Function() onSave;
  final String? text;
  final String? loadingText;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool enabled;

  const SaveButton({
    super.key,
    required this.onSave,
    this.text,
    this.loadingText,
    this.onSuccess,
    this.onError,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressedAsync: onSave,
      disabled: !enabled,
      type: LoadingButtonType.elevated,
      showSuccessIndicator: true,
      loadingText: loadingText ?? 'Salvando...',
      onSuccess: onSuccess,
      onError: onError,
      semanticLabel: 'Salvar informações',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.save, size: 18),
          const SizedBox(width: 8),
          Text(text ?? 'Salvar'),
        ],
      ),
    );
  }
}

/// Botão específico para operações de compra
class PurchaseButton extends StatelessWidget {
  final Future<void> Function() onPurchase;
  final String productName;
  final String price;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool enabled;

  const PurchaseButton({
    super.key,
    required this.onPurchase,
    required this.productName,
    required this.price,
    this.onSuccess,
    this.onError,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressedAsync: onPurchase,
      disabled: !enabled,
      type: LoadingButtonType.elevated,
      showSuccessIndicator: true,
      loadingText: 'Processando compra...',
      onSuccess: onSuccess,
      onError: onError,
      semanticLabel: 'Comprar $productName por $price',
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comprar $productName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(price, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botão para operações de sincronização
class SyncButton extends StatelessWidget {
  final Future<void> Function() onSync;
  final String? text;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool enabled;

  const SyncButton({
    super.key,
    required this.onSync,
    this.text,
    this.onSuccess,
    this.onError,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressedAsync: onSync,
      disabled: !enabled,
      type: LoadingButtonType.outlined,
      showSuccessIndicator: true,
      loadingText: 'Sincronizando...',
      onSuccess: onSuccess,
      onError: onError,
      semanticLabel: 'Sincronizar dados',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync, size: 18),
          const SizedBox(width: 8),
          Text(text ?? 'Sincronizar'),
        ],
      ),
    );
  }
}
