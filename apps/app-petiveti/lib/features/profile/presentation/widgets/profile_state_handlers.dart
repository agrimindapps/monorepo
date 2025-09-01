import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../shared/constants/profile_constants.dart';

/// **Profile State Handler Widgets**
/// 
/// Contains specialized widgets for handling different profile page states
/// including loading, error, and empty states with consistent design patterns.
/// 
/// ## Features:
/// - **Loading State**: Animated skeleton loading for profile content
/// - **Error State**: User-friendly error display with retry functionality
/// - **Empty State**: Guidance for unauthenticated or missing profile data
/// - **Accessibility**: Full screen reader and keyboard support
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced state management
abstract class ProfileStateHandlers {

  /// **Profile Loading State**
  /// 
  /// Displays animated skeleton loading placeholders that match the
  /// structure of the actual profile content for seamless transitions.
  static Widget buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      padding: ProfileConstants.pageContentPadding,
      child: Column(
        children: [
          // Profile header skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Avatar skeleton
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 16),
                // Name skeleton
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Email skeleton
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ProfileConstants.headerTopSpacing),
          
          // Menu sections skeleton
          ..._buildMenuSectionsSkeleton(),
        ],
      ),
    );
  }

  /// **Profile Error State**
  /// 
  /// Displays error information with retry functionality and user guidance.
  static Widget buildErrorState({
    required BuildContext context,
    required String? error,
    required VoidCallback onRetry,
  }) {
    return SingleChildScrollView(
      padding: ProfileConstants.pageContentPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Ocorreu um erro inesperado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Profile Unauthenticated State**
  /// 
  /// Displays guidance for users who are not logged in.
  static Widget buildUnauthenticatedState({
    required BuildContext context,
    required VoidCallback onSignIn,
  }) {
    return SingleChildScrollView(
      padding: ProfileConstants.pageContentPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Faça login para ver seu perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Acesse sua conta para gerenciar suas configurações, assinatura e dados dos seus pets.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Fazer Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Profile Header with User Data**
  /// 
  /// Displays the user profile header with avatar, name, and user information.
  static Widget buildProfileHeader(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // User avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.photoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(user.displayName),
                    ),
                  )
                : _buildDefaultAvatar(user.displayName),
          ),
          const SizedBox(height: 16),
          // User name
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // User email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          // Account type indicator
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isPremium ? Icons.star : Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isPremium ? 'Usuário Premium' : 'Usuário Padrão',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **Build Default Avatar**
  /// 
  /// Creates a default avatar with user's initials when no photo is available.
  static Widget _buildDefaultAvatar(String? displayName) {
    final initials = _getInitials(displayName);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  /// **Get User Initials**
  /// 
  /// Extracts initials from user's display name for avatar placeholder.
  static String _getInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'U';
    }
    
    final names = displayName.split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    } else {
      return (names[0][0] + names.last[0]).toUpperCase();
    }
  }

  /// **Build Menu Sections Skeleton**
  /// 
  /// Creates skeleton placeholders for menu sections during loading.
  static List<Widget> _buildMenuSectionsSkeleton() {
    return List.generate(3, (index) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        // Menu items skeleton
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(2, (itemIndex) => Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ));
  }
}