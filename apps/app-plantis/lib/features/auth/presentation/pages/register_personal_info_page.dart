import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

// Removed unused import
// import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/register_loading_overlay.dart';
import '../../utils/validation_helpers.dart';
// Removed legacy provider import
// import '../providers/register_provider.dart';

class RegisterPersonalInfoPage extends ConsumerStatefulWidget {
  const RegisterPersonalInfoPage({super.key});

  @override
  ConsumerState<RegisterPersonalInfoPage> createState() =>
      _RegisterPersonalInfoPageState();
}

class _RegisterPersonalInfoPageState extends ConsumerState<RegisterPersonalInfoPage>
    with RegisterLoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  // Removed legacy provider - will be replaced with Riverpod
  // RegisterProvider? _registerProvider;

  // Real-time validation state
  String? _nameError;
  String? _emailError;
  bool _nameHasBeenFocused = false;
  bool _emailHasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize controllers with Riverpod provider data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final registerProvider = ref.read(registerProviderNotifier);
    //   registerProvider.goToStep(1);
    //   _nameController.text = registerProvider.registerData.name;
    //   _emailController.text = registerProvider.registerData.email;
    //
    //   // Add listeners to update provider in real-time
    //   _nameController.addListener(() {
    //     ref.read(registerProviderNotifier).updateName(_nameController.text);
    //     _validateNameField();
    //   });
    //
    //   _emailController.addListener(() {
    //     ref.read(registerProviderNotifier).updateEmail(_emailController.text);
    //     _validateEmailField();
    //   });
    // });
    
    // Add validation listeners
    _nameController.addListener(_validateNameField);
    _emailController.addListener(_validateEmailField);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Real-time validation methods
  void _validateNameField() {
    if (!_nameHasBeenFocused) return;

    setState(() {
      _nameError = ValidationHelpers.validateName(_nameController.text);
    });
  }

  void _validateEmailField() {
    if (!_emailHasBeenFocused) return;

    setState(() {
      _emailError = ValidationHelpers.validateEmail(_emailController.text);
    });
  }

  void _onNameFocusChange(bool hasFocus) {
    if (!hasFocus) {
      setState(() {
        _nameHasBeenFocused = true;
      });
      _validateNameField();
    }
  }

  void _onEmailFocusChange(bool hasFocus) {
    if (!hasFocus) {
      setState(() {
        _emailHasBeenFocused = true;
      });
      _validateEmailField();
    }
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      showRegisterLoading(message: 'Validando informações...');

      // TODO: Update provider with current values
      // final registerProvider = ref.read(registerProviderNotifier);
      // registerProvider.updateName(_nameController.text);
      // registerProvider.updateEmail(_emailController.text);

      try {
        // TODO: Validate and proceed to next step
        // final success = await registerProvider.validateAndProceedPersonalInfo();

        // Simulate validation for now
        await Future<void>.delayed(const Duration(milliseconds: 500));

        hideRegisterLoading();

        // Navigation successful, go to password page
        if (mounted) {
          context.go('/register/password');
        }
      } catch (e) {
        hideRegisterLoading();
        // Error handling is done by the provider
      }
    }
  }

  // TODO: Implement email already exists dialog when validation is implemented
  // void _showEmailAlreadyExistsDialog() { ... }

  @override
  Widget build(BuildContext context) {
    return buildWithRegisterLoading(
        child: Scaffold(
          backgroundColor: PlantisColors.primary,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.eco,
                            size: 32,
                            color: PlantisColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Inside Garden',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: PlantisColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuidado de Plantas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PlantisColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tab navigation
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Column(
                                children: [
                                  Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 3,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: PlantisColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Progress indicator (step 2/3 - personal info step)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(3, (index) {
                              // Step 2 de 3 - step 1 completa, step 2 em progresso
                              final steps = [true, true, false];
                              return [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color:
                                        steps[index]
                                            ? PlantisColors.primary
                                            : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                if (index < 2) const SizedBox(width: 8),
                              ];
                            }).expand((widget) => widget).toList(),
                      ),
                      const SizedBox(height: 48),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            const Text(
                              'Nome completo',
                              style: TextStyle(
                                color: PlantisColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Focus(
                              onFocusChange: _onNameFocusChange,
                              child: TextFormField(
                                controller: _nameController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ex: João Silva',
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: PlantisColors.primary,
                                  ),
                                  suffixIcon:
                                      _nameHasBeenFocused &&
                                              _nameController.text.isNotEmpty
                                          ? ValidationHelpers.getValidationIcon(
                                            _nameController.text,
                                            ValidationHelpers.validateName,
                                          )
                                          : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _nameHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _nameController.text,
                                                ValidationHelpers.validateName,
                                              )
                                              : PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _nameHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _nameController.text,
                                                ValidationHelpers.validateName,
                                              )
                                              : PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _nameHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _nameController.text,
                                                ValidationHelpers.validateName,
                                              )
                                              : PlantisColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorText:
                                      _nameHasBeenFocused ? _nameError : null,
                                ),
                                validator: ValidationHelpers.validateName,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email field
                            Focus(
                              onFocusChange: _onEmailFocusChange,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: PlantisColors.primary,
                                  ),
                                  suffixIcon:
                                      _emailHasBeenFocused &&
                                              _emailController.text.isNotEmpty
                                          ? ValidationHelpers.getValidationIcon(
                                            _emailController.text,
                                            ValidationHelpers.validateEmail,
                                          )
                                          : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _emailHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _emailController.text,
                                                ValidationHelpers.validateEmail,
                                              )
                                              : PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _emailHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _emailController.text,
                                                ValidationHelpers.validateEmail,
                                              )
                                              : PlantisColors.primary
                                                  .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          _emailHasBeenFocused
                                              ? ValidationHelpers.getBorderColor(
                                                _emailController.text,
                                                ValidationHelpers.validateEmail,
                                              )
                                              : PlantisColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorText:
                                      _emailHasBeenFocused ? _emailError : null,
                                ),
                                validator: ValidationHelpers.validateEmail,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Error message placeholder - will be handled by form validation
                            const SizedBox.shrink(),

                            // Navigation buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context.pop(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: PlantisColors.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Voltar',
                                      style: TextStyle(
                                        color: PlantisColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _handleNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PlantisColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Próximo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Terms text
                            const Center(
                              child: Text(
                                'Ao criar uma conta, você concorda com nossos\nTermos de Serviço e Política de Privacidade',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: PlantisColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
