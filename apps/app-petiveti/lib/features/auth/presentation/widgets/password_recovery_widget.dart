import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';

/// Password recovery form widget following SRP
/// 
/// Single responsibility: Handle password recovery UI and validation
class PasswordRecoveryWidget extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSendReset;
  final VoidCallback onBackToLogin;

  const PasswordRecoveryWidget({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.onSendReset,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Digite seu email para receber o link de recuperação',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        _buildEmailField(),
        const SizedBox(height: 32),
        
        _buildSendButton(),
        const SizedBox(height: 20),
        
        _buildBackButton(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SplashColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSendReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: SplashColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Enviar Link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton.icon(
        onPressed: onBackToLogin,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Voltar para login'),
      ),
    );
  }
}
