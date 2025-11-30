import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/profile_controller.dart';

/// Widget responsável por exibir e gerenciar a seção do avatar
class AvatarSection extends ConsumerStatefulWidget {

  const AvatarSection({
    super.key,
    required this.user,
    required this.isAnonymous,
    required this.profileController,
  });
  final dynamic user;
  final bool isAnonymous;
  final ProfileController profileController;

  @override
  ConsumerState<AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends ConsumerState<AvatarSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.isAnonymous) {
      return _buildAnonymousAvatar();
    }

    final photoUrl = widget.user?.photoUrl as String?;
    final hasAvatar = photoUrl != null && photoUrl.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child:
                hasAvatar
                    ? _buildAvatarImage(photoUrl)
                    : _buildDefaultAvatar(context),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildEditButton(context, hasAvatar),
        ),
      ],
    );
  }

  Widget _buildAnonymousAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_outline, size: 48, color: Colors.orange),
    );
  }

  Widget _buildAvatarImage(String imageSource) {
    try {
      if (imageSource.startsWith('data:image') ||
          imageSource.startsWith('/9j/') ||
          imageSource.startsWith('iVBOR')) {
        final base64String =
            imageSource.contains(',')
                ? imageSource.split(',').last
                : imageSource;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              debugPrint('❌ Error loading avatar image: $error');
            }
            return _buildDefaultAvatar(context);
          },
        );
      } else {
        return Image.network(
          imageSource,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              debugPrint('❌ Error loading avatar URL: $error');
            }
            return _buildDefaultAvatar(context);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing avatar image: $e');
      }
      return _buildDefaultAvatar(context);
    }
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, bool hasAvatar) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorPrimary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleEditAvatar(context, hasAvatar),
          child: const Icon(Icons.edit, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Future<void> _handleEditAvatar(BuildContext context, bool hasAvatar) async {
    if (kDebugMode) {
      debugPrint('📷 AvatarSection: Opening avatar editor');
    }

    await HapticFeedback.lightImpact();

    await widget.profileController.handleEditAvatar(
      context,
      hasAvatar,
      (File imageFile) => _processNewImage(context, imageFile),
      hasAvatar ? () => _removeCurrentImage(context) : null,
    );
  }

  Future<void> _processNewImage(BuildContext context, File imageFile) async {
    await widget.profileController.processNewAvatarImage(
      context,
      ref,
      imageFile,
    );
  }

  Future<void> _removeCurrentImage(BuildContext context) async {
    await widget.profileController.removeCurrentAvatar(context, ref);
  }
}
