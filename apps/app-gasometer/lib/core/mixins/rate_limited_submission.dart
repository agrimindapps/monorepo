import 'dart:async';

import 'package:flutter/material.dart';

/// Mixin para implementar rate limiting em formulários
/// 
/// Previne spam de submissões múltiplas e implementa debounce
/// para melhorar a experiência do usuário e reduzir carga no servidor.
/// 
/// Características:
/// - Rate limiting configurável
/// - Debounce para evitar múltiplos cliques
/// - Estado de loading automático
/// - Callback de erro integrado
/// - Compatível com qualquer StatefulWidget
mixin RateLimitedSubmission<T extends StatefulWidget> on State<T> {
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  DateTime? _lastSubmission;
  
  /// Duração do debounce entre tentativas de submissão
  Duration get submitDebounce => const Duration(milliseconds: 500);
  
  /// Intervalo mínimo entre submissões (rate limiting)
  Duration get minimumInterval => const Duration(seconds: 1);
  
  /// Indica se o formulário está sendo enviado
  bool get isSubmitting => _isSubmitting;
  
  /// Submete o formulário com rate limiting e debounce
  /// 
  /// [onSubmit] - Função assíncrona que executa a submissão
  /// [onError] - Callback opcional para tratar erros
  /// [force] - Se true, ignora o rate limiting (usar com cuidado)
  Future<void> submitWithRateLimit(
    Future<void> Function() onSubmit, {
    void Function(dynamic error)? onError,
    bool force = false,
  }) async {
    // Verificar se já está submetendo
    if (_isSubmitting && !force) {
      debugPrint('RateLimitedSubmission: Tentativa de submissão ignorada - já processando');
      return;
    }
    
    // Verificar rate limiting
    if (!force && _lastSubmission != null) {
      final timeSinceLastSubmission = DateTime.now().difference(_lastSubmission!);
      if (timeSinceLastSubmission < minimumInterval) {
        final remainingTime = minimumInterval - timeSinceLastSubmission;
        debugPrint('RateLimitedSubmission: Rate limit ativo - aguarde ${remainingTime.inMilliseconds}ms');
        
        // Mostrar feedback para o usuário
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aguarde ${remainingTime.inSeconds + 1} segundo(s) antes de tentar novamente'),
              duration: remainingTime,
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }
    
    // Cancelar debounce anterior
    _debounceTimer?.cancel();
    
    // Configurar debounce
    _debounceTimer = Timer(submitDebounce, () async {
      if (!mounted) return;
      
      try {
        // Atualizar estado de loading
        setState(() {
          _isSubmitting = true;
        });
        
        // Registrar timestamp da submissão
        _lastSubmission = DateTime.now();
        
        // Executar a submissão
        await onSubmit();
        
        debugPrint('RateLimitedSubmission: Submissão concluída com sucesso');
        
      } catch (error, stackTrace) {
        debugPrint('RateLimitedSubmission: Erro na submissão - $error');
        debugPrint('StackTrace: $stackTrace');
        
        // Chamar callback de erro se fornecido
        if (onError != null) {
          onError(error);
        } else {
          // Feedback padrão de erro
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao processar: ${error.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        
      } finally {
        // Sempre resetar o estado de loading
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    });
  }
  
  /// Limpa o rate limiting (útil para testes ou casos específicos)
  void clearRateLimit() {
    _lastSubmission = null;
    _debounceTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
    
    debugPrint('RateLimitedSubmission: Rate limit limpo');
  }
  
  /// Verifica se pode submeter baseado no rate limiting
  bool canSubmit() {
    if (_isSubmitting) return false;
    
    if (_lastSubmission == null) return true;
    
    final timeSinceLastSubmission = DateTime.now().difference(_lastSubmission!);
    return timeSinceLastSubmission >= minimumInterval;
  }
  
  /// Tempo restante até poder submeter novamente (em milissegundos)
  int getRemainingCooldown() {
    if (_lastSubmission == null) return 0;
    
    final timeSinceLastSubmission = DateTime.now().difference(_lastSubmission!);
    final remaining = minimumInterval - timeSinceLastSubmission;
    
    return remaining.isNegative ? 0 : remaining.inMilliseconds;
  }
  
  /// Limpa recursos quando o widget é destruído
  void disposeRateLimit() {
    _debounceTimer?.cancel();
    debugPrint('RateLimitedSubmission: Recursos limpos');
  }
  
  @override
  void dispose() {
    disposeRateLimit();
    super.dispose();
  }
}

/// Versão extendida com configurações customizáveis
mixin ConfigurableRateLimitedSubmission<T extends StatefulWidget> on State<T> {
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  DateTime? _lastSubmission;
  int _submissionCount = 0;
  Timer? _resetCountTimer;
  
  /// Duração do debounce (configurável)
  Duration get submitDebounce => const Duration(milliseconds: 300);
  
  /// Intervalo mínimo entre submissões (configurável)
  Duration get minimumInterval => const Duration(milliseconds: 800);
  
  /// Máximo de submissões por período (configurável)
  int get maxSubmissionsPerPeriod => 5;
  
  /// Período para reset do contador (configurável)
  Duration get submissionCountResetPeriod => const Duration(minutes: 1);
  
  /// Indica se está submetendo
  bool get isSubmitting => _isSubmitting;
  
  /// Número de submissões no período atual
  int get currentSubmissionCount => _submissionCount;
  
  /// Submete com rate limiting avançado
  Future<void> submitWithAdvancedRateLimit(
    Future<void> Function() onSubmit, {
    void Function(dynamic error)? onError,
    void Function(String message)? onRateLimitExceeded,
    bool force = false,
  }) async {
    // Verificar se já está submetendo
    if (_isSubmitting && !force) return;
    
    // Verificar rate limiting por contagem
    if (!force && _submissionCount >= maxSubmissionsPerPeriod) {
      final message = 'Muitas tentativas. Aguarde ${submissionCountResetPeriod.inMinutes} minuto(s)';
      debugPrint('ConfigurableRateLimitedSubmission: $message');
      
      if (onRateLimitExceeded != null) {
        onRateLimitExceeded(message);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Verificar intervalo mínimo
    if (!force && _lastSubmission != null) {
      final timeSinceLastSubmission = DateTime.now().difference(_lastSubmission!);
      if (timeSinceLastSubmission < minimumInterval) {
        return;
      }
    }
    
    // Cancelar debounce anterior
    _debounceTimer?.cancel();
    
    // Configurar debounce
    _debounceTimer = Timer(submitDebounce, () async {
      if (!mounted) return;
      
      try {
        setState(() {
          _isSubmitting = true;
        });
        
        // Incrementar contador e configurar reset
        _submissionCount++;
        _lastSubmission = DateTime.now();
        _setupCountReset();
        
        await onSubmit();
        
      } catch (error) {
        if (onError != null) {
          onError(error);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    });
  }
  
  void _setupCountReset() {
    _resetCountTimer?.cancel();
    _resetCountTimer = Timer(submissionCountResetPeriod, () {
      _submissionCount = 0;
      debugPrint('ConfigurableRateLimitedSubmission: Contador resetado');
    });
  }
  
  /// Limpa todos os recursos
  void disposeAdvancedRateLimit() {
    _debounceTimer?.cancel();
    _resetCountTimer?.cancel();
  }
  
  @override
  void dispose() {
    disposeAdvancedRateLimit();
    super.dispose();
  }
}