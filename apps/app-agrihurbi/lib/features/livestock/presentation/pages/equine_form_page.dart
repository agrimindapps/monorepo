import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/equine_entity.dart';
import '../providers/equines_management_provider.dart';
import '../providers/equines_provider.dart';

/// Página de formulário para criação/edição de equinos
///
/// Unifica as funcionalidades de cadastro e edição em uma única página
/// Implementa validação completa e integração com EquinesManagementNotifier
class EquineFormPage extends ConsumerStatefulWidget {
  const EquineFormPage({super.key, this.equineId});

  /// ID do equino para edição (null para criação)
  final String? equineId;

  /// Se está em modo de edição
  bool get isEditing => equineId != null;

  @override
  ConsumerState<EquineFormPage> createState() => _EquineFormPageState();
}

class _EquineFormPageState extends ConsumerState<EquineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _commonNameController = TextEditingController();
  final _registrationIdController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _historyController = TextEditingController();
  final _geneticInfluencesController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  EquineTemperament? _selectedTemperament;
  CoatColor? _selectedCoat;
  EquinePrimaryUse? _selectedPrimaryUse;
  bool _isActive = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquineData();
  }

  @override
  void dispose() {
    _commonNameController.dispose();
    _registrationIdController.dispose();
    _originCountryController.dispose();
    _historyController.dispose();
    _geneticInfluencesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEquineData() async {
    if (widget.isEditing) {
      // Tenta encontrar primeiro no management provider
      final mgmtNotifier = ref.read(equinesManagementProvider.notifier);
      var equine = mgmtNotifier.findEquineById(widget.equineId!);
      
      // Se não achar, tenta no provider de leitura principal
      if (equine == null) {
        final readNotifier = ref.read(equinesProvider.notifier);
        equine = readNotifier.getEquineById(widget.equineId!);
        
        // Se ainda não achar, força carregamento (poderia usar loadEquineById se existisse no mgmt)
        if (equine == null) {
          await readNotifier.loadEquineById(widget.equineId!);
          equine = ref.read(equinesProvider).selectedEquine;
        }
      }

      if (equine != null && mounted) {
        _populateForm(equine);
      } else if (mounted) {
        _showErrorAndGoBack('Equino não encontrado');
        return;
      }
    } else {
      // Defaults para criação
      _selectedTemperament = EquineTemperament.calm;
      _selectedCoat = CoatColor.bay;
      _selectedPrimaryUse = EquinePrimaryUse.riding;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateForm(EquineEntity equine) {
    _commonNameController.text = equine.commonName;
    _registrationIdController.text = equine.registrationId;
    _originCountryController.text = equine.originCountry;
    _historyController.text = equine.history;
    _geneticInfluencesController.text = equine.geneticInfluences;
    _heightController.text = equine.height;
    _weightController.text = equine.weight;

    _selectedTemperament = equine.temperament;
    _selectedCoat = equine.coat;
    _selectedPrimaryUse = equine.primaryUse;
    _isActive = equine.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final mgmtState = ref.watch(equinesManagementProvider);
    final isOperating = mgmtState.isCreating || mgmtState.isUpdating || mgmtState.isDeleting;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Equino' : 'Novo Equino'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: isOperating ? null : _confirmDelete,
              tooltip: 'Excluir equino',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Form(
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
                              _buildPhysicalInfoSection(),
                              const SizedBox(height: 24),
                              _buildAdditionalInfoSection(),
                              const SizedBox(height: 24),
                              if (widget.isEditing) _buildStatusSection(),
                            ],
                          ),
                        ),
                      ),
                      _buildActionButtons(isOperating),
                    ],
                  ),
                ),
                if (isOperating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
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
                hintText: 'Ex: Árabe, Crioulo, Paint Horse',
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
                hintText: 'Ex: EQ-001-2024',
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
              controller: _originCountryController,
              decoration: const InputDecoration(
                labelText: 'País de Origem *',
                hintText: 'Ex: Brasil, Arábia, Estados Unidos',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<EquinePrimaryUse>(
              initialValue: _selectedPrimaryUse,
              decoration: const InputDecoration(
                labelText: 'Uso Principal *',
                border: OutlineInputBorder(),
              ),
              items: EquinePrimaryUse.values.map((use) {
                return DropdownMenuItem(
                  value: use,
                  child: Text(use.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrimaryUse = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Uso principal é obrigatório';
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
            DropdownButtonFormField<EquineTemperament>(
              initialValue: _selectedTemperament,
              decoration: const InputDecoration(
                labelText: 'Temperamento *',
                border: OutlineInputBorder(),
              ),
              items: EquineTemperament.values.map((temperament) {
                return DropdownMenuItem(
                  value: temperament,
                  child: Text(temperament.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTemperament = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Temperamento é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CoatColor>(
              initialValue: _selectedCoat,
              decoration: const InputDecoration(
                labelText: 'Pelagem *',
                border: OutlineInputBorder(),
              ),
              items: CoatColor.values.map((coat) {
                return DropdownMenuItem(
                  value: coat,
                  child: Text(coat.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCoat = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pelagem é obrigatória';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Físicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Altura',
                      hintText: '1.60m ou 16 mãos',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      hintText: '450kg',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                ),
              ],
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
              controller: _geneticInfluencesController,
              decoration: const InputDecoration(
                labelText: 'Influências Genéticas',
                hintText: 'Ex: Linhagem árabe pura, cruzamento com PSI',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _historyController,
              decoration: const InputDecoration(
                labelText: 'História da Raça',
                hintText: 'Breve história e origens da raça',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              maxLength: 1000,
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
                _isActive ? 'Equino ativo no rebanho' : 'Equino inativo',
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

  Widget _buildActionButtons(bool isLoading) {
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
                onPressed: isLoading ? null : () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveEquine,
                child: Text(widget.isEditing ? 'Salvar' : 'Criar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEquine() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    final notifier = ref.read(equinesManagementProvider.notifier);
    
    final equine = EquineEntity(
      id: widget.equineId ?? '',
      commonName: _commonNameController.text.trim(),
      registrationId: _registrationIdController.text.trim().toUpperCase(),
      originCountry: _originCountryController.text.trim(),
      temperament: _selectedTemperament!,
      coat: _selectedCoat!,
      primaryUse: _selectedPrimaryUse!,
      height: _heightController.text.trim(),
      weight: _weightController.text.trim(),
      geneticInfluences: _geneticInfluencesController.text.trim(),
      history: _historyController.text.trim(),
      isActive: _isActive,
      imageUrls: const [], // TODO: Implementar upload de imagens
      createdAt: DateTime.now(), // Será ignorado/atualizado pelo backend/usecase
      updatedAt: DateTime.now(),
    );

    final success = widget.isEditing
        ? await notifier.updateEquine(equine)
        : await notifier.createEquine(equine);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Equino ${widget.isEditing ? "atualizado" : "criado"} com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } else {
      _showErrorMessage(notifier.errorMessage ?? 'Operação falhou');
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
          'Tem certeza que deseja excluir este equino?\n\n'
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
              _deleteEquine();
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

  void _deleteEquine() async {
    final notifier = ref.read(equinesManagementProvider.notifier);
    final success = await notifier.deleteEquine(widget.equineId!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Equino excluído com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      context.pop();
    } else {
      _showErrorMessage(notifier.errorMessage ?? 'Erro ao excluir');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Erro: $message')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showErrorAndGoBack(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      context.pop();
    });
  }
}
