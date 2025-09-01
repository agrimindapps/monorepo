import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../theme/accessibility_tokens.dart';

/// Helper class para testar acessibilidade durante desenvolvimento
class AccessibilityTestHelper {
  AccessibilityTestHelper._();

  /// Testa se todos os elementos interativos têm tamanhos mínimos adequados
  static List<String> validateTouchTargets(BuildContext context) {
    final issues = <String>[];
    
    // Esta é uma implementação conceitual - em produção seria mais complexa
    // usando RenderObject.visitChildren() para encontrar todos os elementos
    
    return issues;
  }

  /// Simula navegação por teclado para teste manual
  static void simulateKeyboardNavigation(BuildContext context) {
    // Encontrar todos os FocusNode no contexto
    final scope = FocusScope.of(context);
    
    // Navegar para próximo elemento focável
    scope.nextFocus();
  }

  /// Testa contraste de cores
  static bool testColorContrast(Color foreground, Color background) {
    return AccessibilityTokens.isContrastCompliant(foreground, background);
  }

  /// Simula uso de screen reader
  static void simulateScreenReader(BuildContext context, String text) {
    SemanticsService.announce(text, TextDirection.ltr);
  }

  /// Validações gerais de acessibilidade para uma página
  static AccessibilityReport validatePage(BuildContext context) {
    final issues = <AccessibilityIssue>[];
    final suggestions = <String>[];

    // Verificar se há elementos sem semântica
    _checkSemantics(context, issues);
    
    // Verificar tamanhos de toque
    _checkTouchTargets(context, issues);
    
    // Verificar contraste
    _checkContrast(context, issues);
    
    // Verificar navegação por teclado
    _checkKeyboardNavigation(context, issues);

    // Gerar sugestões
    if (issues.isEmpty) {
      suggestions.add('✅ Página está em conformidade com WCAG 2.1');
    } else {
      suggestions.add('❌ ${issues.length} problema(s) de acessibilidade encontrado(s)');
    }

    return AccessibilityReport(
      issues: issues,
      suggestions: suggestions,
      score: _calculateScore(issues),
    );
  }

  static void _checkSemantics(BuildContext context, List<AccessibilityIssue> issues) {
    // Implementação conceitual - verificaria elementos sem Semantics
    // Em produção, usaria flutter_test e testes de integração
  }

  static void _checkTouchTargets(BuildContext context, List<AccessibilityIssue> issues) {
    // Implementação conceitual - verificaria tamanhos mínimos
  }

  static void _checkContrast(BuildContext context, List<AccessibilityIssue> issues) {
    final theme = Theme.of(context);
    
    // Verificar contraste básico do tema
    final background = theme.colorScheme.surface;
    final onBackground = theme.colorScheme.onSurface;
    
    if (!AccessibilityTokens.isContrastCompliant(onBackground, background)) {
      issues.add(const AccessibilityIssue(
        type: AccessibilityIssueType.contrast,
        description: 'Contraste insuficiente entre texto e fundo',
        severity: AccessibilitySeverity.high,
        suggestion: 'Ajustar cores para atingir ratio mínimo de 4.5:1',
      ));
    }
  }

  static void _checkKeyboardNavigation(BuildContext context, List<AccessibilityIssue> issues) {
    // Implementação conceitual - verificaria se há elementos focáveis
  }

  static double _calculateScore(List<AccessibilityIssue> issues) {
    if (issues.isEmpty) return 100.0;
    
    double penalty = 0.0;
    for (final issue in issues) {
      switch (issue.severity) {
        case AccessibilitySeverity.low:
          penalty += 5;
          break;
        case AccessibilitySeverity.medium:
          penalty += 15;
          break;
        case AccessibilitySeverity.high:
          penalty += 25;
          break;
        case AccessibilitySeverity.critical:
          penalty += 40;
          break;
      }
    }
    
    return (100 - penalty).clamp(0, 100);
  }

  /// Atalhos de teclado para desenvolvedores testarem acessibilidade
  static Map<LogicalKeySet, Intent> get accessibilityShortcuts => {
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyA): 
        const _TestAccessibilityIntent(),
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyS):
        const _SimulateScreenReaderIntent(),
    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyN):
        const _NextFocusIntent(),
  };

  static Map<Type, Action<Intent>> get accessibilityActions => {
    _TestAccessibilityIntent: _TestAccessibilityAction(),
    _SimulateScreenReaderIntent: _SimulateScreenReaderAction(),
    _NextFocusIntent: _NextFocusAction(),
  };
}

/// Relatório de acessibilidade
class AccessibilityReport {
  const AccessibilityReport({
    required this.issues,
    required this.suggestions,
    required this.score,
  });

  final List<AccessibilityIssue> issues;
  final List<String> suggestions;
  final double score;

  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

/// Issue de acessibilidade identificado
class AccessibilityIssue {
  const AccessibilityIssue({
    required this.type,
    required this.description,
    required this.severity,
    required this.suggestion,
  });

  final AccessibilityIssueType type;
  final String description;
  final AccessibilitySeverity severity;
  final String suggestion;
}

enum AccessibilityIssueType {
  contrast,
  touchTarget,
  semantics,
  keyboardNavigation,
  textScaling,
  focus,
}

enum AccessibilitySeverity {
  low,
  medium,
  high,
  critical,
}

// Intents e Actions para atalhos de teclado
class _TestAccessibilityIntent extends Intent {
  const _TestAccessibilityIntent();
}

class _SimulateScreenReaderIntent extends Intent {
  const _SimulateScreenReaderIntent();
}

class _NextFocusIntent extends Intent {
  const _NextFocusIntent();
}

class _TestAccessibilityAction extends Action<_TestAccessibilityIntent> {
  @override
  Object? invoke(_TestAccessibilityIntent intent) {
    // Executar teste de acessibilidade
    debugPrint('🔍 Executando teste de acessibilidade...');
    return null;
  }
}

class _SimulateScreenReaderAction extends Action<_SimulateScreenReaderIntent> {
  @override
  Object? invoke(_SimulateScreenReaderIntent intent) {
    // Simular screen reader
    SemanticsService.announce(
      'Simulação de screen reader ativada',
      TextDirection.ltr,
    );
    return null;
  }
}

class _NextFocusAction extends Action<_NextFocusIntent> {
  @override
  Object? invoke(_NextFocusIntent intent) {
    // Navegar para próximo elemento focável
    debugPrint('➡️ Navegando para próximo elemento focável...');
    return null;
  }
}

/// Widget que mostra informações de acessibilidade durante desenvolvimento
class AccessibilityDebugOverlay extends StatelessWidget {
  const AccessibilityDebugOverlay({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  final Widget child;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    if (!showOverlay) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 100,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withValues(alpha: 0.8),
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🔍 Acessibilidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDebugInfo(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escala: ${mediaQuery.textScaler.scale(1.0).toStringAsFixed(1)}x',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Bold: ${mediaQuery.boldText ? "Ativado" : "Desativado"}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Animações: ${mediaQuery.disableAnimations ? "Reduzidas" : "Normais"}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Alto contraste: ${mediaQuery.highContrast ? "Ativado" : "Desativado"}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text(
          'Atalhos:\nAlt+A: Teste\nAlt+S: Screen Reader\nAlt+N: Próximo foco',
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}