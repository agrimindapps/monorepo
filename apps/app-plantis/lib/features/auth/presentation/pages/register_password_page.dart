import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

// Removed unused import
// import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/register_loading_overlay.dart';
import '../../utils/auth_validators.dart';
// Removed unused auth provider import
// import '../providers/auth_provider.dart' as local;
// Removed legacy provider import
// import '../providers/register_provider.dart';

class RegisterPasswordPage extends ConsumerStatefulWidget {
  const RegisterPasswordPage({super.key});

  @override
  ConsumerState<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends ConsumerState<RegisterPasswordPage>
    with RegisterLoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Removed legacy provider - will be replaced with Riverpod
  // RegisterProvider? _registerProvider;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize controllers with Riverpod provider data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final registerProvider = ref.read(registerProviderNotifier);
    //   registerProvider.goToStep(2);
    //   _passwordController.text = registerProvider.registerData.password;
    //   _confirmPasswordController.text = registerProvider.registerData.confirmPassword;
    //
    //   // Add listeners to update provider in real-time
    //   _passwordController.addListener(() {
    //     ref.read(registerProviderNotifier).updatePassword(_passwordController.text);
    //   });
    //
    //   _confirmPasswordController.addListener(() {
    //     ref.read(registerProviderNotifier).updateConfirmPassword(_confirmPasswordController.text);
    //   });
    // });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Use AuthValidators for consistent password validation across the app
  String? _validatePassword(String? value) {
    return AuthValidators.validatePassword(value ?? '', isRegistration: true);
  }

  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Validate passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senhas não coincidem')),
        );
        return;
      }

      showRegisterLoading(message: 'Criando conta...');

      // TODO: Replace with actual auth provider
      // final authProvider = ref.read(authProviderNotifier);
      // final registerData = ref.read(registerProviderNotifier).registerData;
      // await authProvider.register(registerData.email, password, registerData.name);
      
      updateRegisterLoadingMessage('Conectando ao servidor...');

      // Simulate registration for now
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        updateRegisterLoadingMessage('Configurando perfil...');
        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        ); // Small delay for UX

        hideRegisterLoading();

        // TODO: Clear registration data after successful registration
        // ref.read(registerProviderNotifier).reset();

        if (mounted) {
          context.go('/plants');
        }
      } else {
        hideRegisterLoading();
      }
    }
  }

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

                    // Progress indicator (step 3/3 - password step)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(3, (index) {
                            // Step 3 de 3 - todas etapas anteriores completas
                            final steps = [true, true, true];
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
                          // Password field
                          const Text(
                            'Senha',
                            style: TextStyle(
                              color: PlantisColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Mín. 8 caracteres: maiúscula, minúscula, número e símbolo',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: PlantisColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: PlantisColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: PlantisColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: PlantisColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: PlantisColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 24),

                          // Confirm Password field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Confirmar senha',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: PlantisColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: PlantisColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: PlantisColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: PlantisColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: PlantisColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              return AuthValidators.validatePasswordConfirmation(
                                _passwordController.text,
                                value ?? '',
                              );
                            },
                          ),
                          const SizedBox(height: 48),

                          // Error message placeholder
                          const SizedBox.shrink(),

                          // Auth error message placeholder - will be handled by Riverpod later
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
                                  onPressed: _handleCreateAccount,
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
                                    'Criar Conta',
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