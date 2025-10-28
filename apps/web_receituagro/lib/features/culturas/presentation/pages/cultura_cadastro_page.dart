import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../providers/cultura_cadastro_provider.dart';

/// Cultura Cadastro Page - Create/Edit
class CulturaCadastroPage extends ConsumerStatefulWidget {
  final String? culturaId; // null = new, ID = edit

  const CulturaCadastroPage({
    super.key,
    this.culturaId,
  });

  @override
  ConsumerState<CulturaCadastroPage> createState() =>
      _CulturaCadastroPageState();
}

class _CulturaCadastroPageState extends ConsumerState<CulturaCadastroPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nomeComumController;
  late final TextEditingController _nomeCientificoController;
  late final TextEditingController _familiaController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _variedadesController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nomeComumController = TextEditingController();
    _nomeCientificoController = TextEditingController();
    _familiaController = TextEditingController();
    _descricaoController = TextEditingController();
    _imageUrlController = TextEditingController();
    _variedadesController = TextEditingController();

    // Load existing data if editing
    if (widget.culturaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCultura();
      });
    }
  }

  Future<void> _loadCultura() async {
    setState(() => _isLoading = true);

    final result = await ref
        .read(culturaCadastroProvider.notifier)
        .loadCultura(widget.culturaId!);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (cultura) {
        _nomeComumController.text = cultura.nomeComum;
        _nomeCientificoController.text = cultura.nomeCientifico;
        _familiaController.text = cultura.familia;
        _descricaoController.text = cultura.descricao ?? '';
        _imageUrlController.text = cultura.imageUrl ?? '';
        _variedadesController.text = cultura.variedades?.join(', ') ?? '';
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _nomeComumController.dispose();
    _nomeCientificoController.dispose();
    _familiaController.dispose();
    _descricaoController.dispose();
    _imageUrlController.dispose();
    _variedadesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.culturaId != null;

    return InternalPageLayout(
      title: isEdit ? 'Editar Cultura' : 'Nova Cultura',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveCultura,
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
                            helperText: 'Ex: Soja, Milho, Trigo',
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
                            helperText: 'Ex: Glycine max, Zea mays',
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
                          controller: _familiaController,
                          decoration: const InputDecoration(
                            labelText: 'Família *',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Fabaceae, Poaceae',
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
                                'Características gerais, importância econômica',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _variedadesController,
                          decoration: const InputDecoration(
                            labelText: 'Variedades',
                            border: OutlineInputBorder(),
                            helperText:
                                'Separe por vírgula. Ex: Intacta, BRS, Pioneer',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem',
                            border: OutlineInputBorder(),
                            helperText: 'Link para imagem da cultura',
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

  Future<void> _saveCultura() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Parse variedades
    List<String>? variedades;
    if (_variedadesController.text.isNotEmpty) {
      variedades = _variedadesController.text
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();
    }

    final result = await ref.read(culturaCadastroProvider.notifier).saveCultura(
          id: widget.culturaId,
          nomeComum: _nomeComumController.text,
          nomeCientifico: _nomeCientificoController.text,
          familia: _familiaController.text,
          descricao: _descricaoController.text.isNotEmpty
              ? _descricaoController.text
              : null,
          imageUrl: _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          variedades: variedades,
        );

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (cultura) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cultura salva com sucesso!'),
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
