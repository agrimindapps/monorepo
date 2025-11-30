import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../../domain/entities/tipo_praga.dart';
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

  // Controllers - Identificação
  late final TextEditingController _nomeComumController;
  late final TextEditingController _nomeCientificoController;

  // Controllers - Taxonomia Reino
  late final TextEditingController _dominioController;
  late final TextEditingController _reinoController;
  late final TextEditingController _subReinoController;

  // Controllers - Taxonomia Clado
  late final TextEditingController _clado01Controller;
  late final TextEditingController _clado02Controller;
  late final TextEditingController _clado03Controller;

  // Controllers - Taxonomia Divisão
  late final TextEditingController _superDivisaoController;
  late final TextEditingController _divisaoController;
  late final TextEditingController _subDivisaoController;

  // Controllers - Taxonomia Classe
  late final TextEditingController _classeController;
  late final TextEditingController _subClasseController;

  // Controllers - Taxonomia Família
  late final TextEditingController _superFamiliaController;
  late final TextEditingController _familiaController;
  late final TextEditingController _subFamiliaController;

  // Controllers - Taxonomia Ordem
  late final TextEditingController _superOrdemController;
  late final TextEditingController _ordemController;
  late final TextEditingController _subOrdemController;
  late final TextEditingController _infraOrdemController;

  // Controllers - Taxonomia Outros
  late final TextEditingController _triboController;
  late final TextEditingController _subTriboController;
  late final TextEditingController _generoController;
  late final TextEditingController _especieController;

  // Controllers - Detalhes
  late final TextEditingController _descricaoController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _culturasAfetadasController;
  late final TextEditingController _danosController;
  late final TextEditingController _controleController;

  TipoPraga _selectedTipoPraga = TipoPraga.inseto;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize controllers - Identificação
    _nomeComumController = TextEditingController();
    _nomeCientificoController = TextEditingController();

    // Initialize controllers - Taxonomia Reino
    _dominioController = TextEditingController();
    _reinoController = TextEditingController();
    _subReinoController = TextEditingController();

    // Initialize controllers - Taxonomia Clado
    _clado01Controller = TextEditingController();
    _clado02Controller = TextEditingController();
    _clado03Controller = TextEditingController();

    // Initialize controllers - Taxonomia Divisão
    _superDivisaoController = TextEditingController();
    _divisaoController = TextEditingController();
    _subDivisaoController = TextEditingController();

    // Initialize controllers - Taxonomia Classe
    _classeController = TextEditingController();
    _subClasseController = TextEditingController();

    // Initialize controllers - Taxonomia Família
    _superFamiliaController = TextEditingController();
    _familiaController = TextEditingController();
    _subFamiliaController = TextEditingController();

    // Initialize controllers - Taxonomia Ordem
    _superOrdemController = TextEditingController();
    _ordemController = TextEditingController();
    _subOrdemController = TextEditingController();
    _infraOrdemController = TextEditingController();

    // Initialize controllers - Taxonomia Outros
    _triboController = TextEditingController();
    _subTriboController = TextEditingController();
    _generoController = TextEditingController();
    _especieController = TextEditingController();

    // Initialize controllers - Detalhes
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
        // Identificação
        _nomeComumController.text = praga.nomeComum;
        _nomeCientificoController.text = praga.nomeCientifico;
        _selectedTipoPraga = praga.tipoPraga ?? TipoPraga.inseto;

        // Taxonomia Reino
        _dominioController.text = praga.dominio ?? '';
        _reinoController.text = praga.reino ?? '';
        _subReinoController.text = praga.subReino ?? '';

        // Taxonomia Clado
        _clado01Controller.text = praga.clado01 ?? '';
        _clado02Controller.text = praga.clado02 ?? '';
        _clado03Controller.text = praga.clado03 ?? '';

        // Taxonomia Divisão
        _superDivisaoController.text = praga.superDivisao ?? '';
        _divisaoController.text = praga.divisao ?? '';
        _subDivisaoController.text = praga.subDivisao ?? '';

        // Taxonomia Classe
        _classeController.text = praga.classe ?? '';
        _subClasseController.text = praga.subClasse ?? '';

        // Taxonomia Família
        _superFamiliaController.text = praga.superFamilia ?? '';
        _familiaController.text = praga.familia;
        _subFamiliaController.text = praga.subFamilia ?? '';

        // Taxonomia Ordem
        _superOrdemController.text = praga.superOrdem ?? '';
        _ordemController.text = praga.ordem;
        _subOrdemController.text = praga.subOrdem ?? '';
        _infraOrdemController.text = praga.infraOrdem ?? '';

        // Taxonomia Outros
        _triboController.text = praga.tribo ?? '';
        _subTriboController.text = praga.subTribo ?? '';
        _generoController.text = praga.genero ?? '';
        _especieController.text = praga.especie ?? '';

        // Detalhes
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
    // Identificação
    _nomeComumController.dispose();
    _nomeCientificoController.dispose();

    // Taxonomia Reino
    _dominioController.dispose();
    _reinoController.dispose();
    _subReinoController.dispose();

    // Taxonomia Clado
    _clado01Controller.dispose();
    _clado02Controller.dispose();
    _clado03Controller.dispose();

    // Taxonomia Divisão
    _superDivisaoController.dispose();
    _divisaoController.dispose();
    _subDivisaoController.dispose();

    // Taxonomia Classe
    _classeController.dispose();
    _subClasseController.dispose();

    // Taxonomia Família
    _superFamiliaController.dispose();
    _familiaController.dispose();
    _subFamiliaController.dispose();

    // Taxonomia Ordem
    _superOrdemController.dispose();
    _ordemController.dispose();
    _subOrdemController.dispose();
    _infraOrdemController.dispose();

    // Taxonomia Outros
    _triboController.dispose();
    _subTriboController.dispose();
    _generoController.dispose();
    _especieController.dispose();

    // Detalhes
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
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        if (_errorMessage != null)
                          _buildErrorMessage(),

                        // Section: Identificação
                        _buildSectionCard(
                          title: 'Identificação',
                          icon: Icons.badge,
                          color: Colors.blue,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _nomeComumController,
                                label: 'Nome Comum *',
                                helper: 'Ex: Lagarta do Cartucho',
                                validator: _requiredValidator('Nome comum'),
                              ),
                              _buildTextField(
                                controller: _nomeCientificoController,
                                label: 'Nome Científico *',
                                helper: 'Ex: Spodoptera frugiperda',
                                validator: _requiredValidator('Nome científico'),
                              ),
                              _buildTipoPragaDropdown(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Reino
                        _buildSectionCard(
                          title: 'Reino',
                          icon: Icons.account_tree,
                          color: Colors.purple,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _dominioController,
                                label: 'Domínio',
                                helper: 'Ex: Eukaryota',
                              ),
                              _buildTextField(
                                controller: _reinoController,
                                label: 'Reino',
                                helper: 'Ex: Animalia',
                              ),
                              _buildTextField(
                                controller: _subReinoController,
                                label: 'Sub-Reino',
                                helper: 'Ex: Bilateria',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Clado
                        _buildSectionCard(
                          title: 'Clado',
                          icon: Icons.nature,
                          color: Colors.teal,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _clado01Controller,
                                label: 'Clado 01',
                              ),
                              _buildTextField(
                                controller: _clado02Controller,
                                label: 'Clado 02',
                              ),
                              _buildTextField(
                                controller: _clado03Controller,
                                label: 'Clado 03',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Divisão
                        _buildSectionCard(
                          title: 'Divisão',
                          icon: Icons.layers,
                          color: Colors.indigo,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _superDivisaoController,
                                label: 'Super Divisão',
                              ),
                              _buildTextField(
                                controller: _divisaoController,
                                label: 'Divisão',
                              ),
                              _buildTextField(
                                controller: _subDivisaoController,
                                label: 'Sub Divisão',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Classe
                        _buildSectionCard(
                          title: 'Classe',
                          icon: Icons.category,
                          color: Colors.orange,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _classeController,
                                label: 'Classe',
                                helper: 'Ex: Insecta',
                              ),
                              _buildTextField(
                                controller: _subClasseController,
                                label: 'Sub Classe',
                                helper: 'Ex: Pterygota',
                              ),
                              const SizedBox(), // Empty placeholder
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Família
                        _buildSectionCard(
                          title: 'Família',
                          icon: Icons.family_restroom,
                          color: Colors.pink,
                          children: [
                            _buildRow3Fields(
                              _buildTextField(
                                controller: _superFamiliaController,
                                label: 'Super Família',
                              ),
                              _buildTextField(
                                controller: _familiaController,
                                label: 'Família *',
                                helper: 'Ex: Noctuidae',
                                validator: _requiredValidator('Família'),
                              ),
                              _buildTextField(
                                controller: _subFamiliaController,
                                label: 'Sub Família',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Ordem
                        _buildSectionCard(
                          title: 'Ordem',
                          icon: Icons.format_list_numbered,
                          color: Colors.cyan,
                          children: [
                            _buildRow4Fields(
                              _buildTextField(
                                controller: _superOrdemController,
                                label: 'Super Ordem',
                              ),
                              _buildTextField(
                                controller: _ordemController,
                                label: 'Ordem *',
                                helper: 'Ex: Lepidoptera',
                                validator: _requiredValidator('Ordem'),
                              ),
                              _buildTextField(
                                controller: _subOrdemController,
                                label: 'Sub Ordem',
                              ),
                              _buildTextField(
                                controller: _infraOrdemController,
                                label: 'Infra Ordem',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Outros
                        _buildSectionCard(
                          title: 'Outros',
                          icon: Icons.more_horiz,
                          color: Colors.brown,
                          children: [
                            _buildRow4Fields(
                              _buildTextField(
                                controller: _triboController,
                                label: 'Tribo',
                              ),
                              _buildTextField(
                                controller: _subTriboController,
                                label: 'Sub Tribo',
                              ),
                              _buildTextField(
                                controller: _generoController,
                                label: 'Gênero',
                              ),
                              _buildTextField(
                                controller: _especieController,
                                label: 'Espécie',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section: Detalhes
                        _buildSectionCard(
                          title: 'Detalhes',
                          icon: Icons.description,
                          color: Colors.green,
                          children: [
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
                                helperText:
                                    'Separe por vírgula. Ex: Milho, Soja, Algodão',
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
                                    'Descreva os tipos de danos às culturas',
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
                                    'Controle químico, biológico, cultural',
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
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Preview image if URL provided
                        if (_imageUrlController.text.isNotEmpty)
                          _buildImagePreview(),

                        const SizedBox(height: 16),

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

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.red.shade100,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow3Fields(Widget field1, Widget field2, Widget field3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field1),
        const SizedBox(width: 16),
        Expanded(child: field2),
        const SizedBox(width: 16),
        Expanded(child: field3),
      ],
    );
  }

  Widget _buildRow4Fields(
      Widget field1, Widget field2, Widget field3, Widget field4) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field1),
        const SizedBox(width: 16),
        Expanded(child: field2),
        const SizedBox(width: 16),
        Expanded(child: field3),
        const SizedBox(width: 16),
        Expanded(child: field4),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helper,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: helper,
      ),
      validator: validator,
    );
  }

  Widget _buildTipoPragaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<TipoPraga>(
          initialValue: _selectedTipoPraga,
          decoration: const InputDecoration(
            labelText: 'Tipo de Praga *',
            border: OutlineInputBorder(),
          ),
          items: TipoPraga.values.map((tipo) {
            return DropdownMenuItem<TipoPraga>(
              value: tipo,
              child: Row(
                children: [
                  Icon(tipo.icon, color: tipo.color, size: 20),
                  const SizedBox(width: 8),
                  Text(tipo.descricao),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTipoPraga = value;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _selectedTipoPraga.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _selectedTipoPraga.color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _selectedTipoPraga.color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _selectedTipoPraga.usesPlantaInfo
                      ? 'Campos botânicos'
                      : 'Campos de sintomas',
                  style: TextStyle(
                    color: _selectedTipoPraga.color,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.image, color: Colors.grey, size: 24),
                SizedBox(width: 8),
                Text(
                  'Preview da Imagem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Erro ao carregar imagem'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName é obrigatório';
      }
      if (value.trim().length < 2) {
        return 'Mínimo 2 caracteres';
      }
      return null;
    };
  }

  String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

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
          tipoPraga: _selectedTipoPraga,
          descricao: _nullIfEmpty(_descricaoController.text),
          imageUrl: _nullIfEmpty(_imageUrlController.text),
          culturasAfetadas: culturasAfetadas,
          danos: _nullIfEmpty(_danosController.text),
          controle: _nullIfEmpty(_controleController.text),
          // Taxonomia - Reino
          dominio: _nullIfEmpty(_dominioController.text),
          reino: _nullIfEmpty(_reinoController.text),
          subReino: _nullIfEmpty(_subReinoController.text),
          // Taxonomia - Clado
          clado01: _nullIfEmpty(_clado01Controller.text),
          clado02: _nullIfEmpty(_clado02Controller.text),
          clado03: _nullIfEmpty(_clado03Controller.text),
          // Taxonomia - Divisão
          superDivisao: _nullIfEmpty(_superDivisaoController.text),
          divisao: _nullIfEmpty(_divisaoController.text),
          subDivisao: _nullIfEmpty(_subDivisaoController.text),
          // Taxonomia - Classe
          classe: _nullIfEmpty(_classeController.text),
          subClasse: _nullIfEmpty(_subClasseController.text),
          // Taxonomia - Família
          superFamilia: _nullIfEmpty(_superFamiliaController.text),
          subFamilia: _nullIfEmpty(_subFamiliaController.text),
          // Taxonomia - Ordem
          superOrdem: _nullIfEmpty(_superOrdemController.text),
          subOrdem: _nullIfEmpty(_subOrdemController.text),
          infraOrdem: _nullIfEmpty(_infraOrdemController.text),
          // Taxonomia - Outros
          tribo: _nullIfEmpty(_triboController.text),
          subTribo: _nullIfEmpty(_subTriboController.text),
          genero: _nullIfEmpty(_generoController.text),
          especie: _nullIfEmpty(_especieController.text),
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
