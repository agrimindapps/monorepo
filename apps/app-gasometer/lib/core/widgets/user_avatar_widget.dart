import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/user_entity.dart' as gasometer_entities;
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../services/avatar_service.dart';
import 'avatar_selection_dialog.dart';

/// Customizable user avatar widget with support for local and remote images
class UserAvatarWidget extends ConsumerWidget {

  const UserAvatarWidget({
    super.key,
    this.user,
    this.size = 80.0,
    this.showBorder = true,
    this.borderColor,
    this.isEditable = false,
    this.onTap,
    this.placeholderText,
  });
  final gasometer_entities.UserEntity? user;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final bool isEditable;
  final VoidCallback? onTap;
  final String? placeholderText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = user ?? ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final avatarService = AvatarService();

    return GestureDetector(
      onTap: isEditable 
          ? () => _handleAvatarTap(context)
          : onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? theme.primaryColor,
                      width: 2,
                    )
                  : null,
            ),
            child: ClipOval(
              child: _buildAvatarContent(currentUser, avatarService, theme),
            ),
          ),
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(gasometer_entities.UserEntity? user, AvatarService avatarService, ThemeData theme) {
    if (user?.hasLocalAvatar == true) {
      final bytes = avatarService.decodeAvatarBytes(user!.avatarBase64);
      if (bytes != null) {
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      }
    }

    if (user?.hasProfilePhoto == true) {
      return Image.network(
        user!.photoUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(user, theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return _buildPlaceholder(user, theme);
  }

  Widget _buildPlaceholder(gasometer_entities.UserEntity? user, ThemeData theme) {
    final displayText = _getPlaceholderText(user);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  String _getPlaceholderText(gasometer_entities.UserEntity? user) {
    if (placeholderText != null) {
      return placeholderText!;
    }

    if (user?.hasDisplayName == true) {
      final names = user!.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return user.displayName![0].toUpperCase();
    }

    if (user?.email != null) {
      return user!.email![0].toUpperCase();
    }

    return 'U'; // User placeholder
  }

  void _handleAvatarTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      showAvatarSelectionDialog(context);
    }
  }
}

/// Simplified avatar widget for small displays (like app bars)
class UserAvatarSmall extends StatelessWidget {

  const UserAvatarSmall({
    super.key,
    this.user,
    this.size = 32.0,
    this.onTap,
  });
  final gasometer_entities.UserEntity? user;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(
      user: user,
      size: size,
      showBorder: false,
      isEditable: false,
      onTap: onTap,
    );
  }
}

/// Large avatar for profile pages with edit capability
class UserAvatarLarge extends StatelessWidget {

  const UserAvatarLarge({
    super.key,
    this.user,
    this.size = 120.0,
    this.showEditIcon = true,
  });
  final gasometer_entities.UserEntity? user;
  final double size;
  final bool showEditIcon;

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(
      user: user,
      size: size,
      showBorder: true,
      isEditable: showEditIcon,
    );
  }
}