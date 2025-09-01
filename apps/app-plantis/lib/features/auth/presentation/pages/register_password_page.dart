import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/register_loading_overlay.dart';
import '../../utils/auth_validators.dart';
import '../providers/auth_provider.dart';
import '../providers/register_provider.dart';

class RegisterPasswordPage extends StatefulWidget {
  const RegisterPasswordPage({super.key});

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> 
    with RegisterLoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  RegisterProvider? _registerProvider;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerProvider = di.sl<RegisterProvider>();
      _registerProvider!.goToStep(2);
      _passwordController.text = _registerProvider!.registerData.password;
      _confirmPasswordController.text = _registerProvider!.registerData.confirmPassword;
      
      // Add listeners to update provider in real-time
      _passwordController.addListener(() {
        _registerProvider?.updatePassword(_passwordController.text);
      });
      
      _confirmPasswordController.addListener(() {
        _registerProvider?.updateConfirmPassword(_confirmPasswordController.text);
      });
    });
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
    if (_formKey.currentState!.validate() && _registerProvider != null) {
      // Update provider with current password values
      _registerProvider!.updatePassword(_passwordController.text);
      _registerProvider!.updateConfirmPassword(_confirmPasswordController.text);
      
      // Validate password step
      if (_registerProvider!.validatePassword()) {
        showRegisterLoading(message: 'Criando conta...');
        
        final authProvider = context.read<AuthProvider>();
        final registerData = _registerProvider!.registerData;

        updateRegisterLoadingMessage('Conectando ao servidor...');
        
        await authProvider.register(
          registerData.email,
          registerData.password,
          registerData.name,
        );

        if (authProvider.isAuthenticated && mounted) {
          updateRegisterLoadingMessage('Configurando perfil...');
          await Future<void>.delayed(const Duration(milliseconds: 500)); // Small delay for UX
          
          hideRegisterLoading();
          
          // Clear registration data after successful registration
          _registerProvider!.reset();
          
          if (mounted) {
            context.go('/plants');
          }
        } else {
          hideRegisterLoading();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildWithRegisterLoading(
      child: ChangeNotifierProvider.value(
        value: _registerProvider ?? di.sl<RegisterProvider>(),
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
                      const Icon(Icons.eco, size: 32, color: PlantisColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'PlantApp',
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
                              Container(height: 3, color: Colors.grey.shade300),
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

                  // Progress indicator (step 3/3)
                  Consumer<RegisterProvider>(
                    builder: (context, registerProvider, _) {
                      final steps = registerProvider.progressSteps;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: steps[index] 
                                    ? PlantisColors.primary 
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            if (index < 2) const SizedBox(width: 8),
                          ];
                        }).expand((widget) => widget).toList(),
                      );
                    },
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

                        // Error message - RegisterProvider
                        Consumer<RegisterProvider>(
                          builder: (context, registerProvider, _) {
                            if (registerProvider.errorMessage != null) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: PlantisColors.errorLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: PlantisColors.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        registerProvider.errorMessage!,
                                        style: const TextStyle(
                                          color: PlantisColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Error message - AuthProvider
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            if (authProvider.errorMessage != null) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: PlantisColors.errorLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: PlantisColors.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: const TextStyle(
                                          color: PlantisColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

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
                              child: Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return ElevatedButton(
                                    onPressed:
                                        authProvider.isLoading
                                            ? null
                                            : _handleCreateAccount,
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
                                    child:
                                        authProvider.isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Text(
                                              'Criar Conta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  );
                                },
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
    ),
    );
  }
}
