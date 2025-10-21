import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../const/environment_const.dart' as local_env;
import '../../../../core/services/tts_service.dart';
import '../../../../core/widgets/appbar.dart';
import '../../domain/entities/termo.dart';
import '../providers/termos_providers.dart';

/// Page that displays a list of termos, either all termos or favorites only
class TermosPage extends ConsumerStatefulWidget {
  final bool favoritePage;

  const TermosPage({
    super.key,
    required this.favoritePage,
  });

  @override
  ConsumerState<TermosPage> createState() => _TermosPageState();
}

class _TermosPageState extends ConsumerState<TermosPage> {
  final TextEditingController _searchController = TextEditingController();
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _analyticsService = FirebaseAnalyticsService();
  final _ttsService = TTSService();

  String _searchQuery = '';

  @override
  void dispose() {
    _unfocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch termos based on whether it's favorites page or all termos
    final termosAsync = widget.favoritePage
        ? ref.watch(favoritosListProvider)
        : ref.watch(filteredTermosProvider(_searchQuery));

    return Scaffold(
      key: scaffoldKey,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // Search bar
          if (!widget.favoritePage)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar termos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

          // Termos list
          Expanded(
            child: termosAsync.when(
              data: (termos) {
                if (termos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.favoritePage
                              ? Icons.star_border
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.favoritePage
                              ? 'Nenhum favorito ainda'
                              : 'Nenhum termo encontrado',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: termos.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final termo = termos[index];
                    return _buildTermoCard(termo);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar termos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermoCard(Termo termo) {
    final isFavorito = ref.watch(isFavoritoProvider(termo.id));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          termo.termo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: termo.categoria.isNotEmpty
            ? Text(
                termo.categoria,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            isFavorito.value ?? false ? Icons.star : Icons.star_border,
            color: isFavorito.value ?? false ? Colors.amber : null,
          ),
          onPressed: () async {
            await ref
                .read(toggleFavoritoUseCaseProvider)
                .call(termo.id);
            // Refresh favorites if on favorites page
            if (widget.favoritePage) {
              ref.invalidate(favoritosListProvider);
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  termo.descricao,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // TTS button
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () async {
                        await _ttsService.speak('${termo.termo}. ${termo.descricao}');
                        _analyticsService.logEvent(
                          name: 'tts_termo',
                          parameters: {'termo_id': termo.id},
                        );
                      },
                      tooltip: 'Ouvir',
                    ),
                    // Copy button
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        final result = await ref
                            .read(copiarTermoUseCaseProvider)
                            .call(termo);
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                          },
                          (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copiado!')),
                            );
                            _analyticsService.logEvent(
                              name: 'copy_termo',
                              parameters: {'termo_id': termo.id},
                            );
                          },
                        );
                      },
                      tooltip: 'Copiar',
                    ),
                    // Share button
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () async {
                        final result = await ref
                            .read(compartilharTermoUseCaseProvider)
                            .call(termo);
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                          },
                          (_) {
                            _analyticsService.logEvent(
                              name: 'share_termo',
                              parameters: {'termo_id': termo.id},
                            );
                          },
                        );
                      },
                      tooltip: 'Compartilhar',
                    ),
                    // External link button (if applicable)
                    if (local_env.hasExternalLinks)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () async {
                          final result = await ref
                              .read(abrirTermoExternoUseCaseProvider)
                              .call(termo);
                          result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              );
                            },
                            (_) {
                              _analyticsService.logEvent(
                                name: 'open_external_termo',
                                parameters: {'termo_id': termo.id},
                              );
                            },
                          );
                        },
                        tooltip: 'Abrir no navegador',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
