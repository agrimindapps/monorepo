import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/bovine_entity.dart';
import '../providers/bovines_provider.dart';

/// Página de formulário para criação/edição de bovinos
///
/// Unifica as funcionalidades de cadastro e edição em uma única página
/// Implementa validação completa e integração com BovinesProvider
class BovineFormPage extends ConsumerStatefulWidget {
  const BovineFormPage({super.key, this.bovineId});

  /// ID do bovino para edição (null para criação)
  final String? bovineId;

  /// Se está em modo de edição
  bool get isEditing => bovineId != null;

  @override
  ConsumerState<BovineFormPage> createState() => _BovineFormPageState();
}

class _BovineFormPageState extends ConsumerState<BovineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _commonNameController = TextEditingController();
  final _registrationIdController = TextEditingController();
  final _breedController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _animalTypeController = TextEditingController();
  final _originController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _purposeController = TextEditingController();
  final _tagsController = TextEditingController();
  BovineAptitude? _selectedAptitude;
  BreedingSystem? _selectedBreedingSystem;
  List<String> _selectedTags = [];
  bool _isActive = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBovineData();
  }

  @override
  void dispose() {
    _commonNameController.dispose();
    _registrationIdController.dispose();
    _breedController.dispose();
    _originCountryController.dispose();
    _animalTypeController.dispose();
    _originController.dispose();
    _characteristicsController.dispose();
    _purposeController.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBovineData() async {
    if (!mounted) return; // ✅ Safety check at start

    if (widget.isEditing) {
      final provider = ref.read(bovinesProviderProvider);
      var bovine = provider.getBovineById(widget.bovineId!);
      if (bovine == null) {
        final success = await provider.loadBovineById(widget.bovineId!);
        if (success) {
          bovine = provider.selectedBovine;
        }
      }

      if (!mounted) return; // ✅ Safety check after potential async operations

      if (bovine != null) {
        _populateForm(bovine);
      } else {
        final provider = ref.read(bovinesProviderProvider);
        final errorMsg = provider.errorMessage ?? 'Bovino não encontrado';
        _showErrorAndGoBack(errorMsg);
        return;
      }
    }

    if (mounted) {
      // ✅ Safety check before setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateForm(BovineEntity bovine) {
    _commonNameController.text = bovine.commonName;
    _registrationIdController.text = bovine.registrationId;
    _breedController.text = bovine.breed;
    _originCountryController.text = bovine.originCountry;
    _animalTypeController.text = bovine.animalType;
    _originController.text = bovine.origin;
    _characteristicsController.text = bovine.characteristics;
    _purposeController.text = bovine.purpose;
    _tagsController.text = bovine.tags.join(', ');

    _selectedAptitude = bovine.aptitude;
    _selectedBreedingSystem = bovine.breedingSystem;
    _selectedTags = List.from(bovine.tags);
    _isActive = bovine.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Bovino' : 'Novo Bovino'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Excluir bovino',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando bovino...'),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                final provider = ref.watch(bovinesProviderProvider);
                if (provider.isLoadingBovine) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Carregando dados do bovino...'),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${widget.bovineId}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.errorMessage != null && widget.isEditing) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar bovino',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Voltar'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                provider.clearError();
                                _loadBovineData();
                              },
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBasicInfoSection(),
                              const SizedBox(height: 24),
                              _buildCharacteristicsSection(),
                              const SizedBox(height: 24),
                              _buildAdditionalInfoSection(),
                              const SizedBox(height: 24),
                              if (widget.isEditing) _buildStatusSection(),
                            ],
                          ),
                        ),
                      ),
                      _buildActionButtons(provider),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commonNameController,
              decoration: const InputDecoration(
                labelText: 'Nome Comum *',
                hintText: 'Ex: Nelore, Angus, Brahman',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome comum é obrigatório';
                }
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationIdController,
              decoration: const InputDecoration(
                labelText: 'ID de Registro',
                hintText: 'Ex: BR-001-2024',
                border: OutlineInputBorder(),
                helperText: 'Deixe vazio para gerar automaticamente',
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-_]')),
                LengthLimitingTextInputFormatter(20),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (value.length < 3) {
                    return 'ID deve ter pelo menos 3 caracteres';
                  }
                  final regExp = RegExp(r'^[A-Z0-9\-_]{3,20}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Use apenas letras maiúsculas, números, hífens e underscores';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Raça *',
                hintText: 'Ex: Nelore, Angus, Brahman',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Raça é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originCountryController,
              decoration: const InputDecoration(
                labelText: 'País de Origem *',
                hintText: 'Ex: Brasil, Índia, Escócia',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'País de origem é obrigatório';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BovineAptitude>(
              initialValue: _selectedAptitude,
              decoration: const InputDecoration(
                labelText: 'Aptidão',
                border: OutlineInputBorder(),
              ),
              items: BovineAptitude.values.map((aptitude) {
                return DropdownMenuItem(
                  value: aptitude,
                  child: Text(aptitude.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAptitude = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BreedingSystem>(
              initialValue: _selectedBreedingSystem,
              decoration: const InputDecoration(
                labelText: 'Sistema de Criação',
                border: OutlineInputBorder(),
              ),
              items: BreedingSystem.values.map((system) {
                return DropdownMenuItem(
                  value: system,
                  child: Text(system.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBreedingSystem = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Finalidade',
                hintText: 'Ex: Reprodução, Engorda, Ordenha',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Adicionais',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Ex: reprodutor, premiado, importado',
                border: OutlineInputBorder(),
                helperText: 'Separe as tags com vírgulas',
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                _selectedTags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _animalTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Animal *',
                hintText: 'Ex: Bovino, Zebu',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tipo de animal é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origem *',
                hintText: 'Origem detalhada do bovino',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Origem é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _characteristicsController,
              decoration: const InputDecoration(
                labelText: 'Características *',
                hintText: 'Características físicas do bovino',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Características são obrigatórias';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ativo'),
              subtitle: Text(
                _isActive ? 'Bovino ativo no rebanho' : 'Bovino inativo',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BovinesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isCreating || provider.isUpdating
                    ? null
                    : () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: provider.isCreating || provider.isUpdating
                    ? null
                    : _saveBovine,
                child: provider.isCreating || provider.isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Salvar' : 'Criar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBovine() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    final provider = ref.read(bovinesProviderProvider);
    final now = DateTime.now();

    final bovine = BovineEntity(
      id: widget.isEditing ? widget.bovineId! : '',
      commonName: _commonNameController.text.trim(),
      registrationId: _registrationIdController.text.trim(),
      breed: _breedController.text.trim(),
      originCountry: _originCountryController.text.trim(),
      animalType: _animalTypeController.text.trim(),
      origin: _originController.text.trim(),
      characteristics: _characteristicsController.text.trim(),
      purpose: _purposeController.text.trim(),
      tags: _selectedTags,
      aptitude: _selectedAptitude ?? BovineAptitude.beef,
      breedingSystem: _selectedBreedingSystem ?? BreedingSystem.extensive,
      imageUrls: widget.isEditing
          ? (provider.selectedBovine?.imageUrls ?? [])
          : <String>[],
      isActive: _isActive,
      createdAt: widget.isEditing
          ? (provider.selectedBovine?.createdAt ?? now)
          : now,
      updatedAt: now,
    );

    bool success;
    if (widget.isEditing) {
      success = await provider.updateBovine(bovine);
    } else {
      success = await provider.createBovine(bovine);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Bovino atualizado com sucesso!'
                : 'Bovino criado com sucesso!',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onError,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Erro: ${provider.errorMessage ?? 'Operação falhou'}',
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _scrollToFirstError() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este bovino?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBovine();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _deleteBovine() async {
    final provider = ref.read(bovinesProviderProvider);
    final success = await provider.deleteBovine(
      widget.bovineId!,
      confirmed: true,
    );

    if (!mounted) return; // ✅ Safety check after async operation

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bovino excluído com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${provider.errorMessage}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showErrorAndGoBack(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // ✅ Safety check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Tentar Novamente',
            onPressed: () {
              _loadBovineData();
            },
          ),
        ),
      );
      context.pop();
    });
  }
}
