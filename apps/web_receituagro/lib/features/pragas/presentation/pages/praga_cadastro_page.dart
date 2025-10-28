import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../providers/praga_cadastro_provider.dart';

/// Praga Cadastro Page - Create/Edit
class PragaCadastroPage extends ConsumerStatefulWidget {
  final String? pragaId; // null = new, ID = edit

  const PragaCadastroPage({
    super.key,
    this.pragaId,
  });

  @override
  ConsumerState<PragaCadastroPage> createState() => _PragaCadastroPageState();
}

class _PragaCadastroPageState extends ConsumerState<PragaCadastroPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nomeComumController;
  late final TextEditingController _nomeCientificoController;
  late final TextEditingController _ordemController;
  late final TextEditingController _familiaController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _culturasAfetadasController;
  late final TextEditingController _danosController;
  late final TextEditingController _controleController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nomeComumController = TextEditingController();
    _nomeCientificoController = TextEditingController();
    _ordemController = TextEditingController();
    _familiaController = TextEditingController();
    _descricaoController = TextEditingController();
    _imageUrlController = TextEditingController();
    _culturasAfetadasController = TextEditingController();
    _danosController = TextEditingController();
    _controleController = TextEditingController();

    // Load existing data if editing
    if (widget.pragaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPraga();
      });
    }
  }

  Future<void> _loadPraga() async {
    setState(() => _isLoading = true);

    final result =
        await ref.read(pragaCadastroProvider.notifier).loadPraga(widget.pragaId!);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (praga) {
        _nomeComumController.text = praga.nomeComum;
        _nomeCientificoController.text = praga.nomeCientifico;
        _ordemController.text = praga.ordem;
        _familiaController.text = praga.familia;
        _descricaoController.text = praga.descricao ?? '';
        _imageUrlController.text = praga.imageUrl ?? '';
        _culturasAfetadasController.text =
            praga.culturasAfetadas?.join(', ') ?? '';
        _danosController.text = praga.danos ?? '';
        _controleController.text = praga.controle ?? '';
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _nomeComumController.dispose();
    _nomeCientificoController.dispose();
    _ordemController.dispose();
    _familiaController.dispose();
    _descricaoController.dispose();
    _imageUrlController.dispose();
    _culturasAfetadasController.dispose();
    _danosController.dispose();
    _controleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pragaId != null;

    return InternalPageLayout(
      title: isEdit ? 'Editar Praga' : 'Nova Praga',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _savePraga,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Salvar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.only(bottom: 16.0),
                            color: Colors.red.shade100,
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() => _errorMessage = null);
                                  },
                                ),
                              ],
                            ),
                          ),

                        // Section: Identificação
                        const Text(
                          'Identificação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nomeComumController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Comum *',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Lagarta do Cartucho, Mosca Branca',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nome comum é obrigatório';
                            }
                            if (value.trim().length < 3) {
                              return 'Mínimo 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nomeCientificoController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Científico *',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Spodoptera frugiperda, Bemisia tabaci',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nome científico é obrigatório';
                            }
                            if (value.trim().length < 3) {
                              return 'Mínimo 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _ordemController,
                          decoration: const InputDecoration(
                            labelText: 'Ordem *',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Lepidoptera, Hemiptera, Coleoptera',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ordem é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _familiaController,
                          decoration: const InputDecoration(
                            labelText: 'Família *',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Noctuidae, Aleyrodidae',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Família é obrigatória';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Section: Detalhes
                        const Text(
                          'Detalhes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descricaoController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(),
                            helperText:
                                'Características gerais, hábitos alimentares',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _culturasAfetadasController,
                          decoration: const InputDecoration(
                            labelText: 'Culturas Afetadas',
                            border: OutlineInputBorder(),
                            helperText: 'Separe por vírgula. Ex: Milho, Soja, Algodão',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _danosController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Danos Causados',
                            border: OutlineInputBorder(),
                            helperText:
                                'Descreva os tipos de danos que a praga causa às culturas',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _controleController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Métodos de Controle',
                            border: OutlineInputBorder(),
                            helperText:
                                'Estratégias de controle químico, biológico, cultural',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem',
                            border: OutlineInputBorder(),
                            helperText: 'Link para imagem da praga',
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !Uri.tryParse(value)!.isAbsolute) {
                              return 'URL inválida';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Preview image if URL provided
                        if (_imageUrlController.text.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preview da Imagem',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrlController.text,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image,
                                                size: 48, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Erro ao carregar imagem'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),

                        const Text(
                          '* Campos obrigatórios',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _savePraga() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Parse culturas afetadas
    List<String>? culturasAfetadas;
    if (_culturasAfetadasController.text.isNotEmpty) {
      culturasAfetadas = _culturasAfetadasController.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
    }

    final result = await ref.read(pragaCadastroProvider.notifier).savePraga(
          id: widget.pragaId,
          nomeComum: _nomeComumController.text,
          nomeCientifico: _nomeCientificoController.text,
          ordem: _ordemController.text,
          familia: _familiaController.text,
          descricao: _descricaoController.text.isNotEmpty
              ? _descricaoController.text
              : null,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          culturasAfetadas: culturasAfetadas,
          danos: _danosController.text.isNotEmpty ? _danosController.text : null,
          controle:
              _controleController.text.isNotEmpty ? _controleController.text : null,
        );

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (praga) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Praga salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}
