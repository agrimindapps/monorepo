import 'dart:ui' as ui;

import 'package:core/core.dart' hide Column, Consumer, FormState;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart' as auth_providers;
import '../../../../core/theme/accessibility_tokens.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../utils/auth_validators.dart';

/// Login form widget - encapsulates email, password, remember me, and submit button
class LoginForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final FocusNode? loginButtonFocusNode;
  final ValueChanged<bool> onObscurePasswordChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onObscurePasswordChanged,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.onForgotPassword,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.loginButtonFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(auth_providers.authProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccessibleTextField(
            controller: emailController,
            focusNode: emailFocusNode,
            nextFocusNode: passwordFocusNode,
            labelText: 'E-mail',
            hintText: 'Digite seu email',
            semanticLabel: 'Campo de e-mail para login',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.email,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!AuthValidators.isValidEmail(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          AccessibleTextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            semanticLabel: 'Campo de senha para login',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autocomplete: AutofillHints.password,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePassword(
                value ?? '',
                isRegistration: false,
              );
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: PasswordVisibilityToggle(
              isObscured: obscurePassword,
              onToggle: onObscurePasswordChanged,
              fieldName: 'senha',
              fieldSemanticName: 'password',
            ),
            onSubmitted: (value) {
              loginButtonFocusNode?.requestFocus();
            },
          ),
          const SizedBox(height: 16),
          RememberMeSection(
            rememberMe: rememberMe,
            onRememberMeChanged: onRememberMeChanged,
            onForgotPassword: onForgotPassword,
          ),
          const SizedBox(height: 20),
          _buildErrorMessage(authState),
          _buildLoginButton(context, ref, authState),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AsyncValue<auth_providers.AuthState> authState) {
    return authState.when(
      data: (state) {
        if (state.errorMessage != null) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<auth_providers.AuthState> authState,
  ) {
    return authState.when(
      data: (state) {
        final isAnonymousLoading =
            state.currentOperation == AuthOperation.anonymous;
        return AccessibleButton(
          focusNode: loginButtonFocusNode,
          onPressed: (state.isLoading || isAnonymousLoading) ? null : onLogin,
          semanticLabel: AccessibilityTokens.getSemanticLabel(
            'login_button',
            'Fazer login',
          ),
          tooltip: 'Entrar com suas credenciais',
          backgroundColor: (state.isLoading || isAnonymousLoading)
              ? Colors.grey.shade400
              : PlantisColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            AccessibilityTokens.largeTouchTargetSize,
          ),
          hapticPattern: 'medium',
          child: state.isLoading
              ? Semantics(
                  label: AccessibilityTokens.getSemanticLabel(
                    'loading',
                    'Fazendo login',
                  ),
                  liveRegion: true,
                  child: const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: AccessibilityTokens.getAccessibleFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }
}

/// Register form widget - encapsulates name, email, password, confirm password, and submit button
class RegisterForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final FocusNode? nameFocusNode;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final FocusNode? confirmPasswordFocusNode;
  final FocusNode? registerButtonFocusNode;
  final ValueChanged<bool> onObscurePasswordChanged;
  final ValueChanged<bool> onObscureConfirmPasswordChanged;
  final VoidCallback onRegister;
  final VoidCallback onTermsOfService;
  final VoidCallback onPrivacyPolicy;

  const RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onObscurePasswordChanged,
    required this.onObscureConfirmPasswordChanged,
    required this.onRegister,
    required this.onTermsOfService,
    required this.onPrivacyPolicy,
    this.nameFocusNode,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.confirmPasswordFocusNode,
    this.registerButtonFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(auth_providers.authProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccessibleTextField(
            controller: nameController,
            focusNode: nameFocusNode,
            nextFocusNode: emailFocusNode,
            labelText: 'Nome completo',
            hintText: 'Digite seu nome completo',
            semanticLabel: 'Campo de nome para cadastro',
            textInputAction: TextInputAction.next,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validateName(value ?? '');
            },
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 16),
          AccessibleTextField(
            controller: emailController,
            focusNode: emailFocusNode,
            nextFocusNode: passwordFocusNode,
            labelText: 'E-mail',
            hintText: 'Digite seu email',
            semanticLabel: 'Campo de e-mail para cadastro',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.email,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!AuthValidators.isValidEmail(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 16),
          AccessibleTextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            nextFocusNode: confirmPasswordFocusNode,
            labelText: 'Senha',
            hintText: 'Mínimo 8 caracteres',
            semanticLabel: 'Campo de senha para cadastro',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            autocomplete: AutofillHints.newPassword,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePassword(
                value ?? '',
                isRegistration: true,
              );
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: PasswordVisibilityToggle(
              isObscured: obscurePassword,
              onToggle: onObscurePasswordChanged,
              fieldName: 'senha',
              fieldSemanticName: 'register_password',
            ),
          ),
          const SizedBox(height: 16),
          AccessibleTextField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            labelText: 'Confirmar senha',
            hintText: 'Digite a senha novamente',
            semanticLabel: 'Campo de confirmação de senha',
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            isRequired: true,
            validator: (value) {
              return AuthValidators.validatePasswordConfirmation(
                passwordController.text,
                value ?? '',
              );
            },
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: PasswordVisibilityToggle(
              isObscured: obscureConfirmPassword,
              onToggle: onObscureConfirmPasswordChanged,
              fieldName: 'confirmação de senha',
              fieldSemanticName: 'register_confirm_password',
            ),
            onSubmitted: (value) {
              registerButtonFocusNode?.requestFocus();
            },
          ),
          const SizedBox(height: 20),
          _buildErrorMessage(authState),
          _buildRegisterButton(context, ref, authState),
          const SizedBox(height: 16),
          _buildTermsAndPrivacy(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AsyncValue<auth_providers.AuthState> authState) {
    return authState.when(
      data: (state) {
        if (state.errorMessage != null) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildRegisterButton(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<auth_providers.AuthState> authState,
  ) {
    return authState.when(
      data: (state) {
        return AccessibleButton(
          focusNode: registerButtonFocusNode,
          onPressed: state.isLoading ? null : onRegister,
          semanticLabel: AccessibilityTokens.getSemanticLabel(
            'register_button',
            'Criar conta',
          ),
          tooltip: 'Criar nova conta',
          backgroundColor:
              state.isLoading ? Colors.grey.shade400 : PlantisColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            AccessibilityTokens.largeTouchTargetSize,
          ),
          hapticPattern: 'medium',
          child: state.isLoading
              ? Semantics(
                  label: AccessibilityTokens.getSemanticLabel(
                    'loading',
                    'Criando conta',
                  ),
                  liveRegion: true,
                  child: const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : Text(
                  'Criar Conta',
                  style: TextStyle(
                    fontSize: AccessibilityTokens.getAccessibleFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          height: 1.4,
        ),
        children: [
          const TextSpan(
            text: 'Ao criar uma conta, você concorda com nossos\n',
          ),
          TextSpan(
            text: 'Termos de Serviço',
            style: TextStyle(
              color: Colors.blue.shade600,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsOfService,
          ),
          const TextSpan(text: ' e '),
          TextSpan(
            text: 'Política de Privacidade',
            style: TextStyle(
              color: Colors.blue.shade600,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}

/// Password visibility toggle widget - show/hide password button
class PasswordVisibilityToggle extends StatelessWidget {
  final bool isObscured;
  final ValueChanged<bool> onToggle;
  final String fieldName;
  final String fieldSemanticName;

  const PasswordVisibilityToggle({
    required this.isObscured,
    required this.onToggle,
    required this.fieldName,
    required this.fieldSemanticName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isObscured
          ? AccessibilityTokens.getSemanticLabel(
              'show_$fieldSemanticName',
              'Mostrar $fieldName',
            )
          : AccessibilityTokens.getSemanticLabel(
              'hide_$fieldSemanticName',
              'Ocultar $fieldName',
            ),
      button: true,
      child: IconButton(
        icon: Icon(
          isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: PlantisColors.primary.withValues(alpha: 0.7),
          size: 22,
        ),
        onPressed: () {
          AccessibilityTokens.performHapticFeedback('light');
          onToggle(!isObscured);
          final message =
              !isObscured ? '$fieldName ocultada' : '$fieldName visível';
          SemanticsService.announce(message, ui.TextDirection.ltr);
        },
      ),
    );
  }
}

/// Remember me section - checkbox and forgot password link
class RememberMeSection extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPassword;

  const RememberMeSection({
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              onRememberMeChanged(!rememberMe);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          rememberMe ? PlantisColors.primary : Colors.transparent,
                      border: Border.all(
                        color: rememberMe
                            ? PlantisColors.primary
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: rememberMe
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lembrar-me',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Esqueceu a senha?',
            style: TextStyle(
              color: PlantisColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Social login section - Google, Apple, Microsoft buttons
class SocialLoginSection extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;
  final VoidCallback onMicrosoftLogin;

  const SocialLoginSection({
    required this.onGoogleLogin,
    required this.onAppleLogin,
    required this.onMicrosoftLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou continue com',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              'G',
              Colors.red.shade600,
              onGoogleLogin,
            ),
            _buildSocialButton(
              null,
              Colors.black,
              onAppleLogin,
              icon: Icons.apple,
            ),
            _buildSocialButton(
              null,
              Colors.blue.shade600,
              onMicrosoftLogin,
              icon: Icons.apps,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '* Opções de login social estarão disponíveis em breve',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String? text,
    Color color,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: color, size: 20)
                  : Text(
                      text!,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Anonymous login section - continue without account button
class AnonymousLoginSection extends ConsumerWidget {
  final VoidCallback onAnonymousLogin;

  const AnonymousLoginSection({
    required this.onAnonymousLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(auth_providers.authProvider);

    return authState.when(
      data: (state) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: OutlinedButton(
            onPressed: state.isLoading ? null : onAnonymousLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: PlantisColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PlantisColors.primary,
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: PlantisColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Continuar sem conta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: PlantisColors.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => const SizedBox.shrink(),
    );
  }
}
