import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/widgets/sync/simple_sync_loading.dart';
import '../error/sync_error_handler.dart';

/// Exemplo de uso da sincronização automática no login
class SyncIntegrationExample extends StatefulWidget {
  const SyncIntegrationExample({super.key});

  @override
  State<SyncIntegrationExample> createState() => _SyncIntegrationExampleState();
}

class _SyncIntegrationExampleState extends State<SyncIntegrationExample> {
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void initState() {
    super.initState();
    
    // Inicializar o handler de erros globalmente
    SyncErrorHandler.instance.initialize();
    
    // Escutar erros de sincronização
    SyncErrorHandler.instance.errorStream.listen(_handleSyncError);
    SyncErrorHandler.instance.recoveryStream.listen(_handleSyncRecovery);
  }

  void _handleSyncError(SyncError error) {
    // Erros são tratados automaticamente pelo SyncErrorHandler
    // Aqui podemos adicionar lógica específica do app
    debugPrint('Erro de sync capturado: ${error.userMessage}');
  }

  void _handleSyncRecovery(String message) {
    // Feedback de recuperação automática
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Demonstra o novo fluxo de login com sincronização
  Future<void> _performLoginWithSync() async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      // 1. Usar o novo método loginAndSync
      await authProvider.loginAndSync(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        // 2. Verificar se há sincronização em progresso
        if (authProvider.isSyncInProgress) {
          
          // 3. Mostrar loading simples
          _showSimpleSyncLoading(authProvider);
        } else {
          // Login sem sincronização ou sync já completada
          _navigateToApp();
        }
      }
    } catch (e) {
      // Erros são tratados automaticamente pelo SyncErrorHandler
      debugPrint('Erro no login: $e');
    }
  }

  /// Mostra loading simples de sincronização que navega automaticamente
  void _showSimpleSyncLoading(AuthProvider authProvider) {
    SimpleSyncLoading.show(
      context,
      message: authProvider.syncMessage,
    );
    
    // Navegar quando sync terminar
    _navigateAfterSync(authProvider);
  }
  
  /// Navega quando sync terminar
  void _navigateAfterSync(AuthProvider authProvider) {
    late StreamSubscription subscription;
    
    subscription = Stream.periodic(const Duration(milliseconds: 500))
        .listen((_) {
      if (!authProvider.isSyncInProgress) {
        subscription.cancel();
        
        // Pequeno delay para garantir que o loading foi fechado
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigateToApp();
        });
      }
    });
  }

  void _navigateToApp() {
    // Navegar para tela principal do app
    debugPrint('Navegando para tela principal...');
  }

  /// Demonstra controle manual da sincronização
  void _demonstrateSyncControl(AuthProvider authProvider) {
    // Verificar se sync está em progresso
    if (authProvider.isSyncInProgress) {
      debugPrint('Sincronização em progresso: ${authProvider.syncMessage}');
      
      // Cancelar se necessário
      // authProvider.cancelSync();
      
      // Ou fazer retry
      // authProvider.retrySyncAfterLogin();
    } else {
      debugPrint('Sincronização não está em progresso');
    }

    // Verificar se já foi realizada sync inicial
    if (authProvider.hasPerformedInitialSync) {
      debugPrint('Sincronização inicial já foi realizada nesta sessão!');
    }
  }

  /// Demonstra tratamento de diferentes tipos de erro
  void _demonstrateErrorHandling() {
    // Simular diferentes tipos de erro
    final errors = [
      NetworkFailure('Sem conexão com internet'),
      ServerFailure('Servidor temporariamente indisponível'),
      CacheFailure('Erro ao salvar dados localmente'),
    ];

    for (final error in errors) {
      SyncErrorHandler.instance.handleError(
        error,
        context: context,
        metadata: {'operation': 'demo', 'timestamp': DateTime.now().toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Integration Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Documentação
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Funcionalidade de Sincronização Automática',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esta implementação inclui:\n'
                      '• Login + Sincronização automática\n'
                      '• Overlay de progresso não-bloqueante\n'
                      '• Tratamento robusto de erros\n'
                      '• Opção "Continuar em Background"\n'
                      '• Recovery automático com retry\n'
                      '• Fallback gracioso para modo offline',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campos de login
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Botões de demonstração
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : _performLoginWithSync,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login com Sincronização'),
                    ),
                    const SizedBox(height: 12),
                    
                    OutlinedButton(
                      onPressed: () => _demonstrateSyncControl(authProvider),
                      child: const Text('Demonstrar Controles de Sync'),
                    ),
                    const SizedBox(height: 12),
                    
                    OutlinedButton(
                      onPressed: _demonstrateErrorHandling,
                      child: const Text('Simular Tratamento de Erros'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Status da sincronização
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (!authProvider.isAuthenticated) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Status: Não autenticado'),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: Autenticado (${authProvider.currentUser?.email})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        if (authProvider.isSyncInProgress)
                          Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(authProvider.syncMessage),
                              ),
                            ],
                          ),
                        if (authProvider.hasPerformedInitialSync && 
                            !authProvider.isSyncInProgress)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, 
                                   color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text('Sincronização inicial completada!'),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Estatísticas de erro
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estatísticas de Erro',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: Future.value(SyncErrorHandler.instance.getErrorStats()),
                      builder: (context, snapshot) {
                        final stats = snapshot.data ?? {};
                        return Text(
                          'Total de erros: ${stats['total_errors'] ?? 0}\n'
                          'Nas últimas 24h: ${stats['errors_24h'] ?? 0}\n'
                          'Tentativas ativas: ${stats['active_retries'] ?? 0}',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Classes de exemplo para demonstração (normalmente vindas do core)
class NetworkFailure implements Exception {
  final String message;
  NetworkFailure(this.message);
  
  @override
  String toString() => 'NetworkFailure: $message';
}

class ServerFailure implements Exception {
  final String message;
  ServerFailure(this.message);
  
  @override
  String toString() => 'ServerFailure: $message';
}

class CacheFailure implements Exception {
  final String message;
  CacheFailure(this.message);
  
  @override
  String toString() => 'CacheFailure: $message';
}