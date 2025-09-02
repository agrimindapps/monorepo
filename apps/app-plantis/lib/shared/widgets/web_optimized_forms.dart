import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'responsive_layout.dart';
import 'web_hover_extensions.dart';

/// Layout otimizado para formulários web
class WebOptimizedFormLayout extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final List<Widget>? actions;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsets padding;
  final double spacing;
  final ScrollPhysics? physics;

  const WebOptimizedFormLayout({
    super.key,
    this.title,
    required this.children,
    this.actions,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.padding = const EdgeInsets.all(24.0),
    this.spacing = 16.0,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: SingleChildScrollView(
        physics: physics,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing * 1.5),
              ],
              ...children.map((child) => Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: child,
                  )),
              if (actions != null) ...[
                SizedBox(height: spacing),
                WebOptimizedFormActions(children: actions!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout para ações do formulário (botões)
class WebOptimizedFormActions extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;

  const WebOptimizedFormActions({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            )).toList(),
      ),
      desktop: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: children.map((child) => Padding(
              padding: EdgeInsets.only(left: spacing),
              child: child,
            )).toList(),
      ),
    );
  }
}

/// Row adaptativo para campos de formulário
class WebOptimizedFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final List<int>? flex;

  const WebOptimizedFormRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: Column(
        children: children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            )).toList(),
      ),
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return SizedBox(width: spacing);
          }
          final childIndex = index ~/ 2;
          final child = children[childIndex];
          final childFlex = flex?[childIndex] ?? 1;
          return Expanded(flex: childFlex, child: child);
        }),
      ),
    );
  }
}

/// TextField otimizado para web
class WebOptimizedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;

  const WebOptimizedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  State<WebOptimizedTextField> createState() => _WebOptimizedTextFieldState();
}

class _WebOptimizedTextFieldState extends State<WebOptimizedTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dropdown otimizado para web
class WebOptimizedDropdown<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const WebOptimizedDropdown({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    ).withHoverPointer();
  }
}

/// Switch otimizado para web
class WebOptimizedSwitch extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const WebOptimizedSwitch({
    super.key,
    this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: title != null ? Text(title!) : null,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: enabled ? onChanged : null,
    ).withHoverPointer();
  }
}

/// Checkbox otimizado para web
class WebOptimizedCheckbox extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const WebOptimizedCheckbox({
    super.key,
    this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: title != null ? Text(title!) : null,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: enabled ? onChanged : null,
      controlAffinity: ListTileControlAffinity.leading,
    ).withHoverPointer();
  }
}

/// Botão otimizado para formulários web
class WebOptimizedFormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  const WebOptimizedFormButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ).withWebHoverFeedback();
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ).withWebHoverFeedback();
    }
  }
}

/// Extension para facilitar uso
extension WebOptimizedFormExtension on List<Widget> {
  /// Converte lista de widgets em formulário otimizado
  Widget toWebOptimizedForm({
    String? title,
    List<Widget>? actions,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    EdgeInsets padding = const EdgeInsets.all(24.0),
    double spacing = 16.0,
    ScrollPhysics? physics,
  }) {
    return WebOptimizedFormLayout(
      title: title,
      actions: actions,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      padding: padding,
      spacing: spacing,
      physics: physics,
      children: this,
    );
  }
}