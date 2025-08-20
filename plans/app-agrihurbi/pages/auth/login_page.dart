// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Estado de carregamento
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Estado de validação dos campos
  final _formKey = GlobalKey<FormState>();

  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Métodos de autenticação
  Future<void> _signInWithEmailAndPassword() async {
    // Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tenta fazer login com email e senha
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Em caso de sucesso, exibe um toast
      if (mounted) {
        _showSuccessToast();
      }
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos de autenticação
      String errorMessage = 'Ocorreu um erro na autenticação';

      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado para este email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta para este usuário';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Credenciais inválidas';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Este usuário foi desativado';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Muitas tentativas de login. Tente novamente mais tarde';
      }

      _showErrorToast(errorMessage);
    } catch (e) {
      _showErrorToast('Erro ao fazer login: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorToast('Digite seu e-mail para redefinir a senha');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showInfoToast('Link de redefinição enviado para $email');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Não foi possível enviar o email de redefinição';

      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado com este email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do email é inválido';
      }

      _showErrorToast(errorMessage);
    } catch (e) {
      _showErrorToast('Erro ao redefinir senha: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Métodos para exibir mensagens
  void _showSuccessToast() {
    Get.snackbar(
      'Sucesso',
      'Login realizado com sucesso!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorToast(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showInfoToast(String message) {
    Get.snackbar(
      'Informação',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determina se está em modo móvel
    final isMobile = MediaQuery.of(context).size.width < 800;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = ThemeManager().isDark.value;

    return Scaffold(
      body: Stack(
        children: [
          // Background com imagem ou cor
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const NetworkImage(
                  'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/bg_01.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Conteúdo principal
          Align(
            alignment: Alignment.center,
            child: Container(
              width: isMobile ? double.infinity : 950,
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 0,
                vertical: isMobile ? 16 : 32,
              ),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      // Lado com a imagem (somente para telas grandes)
                      if (!isMobile)
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/bg_02.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                              // Gradiente sobre a imagem
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.green.shade900.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Gradiente sobreposto
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      bottomLeft: Radius.circular(16.0),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.green.shade900
                                            .withValues(alpha: 0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                                // Logo e slogan
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.eco,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'AgriHurbi',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Tecnologia que transforma o agronegócio',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Soluções digitais que simplificam o trabalho e aumentam a produtividade no campo.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Formulário de login
                      Expanded(
                        flex: isMobile ? 10 : 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 24 : 40,
                            vertical: 32,
                          ),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo para dispositivos móveis
                                  if (isMobile) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.eco,
                                          size: 32,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'AgriHurbi',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // Título do formulário
                                  Text(
                                    'Bem-vindo de volta!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Entre com suas credenciais para acessar o sistema.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.04),

                                  // Campo de e-mail
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'E-mail',
                                    hint: 'Insira seu e-mail',
                                    icon: Icons.email_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira seu e-mail';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Por favor, insira um e-mail válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Campo de senha
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Senha',
                                    hint: 'Insira sua senha',
                                    icon: Icons.lock_outline,
                                    obscureText: !_isPasswordVisible,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira sua senha';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Link para recuperar senha
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => _resetPassword(),
                                      child: Text(
                                        'Esqueceu a senha?',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.04),

                                  // Botão de login
                                  ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithEmailAndPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.green.shade200,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : const Text('Entrar'),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),

                                  // Divisor para opções de login social
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: isDarkMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'ou continue com',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: isDarkMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Botões de login social (desabilitados)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildSocialButton(
                                        icon:
                                            'assets/imagens/others/google.png',
                                        fallbackIcon: Icons.g_mobiledata,
                                        tooltip: 'Google (em breve)',
                                      ),
                                      _buildSocialButton(
                                        icon:
                                            'assets/imagens/others/microsoft.png',
                                        fallbackIcon: Icons.window,
                                        tooltip: 'Microsoft (em breve)',
                                      ),
                                      _buildSocialButton(
                                        icon: 'assets/imagens/others/apple.png',
                                        fallbackIcon: Icons.apple,
                                        tooltip: 'Apple (em breve)',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.03),

                                  // Texto de ajuda
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Precisa de ajuda? ',
                                          ),
                                          TextSpan(
                                            text: 'Contate o suporte',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Ação para contato com suporte
                                                _showInfoToast(
                                                    'Funcionalidade de suporte em desenvolvimento');
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = ThemeManager().isDark.value;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
        ),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green.shade700,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade700,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red.shade700,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required IconData fallbackIcon,
    required String tooltip,
  }) {
    final isDarkMode = ThemeManager().isDark.value;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: InkWell(
          onTap: null, // Desabilitado
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: 0.5, // Parcialmente transparente para indicar desativado
            child: Center(
              child: Image.asset(
                icon,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    fallbackIcon,
                    size: 24,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
