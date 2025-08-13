// Flutter imports:
import 'package:flutter/material.dart';

/// Widget otimizado para estado de loading
class LoadingStateWidget extends StatelessWidget {
  final String message;
  
  const LoadingStateWidget({
    super.key,
    this.message = 'Carregando...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

/// Widget otimizado para SizedBox pequeno
class SmallGap extends StatelessWidget {
  const SmallGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 4, width: 4);
  }
}

/// Widget otimizado para SizedBox padrão
class DefaultGap extends StatelessWidget {
  const DefaultGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8, width: 8);
  }
}

/// Widget otimizado para SizedBox médio
class MediumGap extends StatelessWidget {
  const MediumGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16, width: 16);
  }
}

/// Widget otimizado para SizedBox grande
class LargeGap extends StatelessWidget {
  const LargeGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 24, width: 24);
  }
}

/// Widget otimizado para CircularProgressIndicator
class OptimizedProgressIndicator extends StatelessWidget {
  const OptimizedProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

/// Widget otimizado para ícones comuns
class ErrorIcon extends StatelessWidget {
  const ErrorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.error_outline,
      size: 64,
      color: Colors.red,
    );
  }
}

/// Widget otimizado para botão de refresh
class RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const RefreshButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh),
      label: const Text('Tentar Novamente'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Widget otimizado para texto monoespaçado
class MonospaceText extends StatelessWidget {
  final String text;
  
  const MonospaceText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    );
  }
}

/// Widget de container com constraints otimizado
class ConstrainedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const ConstrainedContainer({
    super.key,
    required this.child,
    this.maxWidth = 1120,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Factory para widgets otimizados baseados em condições
class OptimizedWidgetFactory {
  /// Cria um SizedBox otimizado baseado no tamanho
  static Widget gap(double size) {
    if (size <= 4) return const SmallGap();
    if (size <= 8) return const DefaultGap();
    if (size <= 16) return const MediumGap();
    if (size <= 24) return const LargeGap();
    return SizedBox(height: size, width: size);
  }
  
  /// Cria um widget de loading otimizado
  static Widget loading([String? message]) {
    return LoadingStateWidget(
      message: message ?? 'Carregando...',
    );
  }
  
  /// Cria um container com constraints otimizado
  static Widget constrainedContainer({
    required Widget child,
    double maxWidth = 1120,
  }) {
    return ConstrainedContainer(
      maxWidth: maxWidth,
      child: child,
    );
  }
}
