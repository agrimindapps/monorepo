import 'package:flutter/material.dart';

/// Widget de avatar de perfil com fallback para iniciais
/// Suporta imagens de rede, assets locais e fallback para iniciais
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? displayName;
  final String? fallbackText;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showEditIcon;
  final IconData editIcon;
  final Color? editIconColor;
  final Color? editIconBackgroundColor;
  final double editIconSize;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.displayName,
    this.fallbackText,
    this.size = 100,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
    this.loadingWidget,
    this.errorWidget,
    this.showEditIcon = false,
    this.editIcon = Icons.camera_alt,
    this.editIconColor,
    this.editIconBackgroundColor,
    this.editIconSize = 18,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? _getDefaultBackgroundColor(theme),
              gradient: gradient,
              borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
              border: border,
              boxShadow: boxShadow ?? _getDefaultBoxShadow(),
            ),
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
              child: _buildAvatarContent(context, theme),
            ),
          ),
          
          // Edit icon
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: size * 0.36, // 36% do tamanho do avatar
                  height: size * 0.36,
                  decoration: BoxDecoration(
                    color: editIconBackgroundColor ?? theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    editIcon,
                    color: editIconColor ?? Colors.white,
                    size: editIconSize,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, ThemeData theme) {
    // Se tem URL de imagem, tentar carregar
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ?? _buildLoadingWidget(theme);
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildFallbackWidget(theme);
        },
      );
    }
    
    // Fallback para iniciais
    return _buildFallbackWidget(theme);
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Center(
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: size * 0.04,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackWidget(ThemeData theme) {
    final initials = _getInitials();
    final effectiveForegroundColor = foregroundColor ?? 
        (gradient != null ? Colors.white : theme.colorScheme.onPrimary);
    
    return Center(
      child: Text(
        initials,
        style: textStyle?.copyWith(color: effectiveForegroundColor) ?? 
            TextStyle(
              color: effectiveForegroundColor,
              fontSize: size * 0.32, // 32% do tamanho do avatar
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getInitials() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return fallbackText!;
    }
    
    if (displayName != null && displayName!.isNotEmpty) {
      final words = displayName!.split(' ').where((word) => word.isNotEmpty).toList();
      
      if (words.isEmpty) return '?';
      if (words.length == 1) {
        return words[0].substring(0, 1).toUpperCase();
      }
      
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
    }
    
    return '?';
  }

  Color _getDefaultBackgroundColor(ThemeData theme) {
    if (gradient != null) return Colors.transparent;
    return theme.colorScheme.primary;
  }

  List<BoxShadow> _getDefaultBoxShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Extensão para criar avatares com configurações predefinidas
extension ProfileAvatarPresets on ProfileAvatar {
  /// Avatar pequeno (40x40)
  static ProfileAvatar small({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: 40,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradient: gradient,
      onTap: onTap,
      showEditIcon: showEditIcon,
      editIconSize: 12,
      onEditTap: onEditTap,
    );
  }

  /// Avatar médio (60x60)
  static ProfileAvatar medium({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: 60,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradient: gradient,
      onTap: onTap,
      showEditIcon: showEditIcon,
      editIconSize: 14,
      onEditTap: onEditTap,
    );
  }

  /// Avatar grande (100x100) - padrão
  static ProfileAvatar large({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: 100,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradient: gradient,
      onTap: onTap,
      showEditIcon: showEditIcon,
      editIconSize: 18,
      onEditTap: onEditTap,
    );
  }

  /// Avatar extra grande (120x120)
  static ProfileAvatar extraLarge({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: 120,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      gradient: gradient,
      onTap: onTap,
      showEditIcon: showEditIcon,
      editIconSize: 20,
      onEditTap: onEditTap,
    );
  }

  /// Avatar com gradiente padrão verde
  static ProfileAvatar withGreenGradient({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    double size = 100,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: size,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4CAF50), // Green 500
          Color(0xFF2E7D32), // Green 700
        ],
      ),
      foregroundColor: Colors.white,
      onTap: onTap,
      showEditIcon: showEditIcon,
      onEditTap: onEditTap,
    );
  }

  /// Avatar com gradiente padrão azul
  static ProfileAvatar withBlueGradient({
    String? imageUrl,
    String? displayName,
    String? fallbackText,
    double size = 100,
    VoidCallback? onTap,
    bool showEditIcon = false,
    VoidCallback? onEditTap,
  }) {
    return ProfileAvatar(
      imageUrl: imageUrl,
      displayName: displayName,
      fallbackText: fallbackText,
      size: size,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2196F3), // Blue 500
          Color(0xFF1565C0), // Blue 800
        ],
      ),
      foregroundColor: Colors.white,
      onTap: onTap,
      showEditIcon: showEditIcon,
      onEditTap: onEditTap,
    );
  }
}