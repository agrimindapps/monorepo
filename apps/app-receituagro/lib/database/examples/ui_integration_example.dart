// ignore_for_file: unused_local_variable, unreachable_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_providers.dart';
import '../repositories/repositories.dart';

/// Exemplo de integração de UI com Drift Streams
///
/// Este arquivo demonstra como converter widgets que usavam Hive
/// para usar Drift com Riverpod providers.
///
/// **NÃO COMPILE ESTE ARQUIVO** - É apenas para referência

// ========== EXEMPLO 1: Lista de Diagnósticos ==========

/// ANTES (Hive + ValueListenableBuilder)
class DiagnosticosListOld extends StatelessWidget {
  const DiagnosticosListOld({super.key});

  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder<Box<DiagnosticoHive>>(
    //   valueListenable: Hive.box<DiagnosticoHive>('diagnosticos').listenable(),
    //   builder: (context, box, _) {
    //     final diagnosticos = box.values.toList();
    //
    //     if (diagnosticos.isEmpty) {
    //       return Center(child: Text('Nenhum diagnóstico'));
    //     }
    //
    //     return ListView.builder(
    //       itemCount: diagnosticos.length,
    //       itemBuilder: (context, index) {
    //         final diagnostico = diagnosticos[index];
    //         return ListTile(
    //           title: Text(diagnostico.nomeDefensivo ?? ''),
    //           subtitle: Text(diagnostico.nomeCultura ?? ''),
    //         );
    //       },
    //     );
    //   },
    // );

    return const Placeholder();
  }
}

/// DEPOIS (Drift + Riverpod)
class DiagnosticosListNew extends ConsumerWidget {
  const DiagnosticosListNew({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o stream de diagnósticos
    final diagnosticosAsync = ref.watch(diagnosticosStreamProvider(userId));

    return diagnosticosAsync.when(
      // Dados carregados
      data: (diagnosticos) {
        if (diagnosticos.isEmpty) {
          return const Center(child: Text('Nenhum diagnóstico'));
        }

        return ListView.builder(
          itemCount: diagnosticos.length,
          itemBuilder: (context, index) {
            final diagnostico = diagnosticos[index];
            return ListTile(
              title: Text(diagnostico.dsMax),
              subtitle: Text('ID: ${diagnostico.idReg}'),
              trailing: Text(diagnostico.um),
            );
          },
        );
      },
      // Carregando
      loading: () => const Center(child: CircularProgressIndicator()),
      // Erro
      error: (error, stackTrace) => Center(
        child: Text('Erro: $error'),
      ),
    );
  }
}

// ========== EXEMPLO 2: Diagnósticos com Dados Relacionados (JOIN) ==========

/// DEPOIS (Drift + Riverpod + JOINs)
class DiagnosticosEnrichedList extends ConsumerWidget {
  const DiagnosticosEnrichedList({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o stream com dados relacionados (JOIN automático!)
    final diagnosticosAsync =
        ref.watch(diagnosticosEnrichedStreamProvider(userId));

    return diagnosticosAsync.when(
      data: (diagnosticos) {
        if (diagnosticos.isEmpty) {
          return const Center(child: Text('Nenhum diagnóstico'));
        }

        return ListView.builder(
          itemCount: diagnosticos.length,
          itemBuilder: (context, index) {
            final enriched = diagnosticos[index];
            final diagnostico = enriched.diagnostico;
            final defensivo = enriched.defensivo;
            final cultura = enriched.cultura;
            final praga = enriched.praga;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(defensivo?.nome ?? 'Defensivo desconhecido'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cultura: ${cultura?.nome ?? 'N/A'}'),
                    Text('Praga: ${praga?.nome ?? 'N/A'}'),
                    Text('Dosagem: ${diagnostico.dsMax} ${diagnostico.um}'),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Erro: $error'),
      ),
    );
  }
}

// ========== EXEMPLO 3: Contador de Diagnósticos ==========

/// DEPOIS (Drift + Riverpod)
class DiagnosticosCounter extends ConsumerWidget {
  const DiagnosticosCounter({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa FutureProvider para buscar count uma única vez
    final countAsync = ref.watch(diagnosticosCountProvider(userId));

    return countAsync.when(
      data: (count) => Text('Total: $count diagnósticos'),
      loading: () => const Text('Carregando...'),
      error: (error, _) => Text('Erro: $error'),
    );
  }
}

// ========== EXEMPLO 4: Verificar se Item está Favoritado ==========

/// DEPOIS (Drift + Riverpod)
class FavoritoButton extends ConsumerWidget {
  const FavoritoButton({
    super.key,
    required this.userId,
    required this.tipo,
    required this.itemId,
  });

  final String userId;
  final String tipo;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verifica se está favoritado
    final isFavoritedAsync = ref.watch(
      isFavoritedProvider(
        userId: userId,
        tipo: tipo,
        itemId: itemId,
      ),
    );

    return isFavoritedAsync.when(
      data: (isFavorited) {
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : null,
          ),
          onPressed: () async {
            final repo = ref.read(favoritoRepositoryProvider);

            if (isFavorited) {
              // Remover favorito
              await repo.removeFavorito(userId, tipo, itemId);
            } else {
              // Adicionar favorito
              await repo.insert(
                FavoritoData(
                  id: 0,
                  userId: userId,
                  moduleName: 'receituagro',
                  createdAt: DateTime.now(),
                  isDirty: true,
                  isDeleted: false,
                  version: 1,
                  tipo: tipo,
                  itemId: itemId,
                  itemData: '{}', // JSON cache
                ),
              );
            }

            // Invalida o cache para refetch
            ref.invalidate(
              isFavoritedProvider(
                userId: userId,
                tipo: tipo,
                itemId: itemId,
              ),
            );
          },
        );
      },
      loading: () => const IconButton(
        icon: Icon(Icons.favorite_border),
        onPressed: null,
      ),
      error: (_, __) => const Icon(Icons.error),
    );
  }
}

// ========== EXEMPLO 5: Lista de Comentários ==========

/// DEPOIS (Drift + Riverpod)
class ComentariosList extends ConsumerWidget {
  const ComentariosList({
    super.key,
    required this.itemId,
  });

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o stream de comentários
    final comentariosAsync = ref.watch(comentariosStreamProvider(itemId));

    return comentariosAsync.when(
      data: (comentarios) {
        if (comentarios.isEmpty) {
          return const Center(child: Text('Nenhum comentário'));
        }

        return ListView.builder(
          itemCount: comentarios.length,
          itemBuilder: (context, index) {
            final comentario = comentarios[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.comment)),
              title: Text(comentario.texto),
              subtitle: Text(
                'Por: ${comentario.userId} • ${_formatDate(comentario.createdAt)}',
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ========== EXEMPLO 6: Criar Novo Diagnóstico ==========

/// DEPOIS (Drift + Riverpod)
class CreateDiagnosticoButton extends ConsumerWidget {
  const CreateDiagnosticoButton({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final repo = ref.read(diagnosticoRepositoryProvider);

        // Criar novo diagnóstico
        final novoDiagnostico = DiagnosticoData(
          id: 0,
          userId: userId,
          moduleName: 'receituagro',
          createdAt: DateTime.now(),
          isDirty: true,
          isDeleted: false,
          version: 1,
          defenisivoId: 1, // TODO: Selecionar do dropdown
          culturaId: 1, // TODO: Selecionar do dropdown
          pragaId: 1, // TODO: Selecionar do dropdown
          idReg: 'diag_${DateTime.now().millisecondsSinceEpoch}',
          dsMax: '1.5',
          um: 'L/ha',
        );

        try {
          final id = await repo.insert(novoDiagnostico);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Diagnóstico criado com ID: $id')),
            );
          }

          // O stream é automaticamente atualizado!
          // Não precisa chamar setState() ou notifyListeners()
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro: $e')),
            );
          }
        }
      },
      child: const Text('Criar Diagnóstico'),
    );
  }
}

// ========== RESUMO DE CONVERSÃO ==========

/// Passos para converter uma tela que usa Hive para Drift:
///
/// 1. Trocar StatelessWidget por ConsumerWidget (ou StatefulWidget por ConsumerStatefulWidget)
/// 2. Adicionar WidgetRef ref aos parâmetros do build()
/// 3. Substituir ValueListenableBuilder por ref.watch(streamProvider)
/// 4. Usar .when() para tratar loading/data/error states
/// 5. Para operações (insert/update/delete), usar ref.read(repositoryProvider)
/// 6. Remover imports de Hive
/// 7. Testar a tela end-to-end
///
/// Benefícios:
/// - ✅ Reactive UI automática (streams)
/// - ✅ Error handling built-in
/// - ✅ Loading states automáticos
/// - ✅ Type safety em compile-time
/// - ✅ JOINs eficientes (dados relacionados)
/// - ✅ No setState() ou notifyListeners() necessário
/// - ✅ Cache automático do Riverpod
