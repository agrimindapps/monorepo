import 'dart:async';

import 'package:flutter/material.dart';

/// Indicador específico para operações de salvamento com feedback visual
/// Resolve problemas identificados na análise UX de falta de feedback durante saves
class SaveIndicator extends StatefulWidget {
  final bool isSaving;
  final bool hasUnsavedChanges;
  final VoidCallback? onSave;
  final String? saveText;
  final String? savingText;
  final String? savedText;
  final SaveIndicatorStyle style;
  final Duration autoHideDuration;
  final Widget? customIcon;

  const SaveIndicator({
    super.key,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.onSave,
    this.saveText,
    this.savingText,
    this.savedText,
    this.style = SaveIndicatorStyle.chip,
    this.autoHideDuration = const Duration(seconds: 2),
    this.customIcon,
  });

  @override
  State<SaveIndicator> createState() => _SaveIndicatorState();
}

class _SaveIndicatorState extends State<SaveIndicator>
    with TickerProviderStateMixin {
  late AnimationController _saveController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _showSaved = false;

  @override
  void initState() {
    super.initState();

    _saveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _saveController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.hasUnsavedChanges) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaving && !widget.isSaving) {
      _onSaveCompleted();
    }
    if (widget.hasUnsavedChanges != oldWidget.hasUnsavedChanges) {
      if (widget.hasUnsavedChanges) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _saveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSaveCompleted() async {
    await _saveController.forward();
    setState(() => _showSaved = true);
    await Future<void>.delayed(widget.autoHideDuration);

    if (mounted) {
      setState(() => _showSaved = false);
      await _saveController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case SaveIndicatorStyle.chip:
        return _buildChipStyle();
      case SaveIndicatorStyle.button:
        return _buildButtonStyle();
      case SaveIndicatorStyle.icon:
        return _buildIconStyle();
      case SaveIndicatorStyle.banner:
        return _buildBannerStyle();
    }
  }

  Widget _buildChipStyle() {
    if (!widget.hasUnsavedChanges && !widget.isSaving && !_showSaved) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_saveController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: _buildChip(),
        );
      },
    );
  }

  Widget _buildChip() {
    final theme = Theme.of(context);

    if (_showSaved) {
      return Chip(
        avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
        label: Text(widget.savedText ?? 'Salvo!'),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        side: const BorderSide(color: Colors.green),
      );
    }

    if (widget.isSaving) {
      return Chip(
        avatar: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        label: Text(widget.savingText ?? 'Salvando...'),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        side: BorderSide(color: theme.colorScheme.primary),
      );
    }

    return ActionChip(
      avatar: widget.customIcon ?? const Icon(Icons.save, size: 18),
      label: Text(widget.saveText ?? 'Alterações não salvas'),
      onPressed: widget.onSave,
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
      side: const BorderSide(color: Colors.orange),
    );
  }

  Widget _buildButtonStyle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildSaveButton(),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);

    if (_showSaved) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        label: Text(widget.savedText ?? 'Salvo!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          foregroundColor: Colors.green,
        ),
      );
    }

    if (widget.isSaving) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(widget.savingText ?? 'Salvando...'),
      );
    }

    return ElevatedButton.icon(
      onPressed: widget.hasUnsavedChanges ? widget.onSave : null,
      icon: widget.customIcon ?? const Icon(Icons.save),
      label: Text(widget.saveText ?? 'Salvar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.hasUnsavedChanges
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildIconStyle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildSaveIcon(),
    );
  }

  Widget _buildSaveIcon() {
    if (_showSaved) {
      return Semantics(
        label: 'Alterações salvas com sucesso',
        child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
      );
    }

    if (widget.isSaving) {
      return Semantics(
        label: 'Salvando alterações',
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.hasUnsavedChanges) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Semantics(
              button: true,
              label: 'Salvar alterações pendentes',
              child: IconButton(
                onPressed: widget.onSave,
                icon: widget.customIcon ?? const Icon(Icons.save),
                color: Colors.orange,
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBannerStyle() {
    if (!widget.hasUnsavedChanges && !widget.isSaving && !_showSaved) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBannerColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBannerBorderColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getBannerIcon(),
          const SizedBox(width: 12),
          Text(
            _getBannerText(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getBannerTextColor(),
            ),
          ),
          if (widget.hasUnsavedChanges && widget.onSave != null) ...[
            const SizedBox(width: 16),
            TextButton(onPressed: widget.onSave, child: const Text('SALVAR')),
          ],
        ],
      ),
    );
  }

  Color _getBannerColor() {
    final theme = Theme.of(context);

    if (_showSaved) return Colors.green.withValues(alpha: 0.1);
    if (widget.isSaving) {
      return theme.colorScheme.primary.withValues(alpha: 0.1);
    }
    return Colors.orange.withValues(alpha: 0.1);
  }

  Color _getBannerBorderColor() {
    final theme = Theme.of(context);

    if (_showSaved) return Colors.green;
    if (widget.isSaving) return theme.colorScheme.primary;
    return Colors.orange;
  }

  Color _getBannerTextColor() {
    final theme = Theme.of(context);

    if (_showSaved) return Colors.green;
    if (widget.isSaving) return theme.colorScheme.primary;
    return Colors.orange;
  }

  Widget _getBannerIcon() {
    if (_showSaved) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }

    if (widget.isSaving) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return const Icon(Icons.warning, color: Colors.orange, size: 20);
  }

  String _getBannerText() {
    if (_showSaved) return widget.savedText ?? 'Alterações salvas!';
    if (widget.isSaving) return widget.savingText ?? 'Salvando alterações...';
    return widget.saveText ?? 'Você tem alterações não salvas';
  }
}

/// Estilos disponíveis para o SaveIndicator
enum SaveIndicatorStyle { chip, button, icon, banner }

/// Widget para auto-save com debounce
class AutoSaveIndicator extends StatefulWidget {
  final bool hasChanges;
  final Future<void> Function() onSave;
  final Duration debounceDelay;
  final String? statusText;

  const AutoSaveIndicator({
    super.key,
    required this.hasChanges,
    required this.onSave,
    this.debounceDelay = const Duration(seconds: 2),
    this.statusText,
  });

  @override
  State<AutoSaveIndicator> createState() => _AutoSaveIndicatorState();
}

class _AutoSaveIndicatorState extends State<AutoSaveIndicator> {
  bool _isSaving = false;
  bool _savedRecently = false;
  Timer? _debounceTimer;

  @override
  void didUpdateWidget(AutoSaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasChanges && !oldWidget.hasChanges) {
      _scheduleAutoSave();
    } else if (!widget.hasChanges) {
      _cancelAutoSave();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, _performAutoSave);
  }

  void _cancelAutoSave() {
    _debounceTimer?.cancel();
  }

  Future<void> _performAutoSave() async {
    if (!mounted || _isSaving) return;

    setState(() {
      _isSaving = true;
      _savedRecently = false;
    });

    try {
      await widget.onSave();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _savedRecently = true;
        });
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _savedRecently = false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasChanges && !_isSaving && !_savedRecently) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              color: _getTextColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    final theme = Theme.of(context);

    if (_savedRecently) {
      return Colors.green.withValues(alpha: 0.1);
    }

    if (_isSaving) {
      return theme.colorScheme.primary.withValues(alpha: 0.1);
    }

    return theme.colorScheme.outline.withValues(alpha: 0.1);
  }

  Color _getTextColor() {
    final theme = Theme.of(context);

    if (_savedRecently) return Colors.green;
    if (_isSaving) return theme.colorScheme.primary;
    return theme.colorScheme.onSurfaceVariant;
  }

  Widget _getStatusIcon() {
    if (_savedRecently) {
      return const Icon(Icons.check, color: Colors.green, size: 16);
    }

    if (_isSaving) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Icon(
      Icons.edit,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  String _getStatusText() {
    if (_savedRecently) return 'Salvo automaticamente';
    if (_isSaving) return 'Salvando...';
    return widget.statusText ?? 'Editando';
  }
}

/// Extensão customizada para cores não disponíveis no ColorScheme padrão
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? warning;

  const CustomColors({this.warning});

  @override
  CustomColors copyWith({Color? warning}) {
    return CustomColors(warning: warning ?? this.warning);
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(warning: Color.lerp(warning, other.warning, t));
  }
}
