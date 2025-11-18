import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/base_provider.dart';
import '../widgets/form_dialog.dart';
import 'base_form_page.dart';
import 'form_mixins.dart';

final _formProviderOverride = Provider<dynamic>((ref) => null);

/// Abstract base class for form dialogs with common functionality
///
/// This class provides a standardized structure for form dialogs that includes:
/// - Loading state management
/// - Error handling with standardized dialogs
/// - Form validation
/// - Navigation handling after successful operations
/// - Consistent dialog structure with header and actions
abstract class BaseFormDialog<T extends ChangeNotifier> extends StatefulWidget {
  const BaseFormDialog({super.key});

  @override
  BaseFormDialogState<T> createState();
}

abstract class BaseFormDialogState<T extends ChangeNotifier>
    extends State<BaseFormDialog<T>>
    with FormLoadingMixin, FormErrorMixin, FormValidationMixin {
  late T _formProvider;
  bool _isInitialized = false;

  /// Form provider getter for child classes
  T get formProvider => _formProvider;

  /// Whether the form is in edit mode (override in child classes if needed)
  bool get isEditMode => false;

  /// Dialog title - must be implemented by child classes
  String get dialogTitle;

  /// Dialog subtitle - must be implemented by child classes
  String get dialogSubtitle;

  /// Dialog header icon - must be implemented by child classes
  IconData get headerIcon;

  /// Submit button text
  String get submitButtonText => isEditMode ? 'Salvar' : 'Salvar';

  /// Cancel button text
  String get cancelButtonText => 'Cancelar';

  /// Create the form provider instance - must be implemented by child classes
  T createFormProvider();

  /// Initialize the form provider after creation
  Future<void> initializeFormProvider(T provider) async {}

  /// Build the form content - must be implemented by child classes
  Widget buildFormContent(BuildContext context, T provider);

  /// Form submission logic - must be implemented by child classes
  Future<bool> onSubmitForm(BuildContext context, T provider);

  /// Called after successful form submission
  void onFormSubmitSuccess() {
    if (mounted) {
      Navigator.of(context).pop(true);
      showSuccessSnackbar(
        isEditMode
            ? 'Item atualizado com sucesso!'
            : 'Item cadastrado com sucesso!',
      );
    }
  }

  /// Called when form submission fails
  void onFormSubmitFailure(String error) {
    showErrorSnackbar(error);
  }

  /// Called when form is cancelled
  void onFormCancel() {
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProviders();
      }
    });
  }

  Future<void> _initializeProviders() async {
    if (!mounted) return;

    try {
      _formProvider = createFormProvider();

      await initializeFormProvider(_formProvider);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog('Erro ao inicializar formulário: $e');
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized && _formProvider is BaseProvider) {
      (_formProvider as BaseProvider).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingDialog();
    }

    return ProviderScope(
      overrides: [_formProviderOverride.overrideWithValue(_formProvider)],
      child: Consumer(
        builder: (context, ref, _) {
          final formProvider = ref.watch(_formProviderOverride) as T;
          return _buildFormDialog(context, formProvider);
        },
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return FormDialog(
      title: dialogTitle,
      subtitle: dialogSubtitle,
      headerIcon: headerIcon,
      isLoading: true,
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: null,
      content: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormDialog(BuildContext context, T formProvider) {
    String? error;
    bool loading = false;
    bool canSubmitForm = false;
    GlobalKey<FormState>? formKey;

    if (formProvider is IFormProvider) {
      final provider = formProvider as IFormProvider;
      error = provider.lastError;
      loading = provider.isLoading;
      canSubmitForm = provider.canSubmit;
      formKey = provider.formKey;
    }

    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showErrorSnackbar(error!);
        }
      });
    }

    return FormDialog(
      title: dialogTitle,
      subtitle: dialogSubtitle,
      headerIcon: headerIcon,
      isLoading: loading,
      cancelButtonText: cancelButtonText,
      confirmButtonText: submitButtonText,
      onCancel: onFormCancel,
      onConfirm: canSubmitForm ? () => _submitForm() : null,
      content: Form(
        key: formKey ?? GlobalKey<FormState>(),
        child: buildFormContent(context, formProvider),
      ),
    );
  }

  Future<void> _submitForm() async {
    bool isValid = false;
    if (_formProvider is IFormProvider) {
      isValid = (_formProvider as IFormProvider).validateForm();
    }

    if (!isValid) {
      showErrorSnackbar('Por favor, corrija os erros no formulário');
      return;
    }

    try {
      final success = await onSubmitForm(context, _formProvider);

      if (success) {
        onFormSubmitSuccess();
      } else {
        onFormSubmitFailure('Erro ao salvar');
      }
    } catch (e) {
      onFormSubmitFailure('Erro inesperado: $e');
    }
  }
}
