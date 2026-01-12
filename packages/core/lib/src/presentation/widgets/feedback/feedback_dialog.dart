import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/feedback_entity.dart';
import '../../../riverpod/domain/feedback/feedback_providers.dart';

/// Dialog para envio de feedback pelo usuário
/// 
/// Pode ser usado em qualquer app do monorepo.
/// Suporta contexto de calculadora (ID e nome) para rastreamento.
class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({
    super.key,
    this.calculatorId,
    this.calculatorName,
    this.appVersion,
    this.primaryColor,
  });

  /// ID da calculadora atual (opcional)
  final String? calculatorId;

  /// Nome da calculadora atual (opcional)
  final String? calculatorName;

  /// Versão do app
  final String? appVersion;

  /// Cor primária do tema (opcional)
  final Color? primaryColor;

  /// Abre o dialog de feedback
  static Future<bool?> show(
    BuildContext context, {
    String? calculatorId,
    String? calculatorName,
    String? appVersion,
    Color? primaryColor,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackDialog(
        calculatorId: calculatorId,
        calculatorName: calculatorName,
        appVersion: appVersion,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  
  FeedbackType _selectedType = FeedbackType.comment;
  double? _rating;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Color get _accentColor => widget.primaryColor ?? Colors.blue;

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final feedback = FeedbackEntity(
        id: '',
        type: _selectedType,
        message: _messageController.text.trim(),
        calculatorId: widget.calculatorId,
        calculatorName: widget.calculatorName,
        rating: _rating,
        appVersion: widget.appVersion,
        platform: _platform,
        userEmail: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        createdAt: DateTime.now(),
      );

      final service = ref.read(feedbackServiceProvider);
      final result = await service.submitFeedback(feedback);

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback enviado com sucesso! Obrigado! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subtitleColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.feedback_rounded,
                        color: _accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enviar Feedback',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.calculatorName != null)
                            Text(
                              widget.calculatorName!,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: subtitleColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Feedback type selection
                Text(
                  'Tipo de feedback',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FeedbackType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _accentColor.withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? _accentColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(type.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              type.displayName,
                              style: TextStyle(
                                color: isSelected ? _accentColor : textColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Message field
                Text(
                  'Sua mensagem',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  maxLength: 1000,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    hintStyle: TextStyle(color: subtitleColor),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _accentColor, width: 2),
                    ),
                    counterStyle: TextStyle(color: subtitleColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, escreva sua mensagem';
                    }
                    if (value.trim().length < 10) {
                      return 'Mensagem muito curta (mínimo 10 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Optional rating (only for comments)
                if (_selectedType == FeedbackType.comment) ...[
                  Text(
                    'Avaliação (opcional)',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = _rating != null && _rating! >= starValue;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = _rating == starValue.toDouble()
                                ? null
                                : starValue.toDouble();
                          });
                        },
                        icon: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isSelected ? Colors.amber : subtitleColor,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],

                // Optional email
                Text(
                  'Seu email (opcional)',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha se deseja receber uma resposta',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'seu@email.com',
                    hintStyle: TextStyle(color: subtitleColor),
                    prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _accentColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Email inválido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: _accentColor.withValues(alpha: 0.5),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded),
                              SizedBox(width: 8),
                              Text(
                                'Enviar Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Privacy note
                Text(
                  'Seu feedback nos ajuda a melhorar o app! 💚',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case FeedbackType.bug:
        return 'Descreva o problema que você encontrou...';
      case FeedbackType.suggestion:
        return 'Compartilhe sua ideia ou sugestão...';
      case FeedbackType.comment:
        return 'Deixe seu comentário ou opinião...';
      case FeedbackType.other:
        return 'Escreva sua mensagem...';
    }
  }
}
