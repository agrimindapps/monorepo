// Flutter imports:
import 'package:flutter/material.dart';

/// Widget wrapper que previne problemas de layout infinito
/// Aplica constraints seguras e trata casos extremos
class SafeLayoutWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SafeLayoutWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.maxHeight,
    this.minWidth,
    this.minHeight,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: margin,
      padding: padding,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? screenSize.width,
        maxHeight: maxHeight ?? screenSize.height,
        minWidth: minWidth ?? 0,
        minHeight: minHeight ?? 0,
      ),
      child: child,
    );
  }
}

/// Widget Card que previne problemas de layout
class SafeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final ShapeBorder? shape;

  const SafeCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 1.0,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4.0),
      elevation: elevation,
      color: color,
      shape: shape,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 48.0,
        ),
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

/// Widget que previne overflow de texto
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }
}
