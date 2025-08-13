// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/application/auth_service.dart';

class UserProfileCardWidget extends StatelessWidget {
  const UserProfileCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AuthService>(
      init: AuthService.instance,
      builder: (authService) {
        if (authService.isLoading) {
          return _buildLoadingCard();
        }

        return Card(
          elevation: 2,
          color: PlantasColors.cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: authService.isLoggedIn
              ? _buildLoggedInContent(authService.currentUser!)
              : _buildLoggedOutContent(),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        color: PlantasColors.cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: PlantasColors.borderColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: PlantasColors.borderColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 180,
                      decoration: BoxDecoration(
                        color: PlantasColors.borderColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOutContent() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: PlantasColors.borderColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: PlantasColors.borderColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                size: 32,
                color: PlantasColors.subtitleColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fazer Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PlantasColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entre para sincronizar suas plantas',
                    style: TextStyle(
                      fontSize: 14,
                      color: PlantasColors.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => AuthService.instance.navegarParaLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantasColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInContent(UserModel user) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildAvatar(user),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.nomeExibicao,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PlantasColors.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.amber.withValues(alpha: 0.4)
                                  : Colors.amber[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: PlantasColors.subtitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: PlantasColors.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Membro desde ${_formatarDataCriacao(user.criadoEm)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: PlantasColors.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: PlantasColors.subtitleColor,
              ),
              color: PlantasColors.cardColor,
              surfaceTintColor: PlantasColors.surfaceColor,
              shadowColor: PlantasColors.shadowColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 20,
                        color: PlantasColors.textColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Editar Perfil',
                        style: TextStyle(
                          color: PlantasColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'configuracoes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 20,
                        color: PlantasColors.textColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Configurações',
                        style: TextStyle(
                          color: PlantasColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Sair',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuAction(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.avatarUrl!),
        onBackgroundImageError: (_, __) {
          // Fallback para initials se a imagem falhar
        },
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: PlantasColors.primaryColor,
      child: Text(
        user.iniciais,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatarDataCriacao(DateTime? data) {
    if (data == null) return '';

    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays < 30) {
      if (diferenca.inDays == 0) {
        return 'hoje';
      } else if (diferenca.inDays == 1) {
        return 'ontem';
      } else {
        return '${diferenca.inDays} dias';
      }
    } else if (diferenca.inDays < 365) {
      final meses = (diferenca.inDays / 30).floor();
      return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    } else {
      final anos = (diferenca.inDays / 365).floor();
      return '$anos ${anos == 1 ? 'ano' : 'anos'}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'perfil':
        Get.snackbar(
          'Em desenvolvimento',
          'Edição de perfil será implementada em breve',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'configuracoes':
        Get.snackbar(
          'Em desenvolvimento',
          'Configurações de conta serão implementadas em breve',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirmar = await AuthService.instance.mostrarDialogoLogout();
    if (confirmar) {
      await AuthService.instance.logout();
    }
  }
}
