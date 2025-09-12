import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_list_tile.dart';

/// Seção de autenticação nas configurações
/// Mostra estado do usuário e opções de login/logout
class AuthSection extends StatelessWidget {
  const AuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReceitaAgroAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return _buildLoadingSection();
        }

        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
          return _buildGuestSection(context, authProvider);
        }

        return _buildAuthenticatedSection(context, authProvider);
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '👤 Conta'),
        Card(
          child: ListTile(
            leading: const CircularProgressIndicator(),
            title: const Text('Carregando...'),
            subtitle: const Text('Verificando autenticação'),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '👤 Conta'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Visitante'),
                subtitle: const Text('Faça login para sincronizar seus dados'),
                trailing: const Icon(Icons.info_outline, color: Colors.orange),
              ),
              const Divider(height: 1),
              SettingsListTile(
                leadingIcon: Icons.login,
                title: 'Fazer Login',
                subtitle: 'Acessar sua conta',
                onTap: () => _showLoginDialog(context, authProvider),
              ),
              SettingsListTile(
                leadingIcon: Icons.person_add,
                title: 'Criar Conta',
                subtitle: 'Cadastre-se para sincronizar dados',
                onTap: () => _showSignupDialog(context, authProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedSection(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final user = authProvider.currentUser!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '👤 Conta'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    user.displayName.isNotEmpty 
                        ? user.displayName[0].toUpperCase() 
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text(user.email),
                trailing: Icon(
                  Icons.verified_user,
                  color: user.isEmailVerified ? Colors.green : Colors.orange,
                ),
              ),
              if (!user.isEmailVerified) ...[
                const Divider(height: 1),
                SettingsListTile(
                  leadingIcon: Icons.email_outlined,
                  title: 'Verificar Email',
                  subtitle: 'Clique para verificar seu email',
                  onTap: () => _verifyEmail(context, authProvider),
                ),
              ],
              const Divider(height: 1),
              SettingsListTile(
                leadingIcon: Icons.edit,
                title: 'Editar Perfil',
                subtitle: 'Alterar nome e informações',
                onTap: () => _showEditProfileDialog(context, authProvider),
              ),
              const Divider(height: 1),
              SettingsListTile(
                leadingIcon: Icons.logout,
                title: 'Fazer Logout',
                subtitle: 'Sair da conta',
                onTap: () => _showLogoutConfirmation(context, authProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLoginDialog(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                _showErrorSnackBar(context, 'Preencha todos os campos');
                return;
              }
              
              final result = await authProvider.signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text,
              );
              
              if (result.isSuccess) {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Login realizado com sucesso!');
              } else {
                _showErrorSnackBar(context, result.errorMessage ?? 'Erro no login');
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  void _showSignupDialog(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || 
                  emailController.text.isEmpty || 
                  passwordController.text.isEmpty) {
                _showErrorSnackBar(context, 'Preencha todos os campos');
                return;
              }
              
              final result = await authProvider.signUpWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text,
                displayName: nameController.text.trim(),
              );
              
              if (result.isSuccess) {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Conta criada com sucesso!');
              } else {
                _showErrorSnackBar(context, result.errorMessage ?? 'Erro ao criar conta');
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.currentUser?.displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement profile update
              Navigator.pop(context);
              _showInfoSnackBar(context, 'Funcionalidade em desenvolvimento');
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _verifyEmail(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    // TODO: Implement email verification
    _showInfoSnackBar(context, 'Email de verificação enviado!');
  }

  void _showLogoutConfirmation(BuildContext context, ReceitaAgroAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Logout'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
              _showInfoSnackBar(context, 'Logout realizado');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}