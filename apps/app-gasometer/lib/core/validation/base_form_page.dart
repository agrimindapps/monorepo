import 'package:flutter/material.dart';


import '../../../core/theme/gasometer_colors.dart';
import 'form_mixins.dart';
import 'form_widgets.dart';

/// Interface for form providers to ensure type safety
abstract class IFormProvider {
  bool get isLoading;
  String? get lastError;
  GlobalKey<FormState>? get formKey;
  bool get canSubmit;
  bool validateForm();
  void dispose();
}

/// Abstract base class for form pages with common functionality
/// 
/// This class provides a standardized structure for form pages that includes:
/// - Loading state management
/// - Error handling with standardized dialogs
/// - Form validation
/// - Navigation handling after successful operations
/// - Consistent scaffold structure
abstract class BaseFormPage<T extends ChangeNotifier> extends StatefulWidget {
  const BaseFormPage({super.key});
  
  @override
  BaseFormPageState<T> createState();
}

abstract class BaseFormPageState<T extends ChangeNotifier> extends State<BaseFormPage<T>>
    with FormLoadingMixin, FormErrorMixin, FormValidationMixin {
  
  late T _formProvider;
  bool _isInitialized = false;
  
  /// Form provider getter for child classes
  T get formProvider => _formProvider;
  
  /// Whether the form is in edit mode (override in child classes if needed)
  bool get isEditMode => false;
  
  /// Page title - must be implemented by child classes
  String get pageTitle;
  
  /// AppBar title for editing mode
  String get editTitle => 'Editar $pageTitle';
  
  /// AppBar title for adding mode  
  String get addTitle => 'Novo $pageTitle';
  
  /// Current title based on mode
  String get currentTitle => isEditMode ? editTitle : addTitle;
  
  /// Create the form provider instance - must be implemented by child classes
  T createFormProvider();
  
  /// Initialize the form provider after creation
  Future<void> initializeFormProvider(T provider) async {
    // Default empty implementation, override if needed
  }
  
  /// Build the form content - must be implemented by child classes
  Widget buildFormContent(BuildContext context, T provider);
  
  /// Form submission logic - must be implemented by child classes
  Future<bool> onSubmitForm(BuildContext context, T provider);
  
  /// Submit button text
  String get submitButtonText => isEditMode ? 'Salvar' : 'Adicionar';
  
  /// Called after successful form submission
  void onFormSubmitSuccess() {
    if (mounted) {
      // Fechar o dialog imediatamente após sucesso local
      Navigator.of(context).pop(true);
      
      // Mostrar confirmação após fechar o dialog
      showSuccessSnackbar(isEditMode 
          ? '$pageTitle atualizado com sucesso!' 
          : '$pageTitle cadastrado com sucesso!');
    }
  }
  
  /// Called when form submission fails
  void onFormSubmitFailure(String error) {
    showErrorDialog(error);
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }
  
  Future<void> _initializeProviders() async {
    try {
      _formProvider = createFormProvider();
      
      await initializeFormProvider(_formProvider);
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      showErrorDialog('Erro ao inicializar formulário: $e');
    }
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      // ✅ TYPE SAFETY FIX: No more dangerous casting, use interface method
      _formProvider.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingScaffold();
    }
    
// Directly use the form provider without Provider package
      return Stack(
        children: [
          _buildFormScaffold(context, _formProvider),
          if (isLoading(_formProvider as IFormProvider))
            const FormLoadingOverlay(),
        ],
      );
  }
  
  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: GasometerColors.getPageBackgroundColor(context),
      appBar: AppBar(
        title: Text(currentTitle),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildFormScaffold(BuildContext context, T formProvider) {
    return Scaffold(
      backgroundColor: GasometerColors.getPageBackgroundColor(context),
      appBar: AppBar(
        title: Text(currentTitle),
        actions: [
          _buildSubmitButton(context, formProvider),
        ],
      ),
      body: _buildFormBody(context, formProvider),
    );
  }
  
  Widget _buildSubmitButton(BuildContext context, T formProvider) {
    final canSubmit = this.canSubmit(formProvider as IFormProvider);
    
    return Semantics(
      label: isEditMode 
        ? 'Salvar alterações do $pageTitle'
        : 'Adicionar novo $pageTitle',
      hint: canSubmit
        ? 'Botão habilitado, toque para salvar'
        : 'Botão desabilitado, preencha todos os campos obrigatórios',
      child: TextButton(
        onPressed: canSubmit ? () => _submitForm() : null,
        child: Text(
          submitButtonText,
          style: TextStyle(
            color: canSubmit
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormBody(BuildContext context, T formProvider) {
    // Check for errors and show them
    final error = getLastError(formProvider as IFormProvider);
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(error);
      });
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: getFormKey(formProvider as IFormProvider),
        child: buildFormContent(context, formProvider),
      ),
    );
  }
  
  Future<void> _submitForm() async {
    if (!validateForm(_formProvider as IFormProvider)) {
      showErrorDialog('Por favor, corrija os erros no formulário');
      return;
    }
    
    try {
      final success = await onSubmitForm(context, _formProvider);
      
      if (success) {
        onFormSubmitSuccess();
      } else {
        onFormSubmitFailure('Erro ao salvar $pageTitle');
      }
    } catch (e) {
      onFormSubmitFailure('Erro inesperado: $e');
    }
  }
}