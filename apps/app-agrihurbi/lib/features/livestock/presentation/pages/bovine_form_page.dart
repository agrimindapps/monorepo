import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// import '../../../../core/di/injection_container.dart';
import '../../domain/services/bovine_form_service.dart';
import '../../domain/services/livestock_validation_service.dart';
import '../providers/bovine_form_provider.dart';
import '../providers/bovines_provider.dart';
import '../widgets/bovine_additional_info_section.dart';
import '../widgets/bovine_basic_info_section.dart';
import '../widgets/bovine_characteristics_section.dart';
import '../widgets/bovine_form_action_buttons.dart';
import '../widgets/bovine_status_section.dart';

/// Local form provider using legacy pattern (will be migrated separately)
final bovineFormLocalProvider = ChangeNotifierProvider<BovineFormProvider>((ref) {
  final validationService = LivestockValidationService();
  final formService = BovineFormService(validationService);
  return BovineFormProvider(formService);
});

/// Página de formulário para criação/edição de bovinos - REFATORADO
///
/// ARQUITETURA LIMPA:
/// - Separação de responsabilidades em widgets dedicados
/// - BovineFormProvider para state management otimizado
/// - BovineFormService para lógica de negócio centralizada
/// - Design System unificado em todos os componentes
/// - Controller pooling para otimização de memória
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBovineData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = ref.watch(bovineFormLocalProvider);
    final bovinesState = ref.watch(bovinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Bovino' : 'Novo Bovino'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildFormContent(formProvider, bovinesState),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando formulário...'),
        ],
      ),
    );
  }

  Widget _buildFormContent(
    BovineFormProvider formProvider,
    BovinesState bovinesState,
  ) {
    if (bovinesState.errorMessage != null && widget.isEditing) {
      return _buildErrorState(bovinesState);
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(child: _buildScrollableForm(formProvider, bovinesState)),
          _buildActionButtons(formProvider),
        ],
      ),
    );
  }

  Widget _buildScrollableForm(
    BovineFormProvider formProvider,
    BovinesState bovinesState,
  ) {
    final isOperating =
        bovinesState.isCreating || bovinesState.isUpdating;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BovineBasicInfoSection(
            commonNameController: formProvider.commonNameController,
            registrationIdController: formProvider.registrationIdController,
            breedController: formProvider.breedController,
            originCountryController: formProvider.originCountryController,
            formService: ref.read(bovineFormLocalProvider).formService,
            enabled: !isOperating,
          ),
          const SizedBox(height: 24),
          BovineCharacteristicsSection(
            purposeController: formProvider.purposeController,
            formService: ref.read(bovineFormLocalProvider).formService,
            selectedAptitude: formProvider.selectedAptitude,
            selectedBreedingSystem: formProvider.selectedBreedingSystem,
            onAptitudeChanged: formProvider.updateAptitude,
            onBreedingSystemChanged: formProvider.updateBreedingSystem,
            enabled: !isOperating,
          ),
          const SizedBox(height: 24),
          BovineAdditionalInfoSection(
            tagsController: formProvider.tagsController,
            animalTypeController: formProvider.animalTypeController,
            originController: formProvider.originController,
            characteristicsController: formProvider.characteristicsController,
            formService: ref.read(bovineFormLocalProvider).formService,
            onTagsChanged: formProvider.updateTags,
            selectedTags: formProvider.selectedTags,
            enabled: !isOperating,
          ),
          const SizedBox(height: 24),
          if (widget.isEditing)
            BovineStatusSection(
              isActive: formProvider.isActive,
              onActiveChanged: formProvider.updateActiveStatus,
              enabled: !isOperating,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BovineFormProvider formProvider) {
    return BovineFormActionButtons(
      onCancel: () => context.pop(),
      onSave: _saveBovine,
      isEditing: widget.isEditing,
      onDelete: widget.isEditing ? _deleteBovine : null,
      hasUnsavedChanges: formProvider.hasUnsavedChanges,
    );
  }

  Widget _buildErrorState(BovinesState state) {
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
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  ref.read(bovinesProvider.notifier).clearError();
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

  Future<void> _loadBovineData() async {
    if (!mounted) return;

    try {
      if (widget.isEditing) {
        await _loadBovineForEditing();
      } else {
        ref.read(bovineFormLocalProvider).initializeForCreation();
      }
    } catch (e) {
      if (mounted) {
        _showErrorAndGoBack('Erro ao carregar dados: $e');
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBovineForEditing() async {
    final notifier = ref.read(bovinesProvider.notifier);
    var bovine = notifier.getBovineById(widget.bovineId!);
    if (bovine == null) {
      final success = await notifier.loadBovineById(widget.bovineId!);
      if (success) bovine = notifier.selectedBovine;
    }

    if (!mounted) return;

    if (bovine != null) {
      ref.read(bovineFormLocalProvider).initializeForEditing(bovine);
    } else {
      final errorMsg = notifier.errorMessage ?? 'Bovino não encontrado';
      _showErrorAndGoBack(errorMsg);
    }
  }

  void _saveBovine() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    final notifier = ref.read(bovinesProvider.notifier);
    final bovine = ref.read(bovineFormLocalProvider).prepareBovineForSaving(
          isEditing: widget.isEditing,
          existingId: widget.bovineId,
          existingImageUrls: notifier.selectedBovine?.imageUrls,
          existingCreatedAt: notifier.selectedBovine?.createdAt,
        );

    final success = widget.isEditing
        ? await notifier.updateBovine(bovine)
        : await notifier.createBovine(bovine);

    if (!mounted) return;

    if (success) {
      ref.read(bovineFormLocalProvider).markAsSaved();
      _showSuccessMessage(widget.isEditing ? 'atualizado' : 'criado');
      context.pop();
    } else {
      _showErrorMessage(notifier.errorMessage ?? 'Operação falhou');
    }
  }

  void _deleteBovine() async {
    final notifier = ref.read(bovinesProvider.notifier);
    final success = await notifier.deleteBovine(
      widget.bovineId!,
      confirmed: true,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessMessage('excluído');
      context.pop();
    } else {
      _showErrorMessage('Erro ao excluir: ${notifier.errorMessage}');
    }
  }

  void _scrollToFirstError() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSuccessMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bovino $action com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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
          action: SnackBarAction(
            label: 'Tentar Novamente',
            onPressed: _loadBovineData,
          ),
        ),
      );
      context.pop();
    });
  }
}
