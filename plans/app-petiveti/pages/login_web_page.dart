// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PetiVetiLoginWebPage extends StatefulWidget {
  const PetiVetiLoginWebPage({super.key});

  @override
  State<PetiVetiLoginWebPage> createState() => _PetiVetiLoginWebPageState();
}

class _PetiVetiLoginWebPageState extends State<PetiVetiLoginWebPage> {
  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Chaves do formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Estado de carregamento
  bool _isLoading = false;

  // Estado de visibilidade da senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Estado para mostrar a tela de recuperação de senha
  bool _showRecoveryForm = false;

  // Estado para alternar entre login e cadastro
  bool _isLoginMode = true;

  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cores do tema seguindo o padrão PetiVeti
  final Color primaryColor = const Color(0xFF6A1B9A); // Roxo principal
  final Color accentColor = const Color(0xFF03A9F4); // Azul accent
  final Color backgroundColor = const Color(0xFFF5F5F5);

  // Helper methods para textos dinâmicos
  String _getTitleText() {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width <= 600;
    
    // Na web sempre mostra "Entrar"
    if (!isMobile) {
      return 'Entrar';
    }
    
    // No mobile permite alternar
    return _isLoginMode ? 'Entrar' : 'Criar Conta';
  }

  String _getSubtitleText() {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width <= 600;
    
    // Na web sempre mostra texto de login
    if (!isMobile) {
      return 'Acesse sua conta para gerenciar';
    }
    
    // No mobile permite alternar
    return _isLoginMode 
        ? 'Acesse sua conta para gerenciar'
        : 'Crie sua conta para começar';
  }

  String _getButtonText() {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width <= 600;
    
    // Na web sempre mostra "Entrar"
    if (!isMobile) {
      return 'Entrar';
    }
    
    // No mobile permite alternar
    return _isLoginMode ? 'Entrar' : 'Criar Conta';
  }

  VoidCallback _getButtonAction() {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width <= 600;
    
    // Na web sempre executa login
    if (!isMobile) {
      return _signIn;
    }
    
    // No mobile permite alternar
    return _isLoginMode ? _signIn : _signUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Método para realizar login
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Redirecionar para a página principal após login bem-sucedido
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login realizado com sucesso!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Redirecionar após um pequeno delay para mostrar o toast
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado. Verifique seu email.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta. Tente novamente.';
          break;
        case 'invalid-email':
          errorMessage = 'Formato de email inválido.';
          break;
        case 'user-disabled':
          errorMessage = 'Este usuário foi desativado.';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          errorMessage = 'Ocorreu um erro. Tente novamente mais tarde.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para realizar cadastro
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Atualizar o nome do usuário
      if (_nameController.text.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(_nameController.text.trim());
      }

      // Cadastro bem-sucedido
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conta criada com sucesso!'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Redirecionar após um pequeno delay para mostrar o toast
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este email já está cadastrado. Tente fazer login.';
          break;
        case 'invalid-email':
          errorMessage = 'Formato de email inválido.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operação não permitida. Contate o suporte.';
          break;
        default:
          errorMessage = 'Ocorreu um erro. Tente novamente mais tarde.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para enviar email de recuperação de senha
  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, insira seu email para recuperação'),
          backgroundColor: Colors.amber[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Email de recuperação enviado! Verifique sua caixa de entrada.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Voltar para o formulário de login
        setState(() {
          _showRecoveryForm = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Não encontramos um usuário com este email.';
          break;
        case 'invalid-email':
          errorMessage = 'Formato de email inválido.';
          break;
        default:
          errorMessage = 'Ocorreu um erro. Tente novamente mais tarde.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 900;
    final bool isTablet = size.width > 600 && size.width <= 900;
    final bool isMobile = size.width <= 600;
    
    // Na web (desktop/tablet), força sempre modo login
    if (!isMobile && !_isLoginMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoginMode = true;
        });
      });
    }

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
                primaryColor.withValues(alpha: 0.6),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: isDesktop
                      ? _buildDesktopLayout(size)
                      : _buildMobileLayout(size),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
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
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.7),
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
                          Icons.pets,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'PetiVeti',
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
                      'Portal do Gestor',
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
                      'Acesse o sistema para gerenciar todas as informações sobre os cuidados com os pets.',
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
                        child: Image.network(
                          'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: 120,
                              ),
                            );
                          },
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
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: _showRecoveryForm ? _buildRecoveryForm() : _buildAuthForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
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
                Icons.pets,
                color: primaryColor,
                size: 40,
              ),
              const SizedBox(width: 10),
              Text(
                'PetiVeti',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Portal do Gestor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 50,
            height: 4,
            color: accentColor,
          ),
          const SizedBox(height: 30),

          // Formulário
          _showRecoveryForm ? _buildRecoveryForm() : _buildAuthForm(),
        ],
      ),
    );
  }

  // Widget para o toggle minimalista entre Login e Cadastro
  Widget _buildAuthToggle() {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width <= 600;
    
    // Na web (desktop/tablet), não mostra o toggle e força modo login
    if (!isMobile) {
      return const SizedBox(height: 30);
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoginMode = true;
                });
              },
              child: Column(
                children: [
                  Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _isLoginMode ? primaryColor : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _isLoginMode ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoginMode = false;
                });
              },
              child: Column(
                children: [
                  Text(
                    'Cadastrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: !_isLoginMode ? primaryColor : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                      color: !_isLoginMode ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Toggle entre Entrar e Cadastrar
        _buildAuthToggle(),
        
        // Container animado com todo o conteúdo
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Container(
            key: ValueKey(_isLoginMode ? 'login_container' : 'signup_container'),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    _getTitleText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    _getSubtitleText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campos do formulário
                  _buildFormFields(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Campo de nome (apenas no cadastro)
        if (!_isLoginMode) ...[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              hintText: 'Insira seu nome',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            validator: (value) {
              if (!_isLoginMode && (value == null || value.isEmpty)) {
                return 'Por favor, insira seu nome';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],

        // Campo de email
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Insira seu email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu email';
            }
            final bool emailValid = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value);

            if (!emailValid) {
              return 'Por favor, insira um email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Campo de senha
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Senha',
            hintText: 'Insira sua senha',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira sua senha';
            }
            if (!_isLoginMode && value.length < 6) {
              return 'A senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Campo de confirmar senha (apenas no cadastro)
        if (!_isLoginMode) ...[
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              hintText: 'Confirme sua senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (!_isLoginMode) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, confirme sua senha';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
        ],

        // Link para recuperação de senha (apenas no login)
        if (_isLoginMode) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _showRecoveryForm = true;
              });
            },
            child: Text(
              'Esqueceu sua senha?',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 30),

        // Botão de ação principal
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _getButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
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
                : Text(
                    _getButtonText(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        // Opções sociais apenas no login
        if (_isLoginMode) ...[
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
              _buildSocialLoginButton(
                icon: Icons.g_mobiledata,
                text: 'Google',
                color: Colors.red,
              ),
              const SizedBox(width: 15),
              _buildSocialLoginButton(
                icon: Icons.apple,
                text: 'Apple',
                color: Colors.black87,
              ),
              const SizedBox(width: 15),
              _buildSocialLoginButton(
                icon: Icons.window,
                text: 'Microsoft',
                color: Colors.blue.shade700,
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecoveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recuperar Senha',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviaremos um link para redefinir sua senha',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
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
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),

        // Botão de enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendPasswordResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
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
              });
            },
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Voltar para o login'),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Tooltip(
      message: 'Em breve',
      child: Opacity(
        opacity: 0.6,
        child: TextButton.icon(
          onPressed: null, // Desabilitado
          icon: Icon(icon, color: color),
          label: Text(text),
          style: TextButton.styleFrom(
            foregroundColor: color,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
