import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_role_providers.dart';

/// Widget guard que protege páginas administrativas
/// 
/// Valida se o usuário tem permissão de admin antes de exibir o conteúdo.
/// Se não for admin, redireciona para home com mensagem de erro.
/// 
/// **Segurança em múltiplas camadas:**
/// 1. Router redirect (primeira barreira)
/// 2. AdminGuard widget (segunda barreira - UI)
/// 3. Firestore Rules (terceira barreira - backend)
class AdminGuard extends ConsumerWidget {
  const AdminGuard({
    required this.child,
    this.loadingWidget,
    super.key,
  });

  /// Widget a ser exibido quando o usuário é admin
  final Widget child;

  /// Widget customizado de loading (opcional)
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminUserProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          // Não é admin - redireciona e mostra erro
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⛔ Acesso negado. Você não tem permissão de administrador.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            context.go('/home');
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // É admin - exibe conteúdo protegido
        return child;
      },
      loading: () {
        return loadingWidget ??
            Scaffold(
              appBar: AppBar(
                title: const Text('Verificando permissões...'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Verificando permissões de administrador...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
      },
      error: (error, stack) {
        // Erro ao verificar permissões - redireciona
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Erro ao verificar permissões: $error'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          context.go('/home');
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Erro'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao verificar permissões',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Voltar ao Início'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
