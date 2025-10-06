import 'package:flutter/material.dart';

/// Extensão para a classe Color que adiciona métodos úteis
extension ColorExtensions on Color {
  /// Retorna uma nova cor com o alpha modificado (compatibilidade)
  /// Usa withValues internamente para manter compatibilidade
  Color withAlphaValue(double alpha) => withValues(alpha: alpha);
}
