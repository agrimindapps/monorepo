// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../core/themes/manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String? _errorMessage;
  bool _showRecoveryForm = false;

  // Cores do tema
  final Color primaryColor = Colors.green.shade700;
  final Color accentColor = Colors.green.shade400;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Mostrar toast de sucesso
        Get.snackbar(
          'Sucesso',
          'Login realizado com sucesso!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        // Aqui normalmente redirecionaríamos para a página principal
        // Por enquanto só exibimos o toast conforme especificado
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorMessage = 'Nenhum usuário encontrado com este e-mail.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Senha incorreta.';
          } else if (e.code == 'invalid-email') {
            _errorMessage = 'E-mail inválido.';
          } else if (e.code == 'user-disabled') {
            _errorMessage = 'Este usuário foi desativado.';
          } else {
            _errorMessage = 'Erro ao fazer login: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Ocorreu um erro: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, informe seu e-mail para redefinir a senha.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'E-mail enviado',
        'Um link para redefinição de senha foi enviado para seu e-mail.',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );

      // Retornar para o formulário de login após enviar o email
      setState(() {
        _showRecoveryForm = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Nenhum usuário encontrado com este e-mail.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'E-mail inválido.';
        } else {
          _errorMessage = 'Erro ao enviar e-mail: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;
    final bool isTablet = size.width > 600 && size.width <= 900;
    final bool isMobile = size.width <= 600;
    final isDark = ThemeManager().isDark.value;

    final Color bgColor = isDark ? const Color(0xFF0F2418) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.grey.shade800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.green.shade700,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Voltar à tela anterior',
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ThemeManager().isDark.value
                  ? [
                      const Color(0xFF1A1A1D),
                      const Color(0xFF0F2418),
                    ]
                  : [
                      Colors.green.shade700,
                      Colors.green.shade600,
                      Colors.green.shade500,
                    ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      isMobile ? size.width * 0.9 : (isTablet ? 500 : 1000),
                  maxHeight:
                      isMobile ? double.infinity : (isTablet ? 650 : 650),
                ),
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.black26,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout(size, isDark, bgColor, textColor)
                      : _buildMobileLayout(size, isDark, bgColor, textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      Size size, bool isDark, Color bgColor, Color textColor) {
    return Row(
      children: [
        // Lado esquerdo com imagem/banner
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A2B1F),
                          const Color(0xFF0F2418),
                        ]
                      : [
                          Colors.green.shade600,
                          Colors.green.shade700,
                        ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Receituagro',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Sistema de Receituário Agronômico',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 50,
                      height: 4,
                      color: accentColor,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Acesse o sistema para gerenciar receitas, produtos e acompanhar os tratamentos agrícolas.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ilustração ou ícone temático
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.security,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Área restrita - Acesso seguro',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Lado direito com formulário
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: _showRecoveryForm ? _buildRecoveryForm() : _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      Size size, bool isDark, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo e título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                size: 40,
              ),
              const SizedBox(width: 10),
              Text(
                'Receituagro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.green.shade400 : Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sistema de Receituário Agronômico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Container(
            width: 50,
            height: 4,
            color: accentColor,
          ),
          const SizedBox(height: 30),

          // Formulário
          _showRecoveryForm ? _buildRecoveryForm() : _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final isDark = ThemeManager().isDark.value;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Entrar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse sua conta para gerenciar',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),

          // Campo de email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Insira seu email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isDark ? Colors.green[400]! : Colors.green[700]!),
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu e-mail';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Digite um e-mail válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de senha
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Insira sua senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isDark ? Colors.green[400]! : Colors.green[700]!),
              ),
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite sua senha';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Lembrar-me e Esqueceu sua senha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: isDark
                          ? Colors.green.shade600
                          : Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lembrar-me',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showRecoveryForm = true;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color:
                        isDark ? Colors.green.shade400 : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 30),

          // Botão de login
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.green.shade700 : Colors.green.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white70 : Colors.white,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ou continue com',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),

          // Opções de login social (desabilitadas)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                color: Colors.red.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                color: isDark ? Colors.white : Colors.black,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.window,
                label: 'Microsoft',
                color: Colors.blue.shade600,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '* Opções de login social estarão disponíveis em breve',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryForm() {
    final isDark = ThemeManager().isDark.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviaremos um link para redefinir sua senha',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 30),

        // Campo de email
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Insira seu email de cadastro',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? Colors.green[400]! : Colors.green[700]!),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 30),

        // Botão de enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? Colors.green.shade700 : Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
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
        ),

        const SizedBox(height: 20),

        // Voltar para o login
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _showRecoveryForm = false;
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Voltar para o login'),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? Colors.green.shade400 : Colors.green.shade700,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorMessage() {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Tooltip(
      message: 'Login com $label (Em breve)',
      child: OutlinedButton.icon(
        onPressed: null, // Desabilitado conforme solicitado
        icon: Icon(
          icon,
          size: 20,
          color: color.withValues(alpha: 0.5),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade500
                : Colors.grey.shade600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
